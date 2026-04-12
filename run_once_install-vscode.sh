#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Visual Studio Code..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm visual-studio-code-bin
else
    sudo apt install -y code
fi

echo "Visual Studio Code installation complete!"
