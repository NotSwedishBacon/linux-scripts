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

# Download and install AdwaitaMono Nerd Font
mkdir -p ~/.local/share/fonts/Noto
curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Noto.tar.xz | tar -xJ -C ~/.local/share/fonts/Noto
fc-cache -f ~/.local/share/fonts

# Install Homebrew
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -d "/home/linuxbrew/.linuxbrew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

sudo tee "/etc/profile.d/91-homebrew.sh" > /dev/null <<'EOF'
# shellcheck shell=sh
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
EOF

# Tap ublue-os/tap
brew tap ublue-os/tap
brew trust ublue-os/tap

# Install brew packages
brew install antigravity-linux
brew install visual-studio-code-linux

# Setup flathub and remove fedora remotes
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable flathub
sudo flatpak uninstall --all -y
sudo flatpak remote-delete fedora-testing
sudo flatpak remote-delete fedora

# Install my flathub apps
# KDE apps
flatpak install flathub -y org.kde.elisa &&
flatpak install flathub -y org.kde.gwenview &&
flatpak install flathub -y org.kde.kcalc &&
flatpak install flathub -y org.kde.kolourpaint &&
flatpak install flathub -y org.kde.okular &&
flatpak install flathub -y org.kde.skanpage &&

# Non KDE apps
flatpak install flathub -y io.github.shiftey.Desktop &&
flatpak install flathub -y com.prusa3d.PrusaSlicer &&
flatpak install flathub -y com.bambulab.BambuStudio &&
flatpak install flathub -y org.telegram.desktop &&
flatpak install flathub -y org.gimp.GIMP &&
flatpak install flathub -y org.inkscape.Inkscape &&
flatpak install flathub -y org.mozilla.firefox &&
flatpak install flathub -y org.mozilla.thunderbird &&
flatpak install flathub -y io.missioncenter.MissionCenter &&
flatpak install flathub -y io.github.flattool.Warehouse &&
flatpak install flathub -y com.github.tchx84.Flatseal &&
flatpak install flathub -y com.discordapp.Discord &&
flatpak install flathub -y org.libreoffice.LibreOffice  

# Disable built-in firefox
sudo mkdir -p /usr/local/share/applications
sudo cp /usr/share/applications/org.mozilla.firefox.desktop /usr/local/share/applications/
sudo sed -i "2a\\NotShowIn=GNOME;KDE" /usr/local/share/applications/org.mozilla.firefox.desktop
sudo update-desktop-database /usr/local/share/applications/

# Auto start Discord
mkdir -p ~/.config/autostart
ln -s "$(flatpak info -l com.discordapp.Discord//stable | sed 's#/app/.*#/exports/share/applications/com.discordapp.Discord.desktop#')" ~/.config/autostart

echo "All done!"
