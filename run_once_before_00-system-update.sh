#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    echo "Updating system packages (pacman)..."
    sudo pacman -Syu --noconfirm --ask 4 --ignore android-studio
    paru -Syu --ignore android-studio
else
    echo "Updating apt package lists..."
    sudo apt update
    echo "Upgrading existing packages..."
    sudo apt upgrade -y
fi

echo "System update complete!"
