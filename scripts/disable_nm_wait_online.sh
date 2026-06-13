#!/usr/bin/env bash

# disable_nm_wait_online.sh
# Purpose: Disable NetworkManager-wait-online.service to reduce boot
#          time by preventing systemd from waiting for network-online.target.
#
# This script disables and masks the service using systemctl. It may
# require sudo privileges when run.

SERVICE=NetworkManager-wait-online.service

if ! systemctl status --no-pager "$SERVICE" >/dev/null 2>&1; then
  echo "Service $SERVICE not found or not active; nothing to do."
  exit 0
fi

echo "Disabling and masking $SERVICE (may prompt for sudo)..."
sudo systemctl disable "$SERVICE"
sudo systemctl mask "$SERVICE"
echo "Done. $SERVICE is disabled and masked."
