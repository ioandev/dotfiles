#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing redis-cli..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm redis
else
    sudo apt install -y redis-tools
fi

echo "redis-cli installation complete!"
