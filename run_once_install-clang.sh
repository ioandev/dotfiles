#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Clang..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm clang
else
    sudo apt install -y clang
fi

echo "Clang installation complete!"
