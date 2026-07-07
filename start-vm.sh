#!/bin/bash
# Start the VM via virsh. Never start it from the Boxes UI - Boxes rewrites the
# domain XML and drops the rendernode pin and the drm_native_context override
# (see FIX-HOST-AMD.md).
set -e

VM="${1:-manjaro-kde-2}"
URI="qemu:///session"

state=$(virsh -c $URI domstate "$VM")
if [[ "$state" == "running" ]]; then
    echo "$VM already running."
    exit 0
fi

# 3D accel must stay on (niri guest requires it, see FIX-HOST-AMD.md).
# If Boxes clobbered any fix (rendernode pin, native context), restore all.
xml=$(virsh -c $URI dumpxml --inactive "$VM")
if ! grep -q "rendernode=" <<<"$xml" || ! grep -q "drm_native_context" <<<"$xml"; then
    echo "Config clobbered - reapplying fixes..."
    "$HOME/.local/bin/fix-guest.sh" "$VM"
fi

virsh -c $URI start "$VM"
sleep 2
echo "Video device:"
grep -o "virtio-vga[a-z-]*" "$HOME/.cache/libvirt/qemu/log/$VM.log" | tail -1
