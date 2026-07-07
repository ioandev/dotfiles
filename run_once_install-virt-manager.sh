#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing virt-manager..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm virt-manager
else
    sudo apt update
    sudo apt install -y virt-manager
fi

echo "virt-manager installation complete!"
