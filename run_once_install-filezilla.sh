#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Filezilla..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm filezilla
else
    sudo apt install -y filezilla
fi

echo "Filezilla installation complete!"
