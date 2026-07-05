#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing GNOME Boxes..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm gnome-boxes
else
    sudo apt update
    sudo apt install -y gnome-boxes
fi

echo "GNOME Boxes installation complete!"
