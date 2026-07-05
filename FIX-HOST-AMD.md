# Fix: GNOME Boxes 3D acceleration shows corrupted noise (dual AMD GPU host)

## Symptom

Enabling 3D acceleration on a GNOME Boxes VM makes the whole guest display render as glitched vertical stripes of colored noise — from boot, before the guest even loads drivers.

## Cause

Host has two AMD GPUs (e.g. Radeon RX 7700/7800 XT dGPU + Ryzen "Granite Ridge" iGPU), so two DRM render nodes exist:

```bash
ls -l /dev/dri/by-path/
# pci-0000:03:00.0-render -> ../renderD128   (dGPU)
# pci-0000:75:00.0-render -> ../renderD129   (iGPU)
```

Boxes writes `<gl enable='yes'/>` into the domain XML **without a rendernode**, and libvirt auto-picks one at VM start — it can pick the iGPU. The guest's frames then get rendered by virgl on the iGPU while the Boxes window is composited on the dGPU (the one driving the monitors). Cross-GPU dmabuf sharing produces garbage.

## Diagnose

```bash
# which node virgl actually got (live XML, VM running):
virsh -c qemu:///session dumpxml <vm> | grep "gl enable"
#   <gl enable='yes' rendernode='/dev/dri/renderD129'/>   <- iGPU = wrong

# map render nodes to GPUs:
ls -l /dev/dri/by-path/
lspci | grep -i vga
```

Boxes VMs live on the **session** libvirt daemon: always use `-c qemu:///session`. The Boxes UI title (e.g. "Aristotle") can differ from the libvirt domain name — find the real name with `virsh -c qemu:///session list --all`.

## Fix

Pin the rendernode to the dGPU (the GPU driving the displays) in the persistent config:

```bash
virsh -c qemu:///session dumpxml --inactive <vm> > /tmp/vm.xml
sed -i "s|<gl enable='yes'/>|<gl enable='yes' rendernode='/dev/dri/renderD128'/>|" /tmp/vm.xml
virsh -c qemu:///session define /tmp/vm.xml
```

Then **fully shut down** the VM (guest reboot is not enough — the QEMU process must restart) and start it again from Boxes.

## Caveats

- Toggling the 3D acceleration switch in the Boxes UI may rewrite the `<graphics>` block and drop the rendernode — re-apply the fix if corruption returns after touching that toggle.
- If it's still corrupt on the correct rendernode: suspect a guest mesa too old for the host's virglrenderer, or a virgl bug on RDNA3. Test the guest with 3D off (llvmpipe) to confirm the pipeline otherwise works.
