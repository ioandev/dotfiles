#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing apache2-utils..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm apache
else
    sudo apt install -y apache2-utils
fi

echo "apache2-utils installed successfully."
