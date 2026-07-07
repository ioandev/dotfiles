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

## Script

`~/.local/bin/fix-guest.sh [vm-name]` (chezmoi-managed: `private_dot_local/bin/executable_fix-guest.sh`) applies both fixes — rendernode pin **and** USB tablet removal (cursor offset fix) — shutting down and restarting the VM if it was running. Boxes reverts the `<graphics>` block whenever it rewrites the domain XML, so rerun the script after touching VM settings in the Boxes UI.

## Caveats

- Toggling the 3D acceleration switch in the Boxes UI may rewrite the `<graphics>` block and drop the rendernode — re-apply the fix if corruption returns after touching that toggle.
- If it's still corrupt on the correct rendernode: suspect a guest mesa too old for the host's virglrenderer, or a virgl bug on RDNA3. Test the guest with 3D off (llvmpipe) to confirm the pipeline otherwise works.
- virgl on RDNA3 occasionally crashes the whole VM (host `amdgpu: [gfxhub] page fault ... in process qemu-system-x86` → `ring gfx timeout, soft recovered` → QEMU GL context lost → domain "crashed"). Known virglrenderer/radeonsi bug; nothing host-config can do. Restart via `start-vm.sh`.
- **3D acceleration must stay ON for a niri guest.** Tried disabling it (2026-07-07) to stop the virgl crashes: niri's DRM backend cannot open the GL-less virtio-vga device (`error adding device: Failed to open device: Invalid argument`, `Error::DeviceMissing`) — black screen, no outputs. No software-rendering fallback in niri's tty backend. So: 3D on + rendernode pin + accept the occasional virgl crash.
- **DRM native context: tried and failed on host kernel 6.12** (2026-07-06, qemu 11.0 / virglrenderer 1.3): dies at boot with `kvm run failed Bad address` when the guest touches the hostmem blob mapping. Root-cause hypothesis: KVM in 6.12 can't map GPU VRAM (pfnmap) memory into guests; support landed in 6.13+. **Retry plan (in progress 2026-07-07): host kernel → linux618, reboot, re-add the XML below, test.**

  Required XML (all four pieces, on top of the rendernode pin):
  1. `<domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>`
  2. After `</currentMemory>`: `<memoryBacking><source type='memfd'/><access mode='shared'/></memoryBacking>`
  3. Video model: `<model type='virtio' blob='on' ...>`
  4. Before `</domain>`:
     ```xml
     <qemu:override>
       <qemu:device alias='video0'>
         <qemu:frontend>
           <qemu:property name='drm_native_context' type='bool' value='true'/>
           <qemu:property name='hostmem' type='unsigned' value='4294967296'/>
         </qemu:frontend>
       </qemu:device>
     </qemu:override>
     ```
  Success check: guest `glxinfo -B | grep renderer` says `radeonsi`, not `virgl`. If it works, virgl crashes and the translation overhead are gone.
