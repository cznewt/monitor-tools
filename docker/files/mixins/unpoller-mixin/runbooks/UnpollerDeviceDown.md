
# UnpollerDeviceDown

A UniFi device has stopped reporting metrics to unpoller for over 15 minutes.

## Impact

The device may be offline, unreachable, or unpoller may have lost connectivity
to the UniFi controller. Clients connected to this device will lose network access.

## Diagnosis

- Check physical device status (LEDs, power).
- Verify network connectivity to the device (ping, SSH).
- Check the UniFi controller UI for device status.
- Verify unpoller is running and connected to the controller.
- Check for firmware update reboots or scheduled maintenance.

## Mitigation

- Power cycle the affected device if physically accessible.
- Restart unpoller if the controller is healthy but metrics are missing.
- Check and restore network path between the device and controller.
