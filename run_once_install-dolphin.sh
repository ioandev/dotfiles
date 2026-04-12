#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Dolphin..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm dolphin plasma-integration frameworkintegration kdegraphics-thumbnailers ffmpegthumbs
    systemctl --user enable --now baloo_file
    systemctl --user mask gvfs-daemon.service gvfs-metadata.service gvfs-udisks2-volume-monitor.service
    sudo ln -s /etc/xdg/menus/plasma-applications.menu /etc/xdg/menus/applications.menu
    kbuildsycoca6
    sudo sed -i 's|inode/directory=pcmanfm-qt.desktop|inode/directory=org.kde.dolphin.desktop|' /usr/share/applications/mimeapps.list

    #sudo bash -c 'cat > /usr/local/bin/pcmanfm-qt << "EOF"
    ##!/bin/bash
    #echo "pcmanfm-qt called with: $@" >> /tmp/filemanager-calls.log
    #exec dolphin "$@"
    #EOF
    #chmod +x /usr/local/bin/pcmanfm-qt'
    #sudo cp /tmp/pcmanfm-wrapper /usr/local/bin/pcmanfm && sudo chmod +x /usr/local/bin/pcmanfm
#
    #mkdir -p ~/.local/share/dbus-1/services
    #cp /usr/share/dbus-1/services/org.kde.dolphin.FileManager1.service ~/.local/share/dbus-1/services/org.freedesktop.FileManager1.service

    systemctl --user disable --now pcmanfm.service

    sudo pacman -R xdg-desktop-portal-gnome

    systemctl --user restart xdg-desktop-portal xdg-desktop-portal-gtk

    systemctl --user unmask gvfs-udisks2-volume-monitor.service
     systemctl --user restart xdg-desktop-portal-gtk

else
    sudo apt install -y dolphin
fi
xdg-mime default org.kde.dolphin.desktop inode/directory
echo "Dolphin installation complete!"
