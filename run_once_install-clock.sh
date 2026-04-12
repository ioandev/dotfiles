#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing GNOME Clocks..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm gnome-clocks
else
    sudo apt install -y gnome-clocks
fi

echo "GNOME Clocks installation complete!"