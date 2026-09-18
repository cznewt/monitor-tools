// PROM CLIENT scenario - payments service.
//
// This standalone app simulates a warehouse inventory domain and EXPOSES its
// metrics on /metrics using the native Prometheus Rust client. Alloy scrapes
// this endpoint across the network, so the server binds to 0.0.0.0:9100.
// A background thread updates the metrics roughly once per second.
use std::sync::LazyLock;
use std::thread;
use std::time::Duration;

use prometheus::{
    register_gauge, register_histogram, register_int_counter_vec, Encoder, Gauge, Histogram,
    IntCounterVec, TextEncoder,
};
use rand::Rng;

const WAREHOUSES: [&str; 3] = ["eu-west", "us-east", "ap-south"];

// Counter: total inventory updates, labelled by warehouse + operation.
static INVENTORY_UPDATES_TOTAL: LazyLock<IntCounterVec> = LazyLock::new(|| {
    register_int_counter_vec!(
        "inventory_updates_total",
        "Total number of inventory update operations.",
        &["warehouse", "operation"]
    )
    .unwrap()
});
// Histogram: stock reservation duration in seconds (idiomatic unit, default buckets).
static INVENTORY_RESERVATION_DURATION: LazyLock<Histogram> = LazyLock::new(|| {
    register_histogram!(
        "inventory_reservation_duration_seconds",
        "Duration of a stock reservation operation in seconds."
    )
    .unwrap()
});
// Gauge: current stock level across the warehouse.
static INVENTORY_STOCK_LEVEL: LazyLock<Gauge> = LazyLock::new(|| {
    register_gauge!("inventory_stock_level", "Current number of items in stock.").unwrap()
});
// Gauge: shipments currently pending dispatch.
static INVENTORY_PENDING_SHIPMENTS: LazyLock<Gauge> = LazyLock::new(|| {
    register_gauge!(
        "inventory_pending_shipments",
        "Number of shipments currently pending dispatch."
    )
    .unwrap()
});

fn main() {
    // Seed initial gauge values so the first scrape has sensible data.
    INVENTORY_STOCK_LEVEL.set(5000.0);
    INVENTORY_PENDING_SHIPMENTS.set(12.0);
    thread::spawn(simulate);

    let server = tiny_http::Server::http("0.0.0.0:9100").expect("metrics server failed to bind");
    println!("payments prometheus client listening on 0.0.0.0:9100/metrics");
    for request in server.incoming_requests() {
        if request.url() != "/metrics" {
            let _ = request.respond(tiny_http::Response::empty(404));
            continue;
        }
        let encoder = TextEncoder::new();
        let mut body = Vec::new();
        encoder.encode(&prometheus::gather(), &mut body).unwrap();
        let header = tiny_http::Header::from_bytes("Content-Type", encoder.format_type()).unwrap();
        let _ = request.respond(tiny_http::Response::from_data(body).with_header(header));
    }
}

fn simulate() {
    loop {
        thread::sleep(Duration::from_secs(1));
        let mut rng = rand::thread_rng();
        let warehouse = WAREHOUSES[rng.gen_range(0..WAREHOUSES.len())];
        // ~8% of ticks are errors: larger latency + an error operation label.
        let is_error = rng.gen::<f64>() < 0.08;
        let (operation, latency) = if is_error {
            ("reserve_failed", 0.2 + rng.gen::<f64>() * 0.3) // 200-500 ms on error
        } else {
            ("reserve", 0.02 + rng.gen::<f64>() * 0.04) // 20-60 ms nominal
        };
        INVENTORY_UPDATES_TOTAL.with_label_values(&[warehouse, operation]).inc();
        INVENTORY_RESERVATION_DURATION.observe(latency);
        // Reserve items (down) unless this tick is a restock (up).
        if !is_error && rng.gen::<f64>() < 0.3 {
            INVENTORY_STOCK_LEVEL.add(rng.gen_range(50..200) as f64);
        } else {
            INVENTORY_STOCK_LEVEL.sub(rng.gen_range(1..6) as f64);
        }
        // Drift the pending-shipment gauge.
        INVENTORY_PENDING_SHIPMENTS.add(rng.gen_range(-2..3) as f64);
    }
}
