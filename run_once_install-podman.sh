#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing podman..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm podman
else
    sudo apt install -y podman
fi

echo "podman installation complete!"
