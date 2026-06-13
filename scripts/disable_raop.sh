#!/usr/bin/env bash
set -euo pipefail

# disable_raop.sh
# Purpose: Disable RAOP (AirPlay) support in PipeWire by writing
#          a small override configuration file.
#
# This is useful on systems where RAOP support is unwanted or causes
# audio routing issues.

LOCAL_CONFIG_DIR="$HOME/.config/pipewire/pipewire.conf.d"
SYSTEM_CONFIG_DIR="/etc/pipewire/pipewire.conf.d"
CONFIG_FILE_NAME="disable-raop.conf"

printf "Choose PipeWire configuration target:\n"
printf "  1) Local user config (%s)\n" "$LOCAL_CONFIG_DIR"
printf "  2) System config (%s) [requires sudo]\n" "$SYSTEM_CONFIG_DIR"
read -rp "Enter 1 or 2 [1]: " choice

case "${choice:-1}" in
  1|l|L)
    CONFIG_DIR="$LOCAL_CONFIG_DIR"
    USE_SUDO=false
    ;;
  2|s|S)
    CONFIG_DIR="$SYSTEM_CONFIG_DIR"
    USE_SUDO=true
    ;;
  *)
    echo "Invalid choice, please enter 1 or 2." >&2
    exit 1
    ;;
esac

CONFIG_FILE="$CONFIG_DIR/$CONFIG_FILE_NAME"

echo "Creating PipeWire configuration directory if needed..."
if [ "$USE_SUDO" = true ]; then
  sudo mkdir -p "$CONFIG_DIR"
else
  mkdir -p "$CONFIG_DIR"
fi

echo "Writing RAOP disable configuration to $CONFIG_FILE..."
if [ "$USE_SUDO" = true ]; then
  sudo tee "$CONFIG_FILE" > /dev/null <<'EOF'
context.properties = {
    module.raop = false
}
EOF
else
  cat <<'EOF' > "$CONFIG_FILE"
context.properties = {
    module.raop = false
}
EOF
fi

echo "RAOP disable configuration written successfully."
echo "Restarting PipeWire services..."
if systemctl --user restart pipewire pipewire-pulse; then
  echo "PipeWire services restarted successfully."
else
  echo "Warning: Failed to restart PipeWire services. You may need to restart them manually." >&2
fi