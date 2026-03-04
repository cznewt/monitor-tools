
# UnpollerHighClientDropRate

A UniFi access point is dropping more than 50 packets per second
(combined receive and transmit) for over 10 minutes.

## Impact

Connected clients experience degraded network quality with packet loss,
slow connections, and potential application timeouts.

## Diagnosis

- Check channel utilization for congestion on 2.4GHz or 5GHz bands.
- Verify the number of clients per AP is within recommended limits.
- Look for sources of RF interference (neighboring APs, microwaves, etc.).
- Check if specific VLANs or SSIDs are disproportionately affected.

## Mitigation

- Adjust channel assignments to reduce co-channel interference.
- Enable band steering to move capable clients to 5GHz.
- Reduce transmit power or adjust AP placement.
- Consider adding additional APs to distribute client load.
