#!/bin/bash

set -e

echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "Tailscale installation complete!"
echo ""
echo "NOTE: Run 'sudo tailscale up' to authenticate and connect to your Tailscale network."
