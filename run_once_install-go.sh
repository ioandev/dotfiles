#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Go..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm go
else
    sudo apt install -y golang-go
fi

export PATH="$PATH:$HOME/go/bin"

echo "Go installation complete!"
go version
