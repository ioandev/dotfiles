#!/bin/bash

set -e

echo "Configuring Podman container registries..."

# Add unqualified-search-registries to registries.conf
sudo tee -a /etc/containers/registries.conf << 'EOF'

unqualified-search-registries = ["docker.io"]
EOF

echo "Podman registries configured successfully."

# Restart podman if it's running
if systemctl --user is-active --quiet podman.socket 2>/dev/null; then
    echo "Restarting Podman socket..."
    systemctl --user restart podman.socket
fi

echo "Done. You may need to restart any running Podman containers for changes to take effect."
