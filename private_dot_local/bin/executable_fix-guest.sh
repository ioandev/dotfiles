#!/bin/bash
# Reapply GNOME Boxes VM fixes that Boxes keeps reverting (see FIX-HOST-AMD.md):
#   - pin virgl rendernode to the dGPU (dual-GPU host -> corrupted 3D display otherwise)
#   - remove the USB tablet input (fixes cursor offset / double cursor in niri guest)
#   - DRM native context (blob + hostmem + memfd + qemu:override) - needs host kernel 6.13+
# Usage: fix-guest.sh [vm-name]
set -e

VM="${1:-manjaro-kde-2}"
RENDERNODE="/dev/dri/renderD128" # RX 7800 XT — the GPU driving the monitors
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

# Disable vmport (vmmouse absolute pointer forces client-mouse mode -> double cursor)
if ! grep -q "<vmport" "$TMP"; then
    sed -i "s|<acpi/>|<acpi/>\n    <vmport state='off'/>|" "$TMP"
fi

# Force server mouse mode (vdagent would switch to client mode -> double cursor;
# clipboard via vdagent is unaffected)
if ! grep -q "<mouse mode=" "$TMP"; then
    sed -i "s|<graphics type='spice'>|<graphics type='spice'>\n      <mouse mode='server'/>|" "$TMP"
fi

# DRM native context (idempotent: each piece added only if missing)
python3 - "$TMP" <<'EOF'
import sys, re
p = sys.argv[1]
x = open(p).read()
if "xmlns:qemu" not in x:
    x = x.replace("<domain type='kvm'>",
                  "<domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>", 1)
if "<memoryBacking>" not in x:
    x = re.sub(r"(</currentMemory>\n)", r"""\1  <memoryBacking>
    <source type='memfd'/>
    <access mode='shared'/>
  </memoryBacking>
""", x, count=1)
if "blob=" not in x:
    x = x.replace("<model type='virtio' heads='1' primary='yes'>",
                  "<model type='virtio' blob='on' heads='1' primary='yes'>", 1)
if "drm_native_context" not in x:
    x = x.replace("</domain>", """  <qemu:override>
    <qemu:device alias='video0'>
      <qemu:frontend>
        <qemu:property name='drm_native_context' type='bool' value='true'/>
        <qemu:property name='hostmem' type='unsigned' value='4294967296'/>
      </qemu:frontend>
    </qemu:device>
  </qemu:override>
</domain>""", 1)
open(p, "w").write(x)
EOF

virsh -c $URI define "$TMP"

echo "Now in config:"
grep "gl enable\|input type\|drm_native_context\|blob=" "$TMP" | sed 's/^ *//'

if [[ $was_running -eq 1 ]]; then
    virsh -c $URI start "$VM"
    echo "$VM restarted."
fi
