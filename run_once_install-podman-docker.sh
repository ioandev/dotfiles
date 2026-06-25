#!/bin/bash

# podman-docker - provides a real /usr/bin/docker shim that calls podman.
# An `alias docker=podman` only exists in interactive shells, so installers
# that run `docker --version` in a non-interactive script won't see it.
# A real binary on PATH works everywhere.
set -e

. /etc/os-release 2>/dev/null || true

echo "Installing podman-docker..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm --needed podman podman-docker
else
    sudo apt install -y podman podman-docker
fi

echo "podman-docker installation complete! 'docker' now maps to podman."
