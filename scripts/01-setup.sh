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

# Enable RPM Fusion (free and nonfree)
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
sudo dnf install -y rpmfusion-\*-appstream-data

# Setup multimedia and recent Intel iGPU hardware acceleration
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf install -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf install -y mesa-vulkan-drivers vulkan-loader mesa-libGLU libva-utils ffmpeg-libs libva intel-media-driver

# Install apps
sudo dnf install -y discord telegram-desktop kate thunderbird langpacks-sv krita

# Setup flathub and remove fedora remotes
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable flathub
sudo flatpak uninstall --all -y --noninteractive 
sudo flatpak remote-delete fedora-testing
sudo flatpak remote-delete fedora

# Install apps that must be a flatpak
flatpak install flathub -y --noninteractive com.bambulab.BambuStudio 

echo "All done!"
