#!/bin/bash

set -e

echo "Installing DBeaver..."

# Download latest DBeaver .deb package
wget -O /tmp/dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb

# Install DBeaver
sudo apt install -y /tmp/dbeaver.deb

# Clean up
rm /tmp/dbeaver.deb

echo "DBeaver installation complete!"
