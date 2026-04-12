#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Filelight..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm filelight
else
    sudo apt install -y filelight
fi

echo "Filelight installation complete!"
