#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing FSearch..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm fsearch-git
else
    echo "Installing FSearch dependencies..."
    sudo apt install -y git build-essential meson itstool libtool pkg-config intltool libicu-dev libpcre2-dev libglib2.0-dev libgtk-3-dev libxml2-utils

    echo "Cloning FSearch repository..."
    cd /tmp
    rm -rf fsearch
    git clone https://github.com/cboxdoerfer/fsearch.git
    cd fsearch

    echo "Building FSearch..."
    meson builddir
    ninja -C builddir install

    echo "Cleaning up..."
    cd /tmp
    rm -rf fsearch
fi

echo "FSearch installation complete!"
