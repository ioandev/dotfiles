#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing VLC..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm vlc
else
    sudo apt install -y vlc
fi

echo "VLC installation complete!"
