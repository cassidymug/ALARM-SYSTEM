# Guardian OS / Appliance Image

This directory builds the **Guardian Debian appliance image** — a minimal, bootable OS that runs the Guardian services.

## Overview

The appliance is built using **mkosi** (a systemd project) to create a clean Debian Bookworm x86-64 image with:
- Minimal package set (systemd, network-manager, openssh, ffmpeg)
- Guardian service users and directory structure
- systemd units pre-installed
- No desktop environment, X11, or unnecessary services

## Prerequisites (Linux build host)

```bash
# Debian/Ubuntu
sudo apt install mkosi systemd-container qemu-system-x86

# Arch
sudo pacman -S mkosi systemd qemu-base
```

## Build

```bash
cd software/os/debian
sudo mkosi build
```

This produces `guardian-appliance.raw` (or `.qcow2`), a bootable disk image.

### Build outputs

- `guardian-appliance.raw` — raw disk image (can be written to USB/SSD with `dd`)
- `guardian-appliance.qcow2` — QEMU virtual disk (if configured)

## Test / Boot

### QEMU (local VM)

```bash
mkosi qemu
# or manually:
qemu-system-x86_64 -m 2G -smp 2 -enable-kvm \
  -drive file=guardian-appliance.raw,format=raw,if=virtio
```

### Physical hardware

Write the raw image to a USB drive or SSD:

```bash
sudo dd if=guardian-appliance.raw of=/dev/sdX bs=4M status=progress oflag=sync
```

**Warning:** double-check the target device (`/dev/sdX`)!

## Post-boot setup

1. **SSH in** (default user: root, no password — **set one immediately**)
2. Install Guardian binaries:
   ```bash
   # Copy from build machine or install .deb packages
   sudo cp software/services/*/zig-out/bin/guardian-* /usr/bin/
   sudo chmod +x /usr/bin/guardian-*
   ```
3. Copy systemd units:
   ```bash
   sudo cp software/debian/systemd/*.service /etc/systemd/system/
   sudo cp software/debian/systemd/guardian.target /etc/systemd/system/
   sudo systemctl daemon-reload
   ```
4. Place `/etc/guardian/site.json` (see `software/configs/examples/`)
5. Enable services:
   ```bash
   sudo systemctl enable guardian.target
   sudo systemctl start guardian.target
   ```

## Customization

Edit `debian/mkosi.conf` to:
- Add packages (`Packages=` section)
- Change release (e.g., `Release=trixie`)
- Enable boot/EFI options

Post-install script: `debian/mkosi.postinst` runs at image build time (user creation, directory setup).

## Directory structure

```
software/os/
├── debian/
│   ├── mkosi.conf       # mkosi config (distro, packages, image options)
│   └── mkosi.postinst   # Post-install script (runs during build)
└── README.md            # This file
```

## Next steps

- **Packaging**: Build `.deb` packages for Guardian services (see `software/debian/`)
- **Provisioning**: Add ansible/cloud-init for automated setup
- **Testing**: Automated VM smoke tests with systemd-nspawn
- **CI**: GitHub Actions to build images on release

## Resources

- [mkosi documentation](https://github.com/systemd/mkosi)
- [Debian Bookworm](https://www.debian.org/releases/bookworm/)
- Guardian systemd units: `software/debian/systemd/`
