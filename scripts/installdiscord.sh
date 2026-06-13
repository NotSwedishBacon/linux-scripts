#!/bin/bash

echo "Starting Discord installation..."

# Create the target install directory for the Discord application files.
echo "Creating Discord install directory..."
mkdir -p "$HOME/.local/share/discord"

# Create directories for the application icon and desktop entry.
mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
mkdir -p "$HOME/.local/share/applications"

# Download the Discord tarball into the Downloads folder.
echo "Downloading Discord tarball..."
curl -L -o "$HOME/Downloads/discord.tar.gz" "https://discord.com/api/download?platform=linux&format=tar.gz"

# Extract the downloaded Discord tarball into the install directory.
# The --strip-components=1 flag removes the top-level directory from the archive.
echo "Extracting Discord files..."
tar -xvf "$HOME/Downloads/discord.tar.gz" -C "$HOME/.local/share/discord/" --strip-components=1

# Create or update a symlink for the Discord icon in the standard icon theme path.
ln -sf "$HOME/.local/share/discord/discord.png" "$HOME/.local/share/icons/hicolor/256x256/apps/discord.png"

# Create a desktop entry so Discord appears in application menus.
echo "Creating Discord desktop entry..."
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

# Make sure the desktop entry file is executable.
chmod +x "$HOME/.local/share/applications/discord.desktop"

# Update the desktop database so the new application entry is recognized.
update-desktop-database "$HOME/.local/share/applications"

# Remove the downloaded tarball from Downloads when done.
echo "Cleaning up downloaded files..."
rm -f "$HOME/Downloads/discord.tar.gz"

echo "Discord installation complete."
