#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing python3 and pip..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm python python-pip
else
    sudo apt install -y python3 python3-pip
fi

echo "python3 and pip installation complete!"
