#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing EasyEffects..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm easyeffects lsp-plugins calf
else
    sudo apt install -y easyeffects lsp-plugins calf-plugins
fi

echo "EasyEffects installation complete!"
