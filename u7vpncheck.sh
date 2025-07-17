#!/bin/bash

CONFIG="/path/to/your.ovpn"
TEST_URL="https://ifconfig.me"
EXPECTED_VPN_IP="XXX.XXX.XXX.XXX"

PID_FILE="/tmp/openvpn.pid"

echo "Connecting to VPN..."
sudo openvpn --config "$CONFIG" --daemon --writepid "$PID_FILE"

for i in {1..15}; do
  sleep 1
  CURRENT_IP=$(curl -s --max-time 5 "$TEST_URL")
  if [[ "$CURRENT_IP" != "" ]]; then
    break
  fi
done

echo "Current external IP: $CURRENT_IP"

if [[ "$CURRENT_IP" = "$EXPECTED_VPN_IP" ]]; then
  echo "VPN IP address is correct."
  STATUS=0
else
  echo "VPN IP address does not match the expected value."
  STATUS=1
fi

if [[ -f "$PID_FILE" ]]; then
  echo "Disconnecting VPN..."
  sudo kill "$(cat "$PID_FILE")"
  rm "$PID_FILE"
fi

exit $STATUS
