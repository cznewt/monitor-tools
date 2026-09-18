// OTEL TRACES scenario - payments service.
//
// This standalone app simulates a "reserve stock" workflow and emits traces via
// the OpenTelemetry SDK over OTLP/gRPC to Alloy. It never calls any other
// service; each loop tick produces one self-contained trace.
//
// Destination and service identity come entirely from the environment
// (OTEL_EXPORTER_OTLP_ENDPOINT, OTEL_SERVICE_NAME, OTEL_RESOURCE_ATTRIBUTES),
// read by the SDK itself - nothing here is hardcoded except the plaintext
// transport to Alloy.
use std::time::Duration;

use opentelemetry::global::BoxedTracer;
use opentelemetry::trace::{Span, Status, TraceContextExt, Tracer};
use opentelemetry::{global, Context, KeyValue};
use opentelemetry_otlp::SpanExporter;
use opentelemetry_sdk::trace::{BatchConfigBuilder, BatchSpanProcessor, SdkTracerProvider};
use opentelemetry_sdk::Resource;
use rand::Rng;

const WAREHOUSES: [&str; 3] = ["eu-west", "us-east", "ap-south"];
const SKUS: [&str; 4] = ["SKU-1001", "SKU-2002", "SKU-3003", "SKU-4004"];

#[derive(Debug)]
struct OutOfStock(String);

impl std::fmt::Display for OutOfStock {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "out_of_stock: insufficient quantity for {}", self.0)
    }
}

impl std::error::Error for OutOfStock {}

#[tokio::main]
async fn main() {
    // OTLP/gRPC exporter; the endpoint comes from OTEL_EXPORTER_OTLP_ENDPOINT.
    let exporter = SpanExporter::builder()
        .with_tonic()
        .build()
        .expect("failed to create OTLP trace exporter");
    // Short schedule delay so spans flush promptly (~1s) like the other samples.
    let batch = BatchSpanProcessor::builder(exporter)
        .with_batch_config(
            BatchConfigBuilder::default()
                .with_scheduled_delay(Duration::from_secs(1))
                .build(),
        )
        .build();
    // Resource: SDK defaults merged with OTEL_SERVICE_NAME / OTEL_RESOURCE_ATTRIBUTES.
    let provider = SdkTracerProvider::builder()
        .with_span_processor(batch)
        .with_resource(Resource::builder().build())
        .build();
    global::set_tracer_provider(provider.clone());
    let tracer = global::tracer("store/payments");

    println!("payments traces app started; emitting one trace per ~1s");
    let mut ticker = tokio::time::interval(Duration::from_secs(1));
    loop {
        tokio::select! {
            _ = ticker.tick() => reserve_stock(&tracer),
            _ = shutdown_signal() => break,
        }
    }
    println!("shutting down...");
    if let Err(err) = provider.shutdown() {
        eprintln!("error shutting down tracer provider: {err}");
    }
}

async fn shutdown_signal() {
    let ctrl_c = tokio::signal::ctrl_c();
    let mut term = tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())
        .expect("failed to install SIGTERM handler");
    tokio::select! {
        _ = ctrl_c => {},
        _ = term.recv() => {},
    }
}

// One trace per call: a root span with two nested children.
// BoxedTracer: its spans are Send + Sync, which attaching them to a Context requires.
fn reserve_stock(tracer: &BoxedTracer) {
    let mut rng = rand::thread_rng();
    let sku = SKUS[rng.gen_range(0..SKUS.len())];
    let warehouse = WAREHOUSES[rng.gen_range(0..WAREHOUSES.len())];
    let quantity: i64 = rng.gen_range(1..=10);

    // Root span, attached to the current context so the children nest under it.
    let mut root = tracer.start("reserve_stock");
    root.set_attribute(KeyValue::new("sku", sku));
    root.set_attribute(KeyValue::new("warehouse", warehouse));
    root.set_attribute(KeyValue::new("quantity", quantity));
    let cx = Context::current_with_span(root);
    let _guard = cx.clone().attach();

    // Child 1: check the warehouse for availability.
    let mut check = tracer.start_with_context("check_warehouse", &cx);
    check.set_attribute(KeyValue::new("warehouse", warehouse));
    check.set_attribute(KeyValue::new("sku", sku));
    std::thread::sleep(Duration::from_millis(rng.gen_range(10..50)));
    // A reorder is triggered when stock runs low - record it as a span event.
    check.add_event(
        "reorder_triggered",
        vec![KeyValue::new("sku", sku), KeyValue::new("reorder_quantity", 100i64)],
    );
    check.end();

    // Child 2: decrement the stock count.
    let mut decrement = tracer.start_with_context("decrement_stock", &cx);
    decrement.set_attribute(KeyValue::new("sku", sku));
    decrement.set_attribute(KeyValue::new("quantity", quantity));
    std::thread::sleep(Duration::from_millis(rng.gen_range(5..25)));
    // ~15% of ticks: the item is out of stock - record the exception and mark
    // the child span as errored.
    if rng.gen::<f64>() < 0.15 {
        let err = OutOfStock(sku.to_string());
        decrement.record_error(&err);
        decrement.set_status(Status::error("out_of_stock"));
    }
    decrement.end();

    cx.span().end();
}
