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

# non KDE apps
flatpak install flathub -y io.github.shiftey.Desktop &&
flatpak install flathub -y com.prusa3d.PrusaSlicer &&
flatpak install flathub -y org.telegram.desktop &&
flatpak install flathub -y org.mozilla.firefox &&
flatpak install flathub -y org.mozilla.thunderbird 

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

# Setup custom toolbox container 
podman build --squash -t localhost/apps-toolbox:latest ../toolbox
toolbox create -i localhost/apps-toolbox:latest apps-toolbox

# Setup toolbox-export script
curl https://raw.githubusercontent.com/mrvladus/toolbox-export/main/toolbox-export.py --create-dirs -o ~/.local/bin/toolbox-export && chmod +x ~/.local/bin/toolbox-export

toolbox run -c apps-toolbox cat << EOF | sudo tee /usr/local/bin/xdg-open
#!/bin/sh
exec flatpak-spawn --host -- xdg-open \$@
EOF
toolbox run -c apps-toolbox sudo chmod +x /usr/local/bin/xdg-open

toolbox run -c apps-toolbox cp /usr/share/applications/code.desktop /usr/share/applications/code-url-handler.desktop ~/.local/share/applications/
TOOLBOX_NAME=$(cat /run/.containerenv | grep 'name=' | sed -e 's/^name="\(.*\)"$/\1/')
toolbox run -c apps-toolbox sed -i "s/Exec=\/usr\/share\/code\/code/Exec=\/usr\/bin\/toolbox run -c \"$TOOLBOX_NAME\" code/g" ~/.local/share/applications/code.desktop ~/.local/share/applications/code-url-handler.desktop

# Enter toolbox and install apps
toolbox run -c apps-toolbox toolbox-export Z-Library

echo "All done!"
