#!/bin/bash

# Gnome minimise and maximise buttons
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

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
# Gnome apps
flatpak install flathub -y org.gnome.Calculator &&
flatpak install flathub -y org.gnome.Calendar &&
flatpak install flathub -y org.gnome.Extensions &&
flatpak install flathub -y org.gnome.TextEditor &&
flatpak install flathub -y org.gnome.Loupe &&
flatpak install flathub -y org.gnome.Logs &&
flatpak install flathub -y org.gnome.NautilusPreviewer &&
flatpak install flathub -y org.gnome.Papers &&
flatpak install flathub -y org.gnome.Weather &&
# non gnome apps
flatpak install flathub -y io.github.shiftey.Desktop &&
flatpak install flathub -y com.prusa3d.PrusaSlicer &&
flatpak install flathub -y org.telegram.desktop &&
flatpak install flathub -y org.gimp.GIMP &&
flatpak install flathub -y org.inkscape.Inkscape &&
flatpak install flathub -y org.mozilla.firefox &&
flatpak install flathub -y org.mozilla.thunderbird 

# Disable built-in firefox
sudo mkdir -p /usr/local/share/applications
sudo cp /usr/share/applications/org.mozilla.firefox.desktop /usr/local/share/applications/
sudo sed -i "2a\\NotShowIn=GNOME;KDE" /usr/local/share/applications/org.mozilla.firefox.desktop
sudo update-desktop-database /usr/local/share/applications/

# Setup custom toolbox container 
podman build --squash -t localhost/apps-toolbox:latest ../toolbox/Containerfile
toolbox create -i localhost/apps-toolbox:latest apps-toolbox

# Setup toolbox-export script
curl https://raw.githubusercontent.com/NotSwedishBacon/linux-scripts/main/scripts/toolbox-export.py --create-dirs -o ~/.local/bin/toolbox-export && chmod +x ~/.local/bin/toolbox-export

# Ensure local directories exist
mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.local/share/icons"

# Enter toolbox and install apps
toolbox run -c apps-toolbox toolbox-export code
toolbox run -c apps-toolbox toolbox-export discord
toolbox run -c apps-toolbox toolbox-export Z-Library

echo "All done!"
