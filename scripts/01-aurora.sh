#!/bin/bash

# Enable TMP2 unlocking
ujust toggle-tpm2

# Disable RAOP (Airplay)
sudo mkdir -p /etc/pipewire/pipewire.conf.d
sudo tee "/etc/pipewire/pipewire.conf.d/disable-raop.conf" > /dev/null <<'EOF'
context.properties = {
    module.raop = false
}
EOF
systemctl --user restart pipewire pipewire-pulse;

# Install my flathub apps
# KDE apps
flatpak install flathub -y org.kde.krita &&
# non KDE apps
flatpak install flathub -y io.github.shiftey.Desktop &&
flatpak install flathub -y com.prusa3d.PrusaSlicer &&
flatpak install flathub -y org.telegram.desktop &&
flatpak install flathub -y com.spotify.Client

# Install official Discord client 
mkdir -p "$HOME/.local/share/discord"
mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
mkdir -p "$HOME/.local/share/applications"
curl -L -o "$HOME/Downloads/discord.tar.gz" "https://discord.com/api/download?platform=linux&format=tar.gz"
tar -xvf "$HOME/Downloads/discord.tar.gz" -C "$HOME/.local/share/discord/" --strip-components=1
ln -sf "$HOME/.local/share/discord/discord.png" "$HOME/.local/share/icons/hicolor/256x256/apps/discord.png"
cat << EOF > "$HOME/.local/share/applications/discord.desktop"
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=$HOME/.local/share/discord/discord
Icon=discord
Type=Application
Categories=Network;InstantMessaging;
Path=$HOME/.local/share/discord
EOF
chmod +x "$HOME/.local/share/applications/discord.desktop"
update-desktop-database "$HOME/.local/share/applications"
rm -f "$HOME/Downloads/discord.tar.gz"

# Enable devmode and aurora-cli
ujust aurora-cli
ujust devmode

echo "Time to reboot for all changes to take effect!"