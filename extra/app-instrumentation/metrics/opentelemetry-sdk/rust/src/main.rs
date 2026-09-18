// OTEL METRICS scenario - payments service.
//
// This standalone app simulates a warehouse inventory domain and PUSHES metrics
// via the OpenTelemetry SDK over OTLP/gRPC to Alloy. It never calls any other
// service; it only loops over its own simulated work once per second.
//
// Destination and service identity are taken entirely from the environment
// (OTEL_EXPORTER_OTLP_ENDPOINT, OTEL_SERVICE_NAME, OTEL_RESOURCE_ATTRIBUTES,
// OTEL_METRIC_EXPORT_INTERVAL) - nothing here is hardcoded except the plaintext
// transport to Alloy.
use std::sync::atomic::{AtomicI64, Ordering};
use std::sync::Arc;
use std::time::Duration;

use opentelemetry::{global, KeyValue};
use opentelemetry_otlp::MetricExporter;
use opentelemetry_sdk::metrics::{PeriodicReader, SdkMeterProvider};
use opentelemetry_sdk::Resource;
use rand::Rng;

const WAREHOUSES: [&str; 3] = ["eu-west", "us-east", "ap-south"];

// OTEL_METRIC_EXPORT_INTERVAL in milliseconds; 5s here rather than the SDK's 60s default.
fn export_interval() -> Duration {
    std::env::var("OTEL_METRIC_EXPORT_INTERVAL")
        .ok()
        .and_then(|v| v.parse::<u64>().ok())
        .map(Duration::from_millis)
        .unwrap_or(Duration::from_secs(5))
}

#[tokio::main]
async fn main() {
    let exporter = MetricExporter::builder()
        .with_tonic()
        .build()
        .expect("failed to create OTLP metric exporter");
    let reader = PeriodicReader::builder(exporter)
        .with_interval(export_interval())
        .build();
    let provider = SdkMeterProvider::builder()
        .with_reader(reader)
        .with_resource(Resource::builder().build())
        .build();
    global::set_meter_provider(provider.clone());
    let meter = global::meter("store/payments");

    // Counter: total inventory updates, labelled by warehouse + operation.
    let updates = meter
        .u64_counter("inventory.updates.total")
        .with_description("Total number of inventory update operations")
        .with_unit("{update}")
        .build();
    // Histogram: how long a stock reservation took, in milliseconds.
    let reservation_duration = meter
        .f64_histogram("inventory.reservation.duration.ms")
        .with_description("Duration of a stock reservation operation")
        .build();
    // UpDownCounter: current stock level (up on restock, down on reserve).
    let stock_level = meter
        .i64_up_down_counter("inventory.stock_level")
        .with_description("Current stock level delta applied this tick")
        .with_unit("{item}")
        .build();
    // Observable gauge: pending shipments, read on demand by the SDK from an atomic.
    let pending = Arc::new(AtomicI64::new(12));
    let observed = Arc::clone(&pending);
    let _pending_gauge = meter
        .i64_observable_gauge("inventory.pending_shipments")
        .with_description("Number of shipments currently pending dispatch")
        .with_unit("{shipment}")
        .with_callback(move |observer| observer.observe(observed.load(Ordering::Relaxed), &[]))
        .build();

    println!("payments metrics app started; pushing OTLP metrics every {:?}", export_interval());
    let mut ticker = tokio::time::interval(Duration::from_secs(1));
    loop {
        tokio::select! {
            _ = ticker.tick() => {
                let mut rng = rand::thread_rng();
                let warehouse = WAREHOUSES[rng.gen_range(0..WAREHOUSES.len())];
                // ~8% of ticks are errors: larger latency + an error status label.
                let is_error = rng.gen::<f64>() < 0.08;
                let (operation, status, latency) = if is_error {
                    ("reserve", "error", 200.0 + rng.gen::<f64>() * 300.0)
                } else {
                    ("reserve", "ok", 20.0 + rng.gen::<f64>() * 40.0)
                };
                let attrs = [
                    KeyValue::new("warehouse", warehouse),
                    KeyValue::new("operation", operation),
                    KeyValue::new("status", status),
                ];
                updates.add(1, &attrs);
                reservation_duration.record(latency, &attrs);
                // Reserve items (down) unless this tick is a restock (up).
                if !is_error && rng.gen::<f64>() < 0.3 {
                    stock_level.add(rng.gen_range(50..200), &[KeyValue::new("warehouse", warehouse)]);
                } else {
                    stock_level.add(-rng.gen_range(1..6), &[KeyValue::new("warehouse", warehouse)]);
                }
                // Drift the pending-shipment gauge.
                pending.fetch_add(rng.gen_range(-2..3), Ordering::Relaxed);
            },
            _ = shutdown_signal() => break,
        }
    }
    println!("shutting down...");
    if let Err(err) = provider.shutdown() {
        eprintln!("error shutting down meter provider: {err}");
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
