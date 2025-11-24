#!/bin/bash

set -e

echo "Installing Obsidian..."

# Download latest Obsidian .deb package
OBSIDIAN_VERSION=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
wget -O /tmp/obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION#v}_amd64.deb"

# Install Obsidian
sudo apt install -y /tmp/obsidian.deb

# Clean up
rm /tmp/obsidian.deb

echo "Obsidian installation complete!"
