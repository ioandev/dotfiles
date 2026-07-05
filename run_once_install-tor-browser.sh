#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Tor Browser..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm torbrowser-launcher
else
    sudo apt update
    sudo apt install -y torbrowser-launcher
fi

echo "Tor Browser installation complete!"
