#!/bin/bash

# Enable TMP2 unlocking
echo "Enable auto unlock" 
sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p3

# Disable RAOP (Airplay)
echo "Disabling Airplay"
sudo mkdir -p /etc/pipewire/pipewire.conf.d
sudo tee "/etc/pipewire/pipewire.conf.d/disable-raop.conf" > /dev/null <<'EOF'
context.properties = {
    module.raop = false
}
EOF
if [ $? -eq 0 ];
   then
      echo "[✓] SUCCESS"
   else
      echo "[✗] FAIL"
fi

# Restart PipeWire so it takes effect
echo "Restarting PipeWire services..."
if systemctl --user restart pipewire pipewire-pulse; then
  echo "[✓] SUCCESS"
else
  echo "[✗] FAIL"
fi

# Disable network wait service for faster boot times
echo "Disabling and masking NetworkManager-wait-online.service"
sudo systemctl disable "NetworkManager-wait-online.service"
sudo systemctl mask "NetworkManager-wait-online.service"
if [ $? -eq 0 ];
   then
      echo "[✓] SUCCESS"
   else
      echo "[✗] FAIL"
fi

# Add Flathub repository:
echo "Adding Flathub repository"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
if [ $? -eq 0 ];
   then
      echo "[✓] SUCCESS"
   else
      echo "[✗] FAIL"
fi

# Enable Flathub repository:
echo "Enabling Flathub repository"
sudo flatpak remote-modify --enable flathub
if [ $? -eq 0 ];
   then
      echo "[✓] SUCCESS"
   else
      echo "[✗] FAIL"
fi

# Remove all applications and runtimes:
echo "Removing all apps and runtimes"
sudo flatpak uninstall --all -y
if [ $? -eq 0 ];
   then
      echo "[✓] SUCCESS"
   else
      echo "[✗] FAIL"
fi

# Disable Fedora repository:
echo "Disabling Fedora repository"
sudo flatpak remote-delete fedora
if [ $? -eq 0 ];
   then
      echo "[✓] SUCCESS"
   else
      echo "[✗] FAIL"
fi

# Disable Fedora repository:
echo "Disabling Fedora-testing repository"
sudo flatpak remote-delete fedora-testing
if [ $? -eq 0 ];
   then
      echo "[✓] SUCCESS"
   else
      echo "[✗] FAIL"
fi

# Install back Fedora default applications from Flathub (minus games & remote desktop):
echo "Installing back apps from Flathub"
# KDE apps
flatpak install flathub -y org.kde.haruna &&
flatpak install flathub -y org.kde.gwenview &&
flatpak install flathub -y org.kde.kcalc &&
flatpak install flathub -y org.kde.okular &&
flatpak install flathub -y org.kde.skanpage &&
flatpak install flathub -y org.kde.kate &&
flatpak install flathub -y org.kde.ark &&
flatpak install flathub -y org.kde.krita &&
flatpak install flathub -y org.kde.kontact &&
# non KDE apps
flatpak install flathub -y com.github.tchx84.Flatseal &&
flatpak install flathub -y org.libreoffice.LibreOffice &&
flatpak install flathub -y io.missioncenter.MissionCenter &&
flatpak install flathub -y io.github.shiftey.Desktop &&
flatpak install flathub -y com.prusa3d.PrusaSlicer &&
flatpak install flathub -y org.telegram.desktop &&
flatpak install flathub -y org.mozilla.firefox

# Disable built-in firefox
sudo mkdir -p /usr/local/share/applications
sudo cp /usr/share/applications/org.mozilla.firefox.desktop /usr/local/share/applications/
sudo sed -i "2a\\NotShowIn=GNOME;KDE" /usr/local/share/applications/org.mozilla.firefox.desktop
sudo update-desktop-database /usr/local/share/applications/

# Install official Discord client 
echo "Starting Discord installation..."

# Create the target install directory for the Discord application files.
echo "Creating Discord install directory..."
sudo mkdir -p "/var/opt/discord"

# Create directories for the desktop entry.
sudo mkdir -p "/usr/local/share/applications"

# Download the Discord tarball into the Downloads folder.
echo "Downloading Discord tarball..."
curl -L -o "$HOME/Downloads/discord.tar.gz" "https://discord.com/api/download?platform=linux&format=tar.gz"

# Extract the downloaded Discord tarball into the install directory.
# The --strip-components=1 flag removes the top-level directory from the archive.
echo "Extracting Discord files..."
sudo tar -xvf "$HOME/Downloads/discord.tar.gz" -C "/var/opt/discord/" --strip-components=1

# Create a desktop entry so Discord appears in application menus.
echo "Creating Discord desktop entry..."
sudo tee "/usr/local/share/applications/discord.desktop" > /dev/null <<'EOF'
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=/var/opt/discord/discord
Icon=/var/opt/discord/discord.png
Type=Application
Categories=Network;InstantMessaging;
Path=/var/opt/discord
EOF

# Make sure the desktop entry file is executable.
sudo chmod +x "/usr/local/share/applications/discord.desktop"

# Update the desktop database so the new application entry is recognized.
update-desktop-database "/usr/local/share/applications"

# Remove the downloaded tarball from Downloads when done.
echo "Cleaning up downloaded files..."
rm -f "$HOME/Downloads/discord.tar.gz"

echo "Discord installation complete."

# Enable VS Code repo
echo "Installing VS Code Repo"
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Enable RPM-Fusion and install packages
echo "Enabling RPM-Fusion"
sudo rpm-ostree install -Ay https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo rpm-ostree install -y \
        intel-media-driver \
        fastfetch \
        code \
        glibc-langpack-sv \
        langpacks-sv \
        gstreamer1-plugin-libav \
        gstreamer1-plugins-bad-free-extras \
        gstreamer1-plugins-bad-freeworld \
        gstreamer1-plugins-ugly \
        gstreamer1-vaapi \
        --allow-inactive

sudo rpm-ostree override remove \
             fdk-aac-free \
             libavcodec-free \
             libavdevice-free \
             libavfilter-free \
             libavformat-free \
             libavutil-free \
             libswresample-free \
             libswscale-free \
             ffmpeg-free \
        --install ffmpeg

sudo rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release --install rpmfusion-free-release --install rpmfusion-nonfree-release

echo "RPM-Fusion is now installed"

# Enable kargs (last to minimise initramfs gens)
echo "Enabling GuC/HuC"
sudo tee "/etc/modprobe.d/i915.conf" > /dev/null <<'EOF'
options i915 enable_guc=2
options i915 enable_fbc=1
EOF

echo "Updating initramfs to include /etc/modprobe.d/i915.conf via rpm-ostree..."
sudo rpm-ostree initramfs --enable --arg=-I --arg=/etc/modprobe.d/i915.conf

echo "Time for a reboot!" 

# Keep terminal open after completion
echo "✂✂✂   Script ended   ✂✂✂"
read
