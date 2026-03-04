
# UnpollerDeviceRestarted

A UniFi device has recently restarted (uptime less than 5 minutes).

## Impact

Clients connected to the device experienced a brief network outage.
This is informational unless restarts are recurring.

## Diagnosis

- Check if a firmware update was recently applied (expected restart).
- Check if the device was manually rebooted via the controller.
- Look for power supply issues or electrical events.
- If recurring, check for crash loops or overheating.

## Mitigation

- If firmware update: no action needed, verify device adopts correctly.
- If unexpected: investigate power supply stability.
- If recurring: check device logs, consider RMA if hardware fault suspected.
