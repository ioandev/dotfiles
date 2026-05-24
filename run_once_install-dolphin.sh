#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Dolphin..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm dolphin plasma-integration frameworkintegration kdegraphics-thumbnailers ffmpegthumbs

    # Disable pcmanfm daemon (claims FileManager1 D-Bus name, blocks Dolphin)
    systemctl --user disable --now pcmanfm.service || true

    # Remove GNOME portal backend (hangs outside GNOME session)
    sudo pacman -R --noconfirm xdg-desktop-portal-gnome || true

    # Set up portal config: use KDE for file chooser, gtk for everything else
    mkdir -p ~/.config/xdg-desktop-portal
    cat > ~/.config/xdg-desktop-portal/niri-portals.conf << 'EOF'
[preferred]
default=gtk
org.freedesktop.impl.portal.FileChooser=kde
EOF

    # Point FileManager1 D-Bus service to Dolphin (user-level override)
    mkdir -p ~/.local/share/dbus-1/services
    cp /usr/share/dbus-1/services/org.kde.dolphin.FileManager1.service \
       ~/.local/share/dbus-1/services/org.freedesktop.FileManager1.service

    # pcmanfm wrapper so Chrome's hardcoded fallback opens Dolphin instead
    sudo bash -c 'cat > /usr/local/bin/pcmanfm << "EOF"
#!/bin/bash
exec dolphin "$@"
EOF
chmod +x /usr/local/bin/pcmanfm'

    # Create applications.menu symlink for kbuildsycoca6
    sudo ln -sf /etc/xdg/menus/plasma-applications.menu /etc/xdg/menus/applications.menu
    kbuildsycoca6 || true

    # Set Dolphin as default file manager system-wide
    sudo sed -i 's|inode/directory=pcmanfm-qt.desktop|inode/directory=org.kde.dolphin.desktop|' \
        /usr/share/applications/mimeapps.list || true

    # Mask only GVFS services that cause D-state hangs (not udisks2 — portal needs it)
    systemctl --user mask gvfs-daemon.service gvfs-metadata.service || true

    # Start Dolphin daemon (registers FileManager1 D-Bus name)
    dolphin --daemon &

    # Restart portal services to pick up new config
    systemctl --user restart xdg-desktop-portal xdg-desktop-portal-gtk \
        plasma-xdg-desktop-portal-kde.service || true

else
    sudo apt install -y dolphin
fi

xdg-mime default org.kde.dolphin.desktop inode/directory
echo "Dolphin installation complete!"
