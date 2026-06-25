#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing VLC..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm --needed vlc ffmpeg gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly x264 x265
else
    sudo apt install -y vlc vlc-plugin-base vlc-plugin-video-output ffmpeg
fi

echo "VLC installation complete!"
