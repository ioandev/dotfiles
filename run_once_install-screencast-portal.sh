#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing screencast portal deps (OBS PipeWire capture on niri)..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm --needed \
        pipewire \
        wireplumber \
        xdg-desktop-portal \
        xdg-desktop-portal-gnome
else
    sudo apt install -y \
        pipewire \
        wireplumber \
        xdg-desktop-portal \
        xdg-desktop-portal-gnome
fi

echo "Screencast portal deps installed."
