#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Obsidian..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm obsidian
else
    OBSIDIAN_VERSION=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    wget -O /tmp/obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION#v}_amd64.deb"
    sudo apt install -y /tmp/obsidian.deb
    rm /tmp/obsidian.deb
fi

echo "Obsidian installation complete!"
