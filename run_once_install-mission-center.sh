#!/bin/bash

set -e

echo "Installing Mission Center via Flatpak..."

# Ensure flatpak is installed
sudo apt install -y flatpak

# Add Flathub repository if not already added
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Mission Center
flatpak install -y flathub io.missioncenter.MissionCenter

echo "Mission Center installation complete!"
