#!/bin/bash

# zip/unzip archive tools
set -e

. /etc/os-release 2>/dev/null || true

echo "Installing zip..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm --needed zip unzip
else
    sudo apt install -y zip unzip
fi

echo "zip installation complete!"
