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
flatpak install flathub -y org.libreoffice.LibreOffice &&
flatpak install flathub -y io.github.shiftey.Desktop &&
flatpak install flathub -y com.prusa3d.PrusaSlicer &&
flatpak install flathub -y org.telegram.desktop &&
flatpak install flathub -y com.spotify.Client

# Install official Discord client 
sudo mkdir -p "/var/opt/discord"
sudo mkdir -p "/usr/local/share/applications"
sudo mkdir -p "/usr/local/share/icons/hicolor/256x256/apps"
curl -L -o "$HOME/Downloads/discord.tar.gz" "https://discord.com/api/download?platform=linux&format=tar.gz"
sudo tar -xvf "$HOME/Downloads/discord.tar.gz" -C "/var/opt/discord/" --strip-components=1
ln -sf "/var/opt/discord/discord.png" "/usr/local/share/icons/hicolor/256x256/apps/discord.png"
sudo tee "/usr/local/share/applications/discord.desktop" > /dev/null <<'EOF'
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=/var/opt/discord/discord
Type=Application
Categories=Network;InstantMessaging;
Path=/var/opt/discord
EOF
sudo chmod +x "/usr/local/share/applications/discord.desktop"
sudo update-desktop-database "/usr/local/share/applications"
rm -f "$HOME/Downloads/discord.tar.gz"

# Enable devmode and aurora-cli
ujust aurora-cli
ujust devmode

# Enable kargs (last to minimise initramfs gens)
sudo tee "/etc/modprobe.d/i915.conf" > /dev/null <<'EOF'
options i915 enable_guc=2
options i915 enable_fbc=1
EOF
sudo rpm-ostree initramfs --enable --arg=-I --arg=/etc/modprobe.d/i915.conf

echo "Time to reboot for all changes to take effect!"