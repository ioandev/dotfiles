#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing screenshot tools (grim, slurp, wl-clipboard, swappy)..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm grim slurp wl-clipboard swappy
else
    sudo apt install -y grim slurp wl-clipboard swappy
fi

echo "Screenshot tools installation complete!"
