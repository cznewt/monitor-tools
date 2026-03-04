
# UnpollerDeviceHighCPU

A UniFi device CPU utilization has been above 90% for over 15 minutes.

## Impact

High CPU usage can cause degraded network performance, dropped packets,
slow management responses, and potential device instability.

## Diagnosis

- Check the number of connected clients on the device.
- Review traffic volume and whether DPI or IDS/IPS is enabled.
- Look for firmware bugs related to high CPU in UniFi community forums.
- Check if a firmware update is available.

## Mitigation

- Reduce load by moving clients to other access points (band steering, RSSI limits).
- Disable resource-intensive features (DPI, IDS/IPS) if not critical.
- Reboot the device to clear transient issues.
- Upgrade firmware if a fix is available.
