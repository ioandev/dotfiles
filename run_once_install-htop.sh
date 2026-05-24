#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing htop..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm htop
else
    sudo apt install -y htop
fi

echo "htop installation complete!"
