#!/bin/bash
# Reapply GNOME Boxes VM fixes that Boxes keeps reverting (see FIX-HOST-AMD.md):
#   - pin virgl rendernode to the dGPU (dual-GPU host -> corrupted 3D display otherwise)
#   - remove the USB tablet input (fixes cursor offset / double cursor in niri guest)
# Usage: fix-guest.sh [vm-name]
set -e

VM="${1:-manjaro-kde-2}"
RENDERNODE="/dev/dri/renderD128" # RX 7700/7800 XT — the GPU driving the monitors
URI="qemu:///session"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

was_running=0
if [[ "$(virsh -c $URI domstate "$VM")" == "running" ]]; then
    was_running=1
    echo "Shutting down $VM..."
    virsh -c $URI shutdown "$VM"
    for _ in $(seq 1 45); do
        [[ "$(virsh -c $URI domstate "$VM")" == "shut off" ]] && break
        sleep 2
    done
    if [[ "$(virsh -c $URI domstate "$VM")" != "shut off" ]]; then
        echo "ERROR: $VM did not shut off in 90s; aborting." >&2
        exit 1
    fi
fi

virsh -c $URI dumpxml --inactive "$VM" >"$TMP"

# Pin rendernode (idempotent: only rewrites the bare <gl enable='yes'/>)
sed -i "s|<gl enable='yes'/>|<gl enable='yes' rendernode='$RENDERNODE'/>|" "$TMP"

# Drop USB tablet input, block or self-closing form
sed -i "/<input type='tablet' bus='usb'>/,/<\/input>/d" "$TMP"
sed -i "/<input type='tablet' bus='usb'\/>/d" "$TMP"

virsh -c $URI define "$TMP"

echo "Now in config:"
grep "gl enable\|input type" "$TMP" | sed 's/^ *//'

if [[ $was_running -eq 1 ]]; then
    virsh -c $URI start "$VM"
    echo "$VM restarted."
fi
