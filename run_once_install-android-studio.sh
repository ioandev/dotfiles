#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

read -r -p "Install Android Studio? (~1.3GB download) [y/N] " response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Skipping Android Studio installation."
    exit 0
fi

echo "Installing Android Studio..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm android-studio
else
    sudo apt install -y wget
    wget -O /tmp/android-studio.tar.gz "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/latest/android-studio-latest-linux.tar.gz"
    sudo tar -xzf /tmp/android-studio.tar.gz -C /opt
    rm /tmp/android-studio.tar.gz
    sudo ln -sf /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio
fi

echo "Android Studio installation complete!"
