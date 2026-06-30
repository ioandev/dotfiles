#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing ansible..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -Sy --noconfirm ansible
else
    sudo apt install -y ansible
fi

echo "ansible installation complete!"
