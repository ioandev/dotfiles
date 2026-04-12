#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Discord..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm discord
else
    wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt update
    sudo apt install -y /tmp/discord.deb
    rm /tmp/discord.deb
fi

echo "Discord installation complete!"
