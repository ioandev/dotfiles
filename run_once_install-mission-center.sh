#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Mission Center..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm mission-center
else
    # Install via Flatpak on Debian-based systems
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub io.missioncenter.MissionCenter
fi

echo "Mission Center installation complete!"
