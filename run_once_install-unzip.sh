#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing unzip..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm unzip
else
    sudo apt install -y unzip
fi

echo "unzip installation complete!"
