#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing OBS Studio..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm obs-studio
else
    sudo apt install -y obs-studio
fi

echo "OBS Studio installation complete!"
