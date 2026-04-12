#!/bin/bash

. /etc/os-release 2>/dev/null || true

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm libsoup3 webkit2gtk-4.1 pkgconf
else
    sudo apt-get install -y libsoup-3.0-dev libjavascriptcoregtk-4.1-dev libwebkit2gtk-4.1-dev pkg-config
fi

echo "libsoup-3.0, javascriptcoregtk-4.1, and webkit2gtk-4.1 development packages installed successfully"
