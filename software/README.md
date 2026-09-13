# Guardian software / OS

This folder is the **software and appliance OS** side of ALARM-SYSTEM.

## Layout

| Path | Purpose |
|------|---------|
| `os/` | Debian-minimal appliance image (mkosi / bootstrap) |
| `services/` | Zig daemons (recorder, alarm, sensors, gateway, backup, …) |
| `ui/` | Zig UI (SDL2) |
| `debian/` | systemd units / packaging |
| `deploy/` | Hetzner relay deploy |
| `configs/` | Example `/etc/guardian` configs |
| `build-all.sh` | Build helper |

Hardware (KiCad zone expander) lives in `../hardware/`.
Design docs live in `../docs/`.

## Build (Linux / WSL recommended)

```bash
cd software
./build-all.sh
```

Requires Zig; recorder needs `ffmpeg`; UI needs `libsdl2`.

## Wired-only note

Hub-edge devices are wired (PoE cameras, custom 32-zone expander). No Zigbee/Wi-Fi to the hub.
