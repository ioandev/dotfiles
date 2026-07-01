#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing yq..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm yq
else
    sudo apt install -y yq
fi

echo "yq installation complete!"
