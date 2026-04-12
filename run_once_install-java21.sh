#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing JDK 21 OpenJDK..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm jdk21-openjdk
    sudo archlinux-java set java-21-openjdk
else
    sudo apt install -y openjdk-21-jdk
    sudo update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java
fi

echo "JDK 21 OpenJDK installation complete!"
