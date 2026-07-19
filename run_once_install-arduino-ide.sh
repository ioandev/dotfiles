#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Arduino IDE..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm arduino-ide-bin
    # Serial port access: uucp owns /dev/ttyUSB*, lock owns /run/lock
    sudo usermod -aG uucp,lock "$USER"
else
    ARDUINO_VERSION=$(curl -s https://api.github.com/repos/arduino/arduino-ide/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    wget -O /tmp/arduino-ide.AppImage "https://github.com/arduino/arduino-ide/releases/download/${ARDUINO_VERSION}/arduino-ide_${ARDUINO_VERSION}_Linux_64bit.AppImage"
    sudo install -m 755 /tmp/arduino-ide.AppImage /opt/arduino-ide.AppImage
    rm /tmp/arduino-ide.AppImage
    sudo ln -sf /opt/arduino-ide.AppImage /usr/local/bin/arduino-ide
    sudo usermod -aG dialout "$USER"
fi

echo "Arduino IDE installation complete!"
echo "Log out and back in for serial port group membership to take effect."
