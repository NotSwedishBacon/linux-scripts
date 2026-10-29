#!/bin/bash

# Enable TMP2 unlocking
ujust toggle-tpm2

# Disable RAOP (Airplay)
sudo mkdir -p /etc/pipewire/pipewire.conf.d
sudo tee "/etc/pipewire/pipewire.conf.d/disable-raop.conf" > /dev/null <<'EOF'
context.properties = {
    module.raop = false
}
EOF
systemctl --user restart pipewire pipewire-pulse;

ujust aurora-cli

# Copy toml config
curl -sS https://raw.githubusercontent.com/NotSwedishBacon/linux-scripts/refs/heads/main/files/starship.toml -o ~/.config/starship.toml

# Uninstall flatpaks that are not relevant
flatpak uninstall --noninteractive --delete-data -y org.deskflow.deskflow &&
flatpak uninstall --noninteractive --delete-data -y org.fedoraproject.MediaWriter &&
flatpak uninstall --noninteractive --delete-data -y org.fkoehler.KTailctl &&
flatpak uninstall --noninteractive --delete-data -y org.gnome.DejaDup &&
flatpak uninstall --noninteractive --delete-data -y org.kde.qrca &&
flatpak uninstall --noninteractive --delete-data -y org.kde.kontact &&

# Install my flathub apps
flatpak install flathub --noninteractive -y io.github.shiftey.Desktop &&
flatpak install flathub --noninteractive -y com.prusa3d.PrusaSlicer &&
flatpak install flathub --noninteractive -y org.telegram.desktop &&
flatpak install flathub --noninteractive -y org.gimp.GIMP &&
flatpak install flathub --noninteractive -y org.inkscape.Inkscape &&
flatpak install flathub --noninteractive -y com.discordapp.Discord &&
flatpak install flathub --noninteractive -y org.libreoffice.LibreOffice  

# Auto start Discord
mkdir -p ~/.config/autostart
ln -s "$(flatpak info -l com.discordapp.Discord//stable | sed 's#/app/.*#/exports/share/applications/com.discordapp.Discord.desktop#')" ~/.config/autostart

# Fonts
brew tap colindean/fonts-nonfree && brew install --cask font-microsoft-office font-microsoft-aptos font-arial font-arial-black font-courier-new font-times-new-roman font-georgia

ujust devmode

echo "All done!"
