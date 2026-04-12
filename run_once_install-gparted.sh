#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing GParted..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm gparted
else
    sudo apt install -y gparted
fi

echo "GParted installation complete!"
