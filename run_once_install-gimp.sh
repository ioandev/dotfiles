#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing GIMP..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm gimp
else
    sudo apt install -y gimp
fi

echo "GIMP installation complete!"
