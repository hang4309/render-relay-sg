#!/bin/sh
printf "%s" "$XRAY_CONFIG" > /etc/xray/config.json
exec /usr/bin/xray run -c /etc/xray/config.json
