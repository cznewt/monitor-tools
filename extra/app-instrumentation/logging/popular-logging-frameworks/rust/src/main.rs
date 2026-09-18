// Structured logging with `tracing` + `tracing-subscriber` (JSON to stdout).
// The same 12-case loop as the other languages: levels, structured fields,
// a nested object, errors with context and a child span carrying a request id.
use std::time::Duration;

use tracing::{debug, error, info, info_span, warn, Level};

fn main() {
    tracing_subscriber::fmt()
        .json()
        .with_max_level(Level::DEBUG)
        .with_target(true)
        .with_current_span(true)
        .flatten_event(true)
        .init();

    let mut counter: u64 = 0;
    info!(target: "app", "Starting Rust basic logging example with tracing");
    info!(target: "app", "Demonstrating tracing structured logging features");

    loop {
        counter += 1;
        match counter % 12 {
            0 => info!(target: "app", "hello world"),
            1 => error!(target: "app", "this is at error level"),
            2 => info!(target: "app", answer = 42, "the answer is 42"),
            3 => info!(target: "app", obj = 42, "hello world"),
            4 => info!(target: "app", obj = 42, counter, "hello world with counter"),
            5 => {
                let nested = serde_json::json!({"obj": 42, "timestamp": now_rfc3339()});
                info!(target: "app", nested = %nested, "nested object");
            }
            6 => error!(target: "app", error = "kaboom", "simulated error"),
            7 => info!(target: "app", "hello from app component!"),
            8 => warn!(target: "database", query = "SELECT * FROM users", duration_ms = 250, "slow query detected"),
            9 => info!(target: "api", method = "GET", path = "/api/users", status = 200, "API request completed"),
            10 => {
                let span = info_span!("request", request_id = format!("req-{counter}"));
                let _enter = span.enter();
                debug!(target: "app", "this is a debug statement via child");
            }
            11 => error!(target: "app", error = "kaboom", context1 = "additional", context2 = "information", "error with additional context"),
            _ => unreachable!(),
        }
        // Occasionally demonstrate different log levels.
        if counter % 20 == 0 {
            debug!(target: "app", counter, "this is a debug message");
            warn!(target: "app", counter, "this is a warning message");
        }
        std::thread::sleep(Duration::from_secs(1));
    }
}

fn now_rfc3339() -> String {
    let secs = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    format!("{secs}")
}
