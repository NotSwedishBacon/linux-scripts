#!/bin/bash

# Download the latest version of wonderbrushed from GitHub
echo "Downloading the latest version of wonderbrushed from GitHub"
cd "$HOME/Downloads"
curl -s https://api.github.com/repos/Bhavneeth-Games/Wonderbrushed/releases/latest \
| jq -r '.assets[] | select(.name == "Wonderbrushed.zip") | .browser_download_url' \
| xargs curl -LO

# Unzip the downloaded file
echo "Unzipping the downloaded file"
unzip "$HOME/Downloads/Wonderbrushed.zip" -d "$HOME/.local/share/icons"

# Remove the downloaded zip file
echo "Removing the downloaded zip file"
rm "$HOME/Downloads/Wonderbrushed.zip"