#!/bin/bash

if ! command -v openvpn >/dev/null 2>&1; then
  echo "Error: openvpn is not installed"
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is not installed"
  exit 1
fi

CONF_FILE="$(dirname "$0")/u7vpncheck.conf"
if [ ! -f "$CONF_FILE" ]; then
  echo "Error: config file '$CONF_FILE' does not exist"
  exit 1
fi
source "$CONF_FILE"

TEST_URL="https://ifconfig.me"

PID_FILE="/tmp/openvpn.pid"

echo "Connecting to VPN..."
sudo openvpn --config "$CONFIG" --daemon --writepid "$PID_FILE"
if [ $? -ne 0 ]; then
  echo "Error: failed to start openvpn"
  exit 1
fi

for i in {1..15}; do
  sleep 1
  CURRENT_IP=$(curl -s --max-time 5 "$TEST_URL")
  if [[ "$CURRENT_IP" != "" ]]; then
    break
  fi
done

if [[ "$CURRENT_IP" == "" ]]; then
  echo "Error: failed to obtain external IP address"
  if [[ -f "$PID_FILE" ]]; then
    sudo kill "$(cat "$PID_FILE")"
    rm "$PID_FILE"
  fi
  exit 1
fi

if [[ ! "$CURRENT_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  echo "Error: obtained value is not a valid IP address: '$CURRENT_IP'"
  if [[ -f "$PID_FILE" ]]; then
    sudo kill "$(cat "$PID_FILE")"
    rm "$PID_FILE"
  fi
  exit 1
fi

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
