#!/bin/bash

set -e

echo "Installing and enabling Bluetooth..."
sudo apt install -y bluez bluez-tools
sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service

echo "Bluetooth setup complete!"
