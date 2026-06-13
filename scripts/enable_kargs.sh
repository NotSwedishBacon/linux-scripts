#!/bin/bash

# enable_kargs.sh
# Purpose: Write `/etc/modprobe.d/i915.conf` with recommended i915
# kernel module options and ensure the file is included in the initramfs
# on rpm-ostree systems by running `rpm-ostree initramfs`.
#
# What it does:
# - backs up an existing `/etc/modprobe.d/i915.conf` (timestamped)
# - writes the two `options i915` lines shown below
# - runs `sudo rpm-ostree initramfs --enable --arg=-I --arg=/etc/modprobe.d/i915.conf`
#
# Usage:
#   bash scripts/enable_kargs.sh
#
# Notes:
# - This script requires `sudo` and `rpm-ostree` to be available.
# - Running the rpm-ostree command typically requires a reboot to apply.

CONFIG_FILE="/etc/modprobe.d/i915.conf"
BACKUP_SUFFIX="$(date +%Y%m%d%H%M%S)"

echo "Checking for required command: rpm-ostree..."
if ! command -v rpm-ostree >/dev/null 2>&1; then
  echo "Error: rpm-ostree not found in PATH. This script is intended for rpm-ostree systems." >&2
  exit 1
fi

echo "Preparing to write $CONFIG_FILE"

if sudo test -f "$CONFIG_FILE"; then
  echo "Backing up existing $CONFIG_FILE to ${CONFIG_FILE}.backup.$BACKUP_SUFFIX"
  sudo cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$BACKUP_SUFFIX"
fi

TMPFILE="$(mktemp)"
cat > "$TMPFILE" <<'EOF'
options i915 enable_guc=2
options i915 enable_fbc=1
EOF

echo "Installing new $CONFIG_FILE (this requires sudo)..."
sudo install -m 644 "$TMPFILE" "$CONFIG_FILE"
rm -f "$TMPFILE"

echo "Updating initramfs to include $CONFIG_FILE via rpm-ostree..."
sudo rpm-ostree initramfs --enable --arg=-I --arg=/etc/modprobe.d/i915.conf

if [ $? -eq 0 ]; then
  echo "rpm-ostree initramfs updated successfully."
  echo "Reboot your machine to ensure the new kernel options are applied." 
else
  echo "Error: rpm-ostree initramfs command failed." >&2
  exit 1
fi

echo "Done."
