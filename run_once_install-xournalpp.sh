#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Xournal++..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm xournalpp
else
    sudo apt install -y xournalpp
fi

echo "Xournal++ installation complete!"
