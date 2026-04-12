#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing GitHub CLI..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm github-cli
else
    sudo apt install -y gh
fi

echo "GitHub CLI installation complete!"
