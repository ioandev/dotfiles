#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Steam..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm steam
else
    sudo apt install -y steam
fi

echo "Steam installation complete!"
