#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Zellij..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm zellij
else
    sudo apt install -y zellij
fi

echo "Zellij installation complete!"
