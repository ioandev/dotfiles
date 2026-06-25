# CoolerControl / Fan Detection Investigation

## System

- **Board:** Gigabyte X870 AORUS ELITE WIFI7
- **Super I/O chip:** IT87952E (reported by hwmon as `it87952`)
- **CPU:** AMD (k10temp loaded)
- **GPU:** AMD (amdgpu)
- **Distro:** Manjaro (Arch-based)

## Symptoms

- `sensors` shows `it87952-isa-0a60` adapter but:
  - `fan1/2/3 = 0 RPM`
  - `pwm1/2 = 126%` (invalid — driver register mismatch, max is 100%)
  - `temp2 = -55°C` (disconnected thermistor)
- CoolerControl GUI does not show CPU fan control.
- `k10temp` works (CPU temp readable).
- AMDGPU fan + temps work fine.

## Root cause

Mainline kernel `it87` driver has incomplete support for **IT87952E** (new X870-era ITE Super I/O chip, 2024). Driver loads, but fan tachometer and PWM scaling registers are wrong. Gigabyte boards also have ACPI resource conflicts that block hwmon access by default.

## Fix steps

### 1. Install `it87-dkms` (out-of-tree fork with better chip coverage)

```bash
yay -S it87-dkms
```

Repo: https://github.com/frankcrawford/it87

### 2. Module options

```bash
sudo tee /etc/modprobe.d/it87.conf <<EOF
options it87 ignore_resource_conflict=1
EOF

sudo tee /etc/modules-load.d/it87.conf <<EOF
it87
EOF
```

`ignore_resource_conflict=1` — bypass ACPI claim on the I/O region.

If chip still misdetected, try `force_id=0x8628` (IT8628E compat) — only after confirming dkms alone fails.

### 3. Kernel command line

Gigabyte BIOS marks Super I/O region as ACPI-reserved. Kernel refuses access unless told to allow:

```bash
sudoedit /etc/default/grub
# append to GRUB_CMDLINE_LINUX_DEFAULT:
#   acpi_enforce_resources=lax
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Reboot.

### 4. Verify

```bash
sensors          # fans should show real RPM, pwm ≤ 100%
sudo systemctl restart coolercontrold
```

Open CoolerControl GUI — CPU fan + case fans should appear.

## Fallback

If `it87-dkms` does not yet support IT87952E (X870 is recent, support lands late):

- Use BIOS fan curves directly (Smart Fan in UEFI).
- Read temps via `k10temp` for monitoring only.
- Track upstream issues:
  - https://github.com/frankcrawford/it87/issues
  - Arch wiki: https://wiki.archlinux.org/title/Lm_sensors

## Related side-quest: VLC video not playing

- VLC 3.0.22 + ffmpeg 8.1.1 = broken video decode API on Arch.
- Fix: `yay -S ffmpeg4.4` (compat package), VLC auto-prefers it.
- Alternative: `vlc-git` (VLC 4 nightly, supports ffmpeg 8).
