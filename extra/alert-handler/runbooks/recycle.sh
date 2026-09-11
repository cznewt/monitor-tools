#!/bin/sh
# Demo runbook. In a cluster this would be `kubectl -n "$1" rollout restart
# deployment/"$2"`; compose has no API server, so it just reports what it would
# do - including the credential it was handed, to show that the handler redacts
# it in the log.
set -eu
echo "would recycle $2 in $1 after $ALERT_LABEL_ALERTNAME (token=${DEMO_TOKEN:-none})"
