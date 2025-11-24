#!/bin/bash

set -e

echo "Installing Discord..."

# Download Discord .deb package
wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"

# Install Discord
sudo apt update
sudo apt install -y /tmp/discord.deb

# Clean up
rm /tmp/discord.deb

echo "Discord installation complete!"
