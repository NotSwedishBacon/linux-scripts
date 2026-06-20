#!/bin/bash

# Enable TMP2 unlocking
sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p3

# Disable RAOP (Airplay)
sudo mkdir -p /etc/pipewire/pipewire.conf.d
sudo tee "/etc/pipewire/pipewire.conf.d/disable-raop.conf" > /dev/null <<'EOF'
context.properties = {
    module.raop = false
}
EOF
systemctl --user restart pipewire pipewire-pulse;

# Setup flathub and remove fedora remotes
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable flathub
sudo flatpak uninstall --all -y
sudo flatpak remote-delete fedora
sudo flatpak remote-delete fedora-testing

# Install my flathub apps
# KDE apps
flatpak install flathub -y org.kde.elisa &&
flatpak install flathub -y org.kde.gwenview &&
flatpak install flathub -y org.kde.kcalc &&
flatpak install flathub -y org.kde.okular &&
flatpak install flathub -y org.kde.skanpage &&
flatpak install flathub -y org.kde.krita &&
flatpak install flathub -y org.kde.kate &&
flatpak install flathub -y org.kde.haruna &&
# non KDE apps
flatpak install flathub -y org.libreoffice.LibreOffice &&
flatpak install flathub -y io.github.shiftey.Desktop &&
flatpak install flathub -y com.prusa3d.PrusaSlicer &&
flatpak install flathub -y org.telegram.desktop &&
flatpak install flathub -y org.mozilla.firefox &&
flatpak install flathub -y org.mozilla.Thunderbird 

# Disable built-in firefox
sudo mkdir -p /usr/local/share/applications
sudo cp /usr/share/applications/org.mozilla.firefox.desktop /usr/local/share/applications/
sudo sed -i "2a\\NotShowIn=GNOME;KDE" /usr/local/share/applications/org.mozilla.firefox.desktop
sudo update-desktop-database /usr/local/share/applications/

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

# Install Sysexts Manager for easier management of system extensions
# get the latest version number from github
VERSION=$(curl -s https://api.github.com/repos/travier/sysexts-manager/releases/latest \
  | jq -r '.body' \
  | grep -o 'sysexts-manager-.*-x86-64\.raw' \
  | tail -n 1 \
  | sed -E 's/sysexts-manager-([0-9.]+)-.*/\1/')
VERSION_ID="$(rpm -E %fedora)" # Fedora release
ARCH="x86-64"   # or arm64
URL="https://github.com/travier/sysexts-manager/releases/download/sysexts-manager/"
NAME="sysexts-manager-${VERSION}-${VERSION_ID}-${ARCH}.raw"
sudo install -d -m 0755 -o 0 -g 0 "/var/lib/extensions"{,.d} "/run/extensions"
curl --silent --fail --location "${URL}/${NAME}" \
    | sudo bash -c "cat > /var/lib/extensions.d/${NAME}"
sudo ln -snf "/var/lib/extensions.d/${NAME}" "/var/lib/extensions/sysexts-manager.raw"
sudo restorecon -RFv "/var/lib/extensions"{,.d} "/run/extensions"
sudo systemctl enable systemd-sysext.service
sudo systemctl restart systemd-sysext.service
sudo sysexts-manager add fastfetch https://extensions.fcos.fr/fedora &&
sudo sysexts-manager add vscode https://extensions.fcos.fr/community &&
sudo sysexts-manager update &&
sudo sysexts-manager enable fastfetch &&
sudo sysexts-manager enable vscode &&
sudo sysexts-manager refresh

# Add update command alias to .bashrc
if ! grep -qxF "alias updext='sudo sysexts-manager update && sudo sysexts-manager refresh'" "$HOME/.bashrc"; then
    printf "%s\n" "alias updext='sudo sysexts-manager update && sudo sysexts-manager refresh'" >> "$HOME/.bashrc"
fi

# Enable auto updates
sudo sed -i 's/^#\?AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf
sudo rpm-ostree reload
sudo systemctl enable --now rpm-ostreed-automatic.timer

# Enable kargs (last to minimise initramfs gens)
sudo tee "/etc/modprobe.d/i915.conf" > /dev/null <<'EOF'
options i915 enable_guc=2
options i915 enable_fbc=1
EOF
sudo rpm-ostree initramfs --enable --arg=-I --arg=/etc/modprobe.d/i915.conf

echo "Time to reboot for all changes to take effect!"