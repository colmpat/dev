#!/bin/bash
# Set deluge listen/outgoing interface to nordlynx IP before daemon starts.
# nordlynx IP changes per VPN connection, so this resolves it at startup.

CONF="/srv/deluge/.config/deluge/core.conf"
NORDLYNX_IP=$(ip -4 addr show nordlynx 2>/dev/null | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+')

if [ -z "$NORDLYNX_IP" ]; then
    echo "ERROR: nordlynx interface not found or has no IP" >&2
    exit 1
fi

sed -i "s/\"listen_interface\": \".*\"/\"listen_interface\": \"$NORDLYNX_IP\"/" "$CONF"
sed -i "s/\"outgoing_interface\": \".*\"/\"outgoing_interface\": \"$NORDLYNX_IP\"/" "$CONF"

echo "Set deluge interfaces to $NORDLYNX_IP"
