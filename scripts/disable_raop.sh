#!/usr/bin/env bash

# disable_raop.sh
# Purpose: Disable RAOP (AirPlay) support in PipeWire by writing
#          a small override configuration file.
#
# This is useful on systems where RAOP support is unwanted or causes
# audio routing issues.

CONFIG_DIR="/etc/pipewire/pipewire.conf.d"
CONFIG_FILE="$CONFIG_DIR/disable-raop.conf"

echo "Creating PipeWire configuration directory if needed..."
mkdir -p "$CONFIG_DIR"

echo "Writing RAOP disable configuration to $CONFIG_FILE..."
cat << EOF > "$CONFIG_FILE"
context.properties = {
    module.raop = false
}
EOF

if [ $? -eq 0 ]; then
  echo "RAOP disable configuration written successfully."
  echo "Restarting PipeWire services..."

  systemctl --user restart pipewire pipewire-pulse
  if [ $? -eq 0 ]; then
    echo "PipeWire services restarted successfully."
  else
    echo "Warning: Failed to restart PipeWire services. You may need to restart them manually." >&2
  fi
else
  echo "Error: Failed to write $CONFIG_FILE." >&2
  exit 1
fi