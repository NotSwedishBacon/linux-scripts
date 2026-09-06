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
flatpak install flathub -y org.kde.gwenview &&
flatpak install flathub -y org.kde.kcalc &&
flatpak install flathub -y org.kde.okular &&
flatpak install flathub -y org.kde.skanpage &&
flatpak install flathub -y org.kde.krita &&
flatpak install flathub -y org.kde.kate &&

# non gnome apps
flatpak install flathub -y io.github.shiftey.Desktop &&
flatpak install flathub -y com.prusa3d.PrusaSlicer &&
flatpak install flathub -y org.telegram.desktop &&
flatpak install flathub -y org.gimp.GIMP &&
flatpak install flathub -y org.inkscape.Inkscape &&
flatpak install flathub -y org.mozilla.firefox &&
flatpak install flathub -y org.mozilla.thunderbird &&
flatpak install flathub -y io.missioncenter.MissionCenter &&
flatpak install flathub -y io.github.flattool.Warehouse &&
flatpak install flathub -y com.github.tchx84.Flatseal &&
flatpak install flathub -y io.podman_desktop.PodmanDesktop &&
flatpak install flathub -y io.github.DenysMb.Kontainer &&
flatpak install flathub -y com.discordapp.Discord &&
flatpak install flathub -y org.libreoffice.LibreOffice

# Disable built-in firefox
sudo mkdir -p /usr/local/share/applications
sudo cp /usr/share/applications/org.mozilla.firefox.desktop /usr/local/share/applications/
sudo sed -i "2a\\NotShowIn=GNOME;KDE" /usr/local/share/applications/org.mozilla.firefox.desktop
sudo update-desktop-database /usr/local/share/applications/

# Install Distrobox
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local

echo "All done!"
