
# UnpollerHighVAPErrorRate

A UniFi access point VAP is experiencing more than 10 errors per second
(combined receive and transmit) for over 10 minutes.

## Impact

Wireless errors indicate physical-layer or driver-level issues that degrade
client connectivity, throughput, and reliability.

## Diagnosis

- Check for RF interference sources near the affected AP.
- Review channel utilization and noise floor levels.
- Verify antenna connections and physical hardware condition.
- Check if errors correlate with specific firmware versions.
- Look for CRC errors, fragmentation, or crypto errors in the metrics.

## Mitigation

- Change wireless channel to avoid interference.
- Reduce transmit power if signal reflections are causing issues.
- Update firmware to address known driver bugs.
- Replace hardware if physical defect is suspected.
