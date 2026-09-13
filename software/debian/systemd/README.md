# Guardian systemd units

This directory contains systemd service units and the `guardian.target` for the Guardian appliance services.

## Units

- `guardian.target` — Meta-target that depends on all Guardian services
- `guardian-*.service` — Individual service units (api, recorder, alarm, sensors, etc.)

## Installation

These units are designed to be installed to `/etc/systemd/system/` on the Guardian appliance.

### During OS image build

The `mkosi.postinst` script (in `software/os/debian/`) creates users and directories, but units are installed separately (by `.deb` packages or manually).

### Manual install (for development/testing)

```bash
sudo cp software/debian/systemd/*.service /etc/systemd/system/
sudo cp software/debian/systemd/guardian.target /etc/systemd/system/
sudo systemctl daemon-reload
```

### Package install (future)

`.deb` packages will install units automatically:
```bash
sudo dpkg -i guardian-services_0.1.0_amd64.deb
sudo systemctl daemon-reload
sudo systemctl enable guardian.target
```

## Binary paths

All units reference binaries at `/usr/bin/guardian-*`:
- `/usr/bin/guardian-api`
- `/usr/bin/guardian-recorder`
- `/usr/bin/guardian-alarm`
- `/usr/bin/guardian-sensors`
- `/usr/bin/guardian-gateway`
- `/usr/bin/guardian-intercom`
- `/usr/bin/guardian-backup`
- `/usr/bin/guardian-detect`
- `/usr/bin/guardian-ui`

Copy built binaries from `software/services/*/zig-out/bin/` and `software/ui/zig-out/bin/` to `/usr/bin/`.

## Enabling services

```bash
# Enable all services via the target
sudo systemctl enable guardian.target
sudo systemctl start guardian.target

# Or enable individual services
sudo systemctl enable guardian-api.service
sudo systemctl start guardian-api.service
```

## Configuration

Services read configuration from:
- `/etc/guardian/site.json` (main site config)
- `/etc/guardian/certs/` (TLS certificates)

See `software/configs/examples/` for configuration examples.

## Logs

```bash
# View logs for all Guardian services
journalctl -u 'guardian-*'

# Follow logs for a specific service
journalctl -u guardian-api.service -f
```

## Security

Units are hardened with systemd sandboxing features:
- `ProtectSystem=strict`
- `PrivateTmp=yes`
- `NoNewPrivileges=yes`
- `RestrictAddressFamilies=`
- `SystemCallFilter=@system-service`

Services run as dedicated users (`guardian-api`, `guardian-recorder`, etc.) in the `guardian` group.

## Dependencies

The `guardian.target` has `After=network-online.target` to ensure network is ready before services start.

Service dependencies:
- `recorder` → needs network for RTSP cameras
- `sensors` → no network required (local serial/USB)
- `api` → needs network for HTTP API
- `gateway` → needs network for relay WebSocket
- `ui` → needs local display (framebuffer or X11/Wayland)
