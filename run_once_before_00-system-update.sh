#!/bin/bash

set -e

echo "Updating apt package lists..."
sudo apt update

echo "Upgrading existing packages..."
sudo apt upgrade -y

echo "System update complete!"
