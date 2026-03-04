
# UnpollerAccessPointNoClients

A UniFi access point has had zero connected clients (users and guests)
for over 30 minutes.

## Impact

This is informational. An AP with no clients may indicate a coverage issue,
an SSID misconfiguration, or simply a low-traffic period.

## Diagnosis

- Verify the AP is broadcasting expected SSIDs.
- Check if clients can see and connect to the AP.
- Review AP placement and signal coverage area.
- Check if this is expected (e.g., off-hours, seasonal, isolated location).

## Mitigation

- If SSID misconfiguration: correct the SSID settings in the controller.
- If coverage issue: adjust AP placement or transmit power.
- If expected: consider suppressing this alert for specific APs.
