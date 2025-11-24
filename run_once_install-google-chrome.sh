#!/bin/bash

set -e

echo "Installing Google Chrome..."

# Download Google Chrome .deb package
wget -O /tmp/google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Install Google Chrome
sudo apt install -y /tmp/google-chrome-stable.deb

# Clean up
rm /tmp/google-chrome-stable.deb

echo "Google Chrome installation complete!"
