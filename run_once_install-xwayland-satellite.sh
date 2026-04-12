#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing xwayland-satellite..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm xwayland-satellite
else
    sudo apt install -y xwayland-satellite
fi

echo "xwayland-satellite installation complete!"
