#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Podman and Podman Compose..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm podman podman-compose
else
    sudo apt install -y podman podman-compose
fi

echo "Podman installation complete!"
