#!/bin/bash

ID=$(id -u)

if [ "$ID" != "0" ]; then
    echo "This command requires super user privilege - please run with sudo"
    exit 1
fi

# Check if snap is installed 
if (snap info snapshot-exclude-demo) 2>&1 | grep -q "no snap found"; then
	echo 'Cannot reqeust snapshot: snap "snapshot-exclude-demo" is not installed'
	exit 1
fi

# Do the REST API call
echo "Calling REST API /v2/snaps to action snapshot with dynamic exclusion..."
SET_ID=$( curl -s --unix-socket /run/snapd.socket --max-time 5 http://localhost/v2/snaps -X POST -H 'Content-Type: application/json' -d '{"action": "snapshot", "snaps": ["snapshot-exclude-demo"], "snapshot-options": {"snapshot-exclude-demo":{"exclude":["$SNAP_DATA/excl-*", "$SNAP_COMMON/.cache", "$SNAP_USER_COMMON/tmp", "$SNAP_USER_DATA/large-files/*-not-used.*"]}}}' | jq '.result."set-id"')
echo "Snapshot set ID is: $SET_ID"

# Display the metadata
echo "Metadata for set ID $SET_ID is:"
sleep 3
curl -s --unix-socket /run/snapd.socket --max-time 5 http://localhost/v2/snapshots?set="$SET_ID"
echo ""
