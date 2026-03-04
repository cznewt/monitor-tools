
# UnpollerDeviceHighMemory

A UniFi device memory utilization has been above 90% for over 15 minutes.

## Impact

High memory usage can lead to out-of-memory conditions, process crashes,
degraded throughput, and device instability.

## Diagnosis

- Check the number of connected clients and active sessions.
- Review whether DPI, IDS/IPS, or other memory-intensive features are enabled.
- Check the device model's memory capacity and known limitations.
- Look for firmware-related memory leaks in UniFi community forums.

## Mitigation

- Reboot the device to reclaim leaked memory.
- Reduce connected client count by adjusting RSSI thresholds.
- Disable non-essential features consuming memory.
- Upgrade firmware if a fix for memory leaks is available.
