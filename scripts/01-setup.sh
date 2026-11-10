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

# Install Starship prompt
curl -sS https://starship.rs/install.sh | sh
sudo tee "/etc/profile.d/90-starship.sh" > /dev/null <<'EOF'
# shellcheck shell=sh
command -v starship >/dev/null 2>&1 || return 0

if [ "$(basename "$(readlink /proc/$$/exe)")" = "bash" ]; then
  eval "$(starship init bash)"
fi
EOF

# Copy toml config
curl -sS https://raw.githubusercontent.com/NotSwedishBacon/linux-scripts/refs/heads/main/files/starship.toml -o ~/.config/starship.toml

# Download and install Noto Nerd Font
mkdir -p ~/.local/share/fonts/Noto
curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Noto.tar.xz | tar -xJ -C ~/.local/share/fonts/Noto
fc-cache -f ~/.local/share/fonts

# Setup flathub and remove fedora remotes
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable flathub
sudo flatpak uninstall --all -y --noninteractive 
sudo flatpak remote-delete fedora-testing
sudo flatpak remote-delete fedora

# Install my flathub apps
# KDE apps
flatpak install flathub -y --noninteractive org.kde.elisa &&
flatpak install flathub -y --noninteractive org.kde.gwenview &&
flatpak install flathub -y --noninteractive org.kde.kcalc &&
flatpak install flathub -y --noninteractive org.kde.okular &&
flatpak install flathub -y --noninteractive org.kde.skanpage &&
flatpak install flathub -y --noninteractive org.kde.krita &&
flatpak install flathub -y --noninteractive org.kde.kate &&
flatpak install flathub -y --noninteractive org.kde.kontact &&
flatpak install flathub -y --noninteractive org.kde.filelight &&
flatpak install flathub -y --noninteractive org.kde.ark &&
flatpak install flathub -y --noninteractive org.kde.kommit &&

# non KDE apps
flatpak install flathub -y --noninteractive com.bambulab.BambuStudio &&
flatpak install flathub -y --noninteractive org.telegram.desktop &&
flatpak install flathub -y --noninteractive org.mozilla.firefox &&
flatpak install flathub -y --noninteractive com.discordapp.Discord 

# Disable built-in firefox
sudo mkdir -p /usr/local/share/applications
sudo cp /usr/share/applications/org.mozilla.firefox.desktop /usr/local/share/applications/
sudo sed -i "2a\\NotShowIn=GNOME;KDE" /usr/local/share/applications/org.mozilla.firefox.desktop
sudo update-desktop-database /usr/local/share/applications/

# Install Sysexts
sudo install -d -m 0755 -o 0 -g 0 "/var/lib/extensions" "/var/lib/extensions.d"
sudo restorecon -RFv "/var/lib/extensions" "/var/lib/extensions.d"
sudo systemctl enable --now systemd-sysext.service

# Download Fedora sysexts
install_sysext() {
  SYSEXT="${1}"
  URL="https://extensions.fcos.fr/fedora"
  sudo install -d -m 0755 -o 0 -g 0 "/etc/sysupdate.${SYSEXT}.d"
  sudo restorecon -RFv "/etc/sysupdate.${SYSEXT}.d"
  curl --silent --fail --location "${URL}/${SYSEXT}.conf" \
    | sudo tee "/etc/sysupdate.${SYSEXT}.d/${SYSEXT}.transfer"
  sudo /usr/lib/systemd/systemd-sysupdate update --component "${SYSEXT}"
}

install_sysext btop 
install_sysext fastfetch 
install_sysext gh  
install_sysext git-lfs 
install_sysext htop 

# Download Community sysexts
install_sysext() {
  SYSEXT="${1}"
  URL="https://extensions.fcos.fr/community"
  sudo install -d -m 0755 -o 0 -g 0 "/etc/sysupdate.${SYSEXT}.d"
  sudo restorecon -RFv "/etc/sysupdate.${SYSEXT}.d"
  curl --silent --fail --location "${URL}/${SYSEXT}.conf" \
    | sudo tee "/etc/sysupdate.${SYSEXT}.d/${SYSEXT}.conf"
  sudo /usr/lib/systemd/systemd-sysupdate update --component "${SYSEXT}"
}

install_sysext bitwarden 
install_sysext nordvpn-gui 
install_sysext vscode 

#Enable all sysexts
sudo systemctl restart systemd-sysext.service
systemd-sysext status

# Auto start Discord
mkdir -p ~/.config/autostart
ln -s "$(flatpak info -l com.discordapp.Discord//stable | sed 's#/app/.*#/exports/share/applications/com.discordapp.Discord.desktop#')" ~/.config/autostart

echo "All done!"
