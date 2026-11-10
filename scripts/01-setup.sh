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

# Set 20 downloads at a time
sudo sed -i -e '/^max_parallel_downloads/d' -e '/^\[main\]/a max_parallel_downloads=20' /etc/dnf/dnf.conf

# Remove crud
sudo dnf remove -y kmail kontact kpat kmines kmahjongg kolourpaint akregator krdc krfb neochat dragon elisa-player kamoso mediawriter qrca kmouth kleopatra korganizer kaddressbook

# Install basics
sudo dnf install -y kate thunderbird langpacks-sv krita

# Setup flathub and remove fedora remotes
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable flathub
sudo flatpak uninstall --all -y --noninteractive 
sudo flatpak remote-delete fedora-testing
sudo flatpak remote-delete fedora

# Install apps that must be a flatpak
flatpak install flathub -y --noninteractive com.bambulab.BambuStudio 

echo "All done!"
