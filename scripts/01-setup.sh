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

# Install Distrobox
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh

# Download and install AdwaitaMono Nerd Font
mkdir -p ~/.local/share/fonts/AdwaitaMono
curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/AdwaitaMono.tar.xz | tar -xJ -C ~/.local/share/fonts/AdwaitaMono
fc-cache -f ~/.local/share/fonts

# Setup flathub and remove fedora remotes
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable flathub
sudo flatpak uninstall --all -y --noninteractive 
sudo flatpak remote-delete fedora-testing
sudo flatpak remote-delete fedora

# Install my flathub apps
# Gnome apps
flatpak install flathub -y --noninteractive org.gnome.Calculator &&
flatpak install flathub -y --noninteractive org.gnome.Calendar &&
flatpak install flathub -y --noninteractive org.gnome.TextEditor &&
flatpak install flathub -y --noninteractive org.gnome.Loupe &&
flatpak install flathub -y --noninteractive org.gnome.Logs &&
flatpak install flathub -y --noninteractive org.gnome.NautilusPreviewer &&
flatpak install flathub -y --noninteractive org.gnome.Papers &&
flatpak install flathub -y --noninteractive org.gnome.Weather &&
flatpak install flathub -y --noninteractive org.gnome.Showtime &&
flatpak install flathub -y --noninteractive org.gnome.Snapshot &&
flatpak install flathub -y --noninteractive org.gnome.baobab &&
flatpak install flathub -y --noninteractive org.gnome.SimpleScan &&
flatpak install flathub -y --noninteractive org.gnome.clocks &&
flatpak install flathub -y --noninteractive org.gnome.Maps &&
flatpak install flathub -y --noninteractive org.gnome.Contacts &&
flatpak install flathub -y --noninteractive org.gnome.Decibels &&
flatpak install flathub -y --noninteractive org.gnome.font-viewer &&
flatpak install flathub -y --noninteractive org.gnome.Characters &&

# non gnome apps
flatpak install flathub -y --noninteractive com.mattjakeman.ExtensionManager &&
flatpak install flathub -y --noninteractive io.github.shiftey.Desktop &&
flatpak install flathub -y --noninteractive com.bambulab.BambuStudio &&
flatpak install flathub -y --noninteractive org.telegram.desktop &&
flatpak install flathub -y --noninteractive org.gimp.GIMP &&
flatpak install flathub -y --noninteractive org.inkscape.Inkscape &&
flatpak install flathub -y --noninteractive org.mozilla.firefox &&
flatpak install flathub -y --noninteractive org.mozilla.thunderbird &&
flatpak install flathub -y --noninteractive io.missioncenter.MissionCenter &&
flatpak install flathub -y --noninteractive io.github.flattool.Warehouse &&
flatpak install flathub -y --noninteractive com.github.tchx84.Flatseal &&
flatpak install flathub -y --noninteractive com.discordapp.Discord &&
flatpak install flathub -y --noninteractive org.libreoffice.LibreOffice && 
flatpak install flathub -y --noninteractive com.visualstudio.code &&
flatpak install flathub -y --noninteractive com.ranfdev.DistroShelf

# Allow VS Code to connect to a devcontainer
# Read https://distrobox.it/posts/integrate_vscode_distrobox/
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/podman-host -o ~/.local/bin/podman-host
chmod +x ~/.local/bin/podman-host

# Disable built-in firefox
sudo mkdir -p /usr/local/share/applications
sudo cp /usr/share/applications/org.mozilla.firefox.desktop /usr/local/share/applications/
sudo sed -i "2a\\NotShowIn=GNOME;KDE" /usr/local/share/applications/org.mozilla.firefox.desktop
sudo update-desktop-database /usr/local/share/applications/

# Auto start Discord
mkdir -p ~/.config/autostart
ln -s "$(flatpak info -l com.discordapp.Discord//stable | sed 's#/app/.*#/exports/share/applications/com.discordapp.Discord.desktop#')" ~/.config/autostart

# Disable nag
gsettings set org.gnome.settings-daemon.plugins.housekeeping donation-reminder-enabled false

# personal settings
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.calendar show-weekdate true

echo "All done!"
