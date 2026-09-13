# ALARM-SYSTEM

Guardian DIY DVR + alarm appliance — a wired-only security hub with PoE cameras and custom zone expander.

## Structure

- **`software/`** — Appliance OS (Debian), Zig services, UI — **[start here](software/README.md)**
- **`hardware/`** — KiCad PCB designs (zone expander, power distribution)
- **`docs/`** — Architecture, specifications, build notes

## Quick start

For software/OS work:
```bash
cd software
# See software/README.md for build instructions
```

For hardware:
```bash
cd hardware
# Open .kicad_pro files in KiCad 8+
```

## Architecture

**Wired hub-edge design:**
- Hub appliance: Debian minimal + Zig services (recorder, alarm, sensors, gateway)
- Edge devices: PoE IP cameras (ONVIF/RTSP), 32-zone wired alarm expander (GXP protocol)
- Remote access: Optional Hetzner relay for mobile app (WebSocket tunnel)

**No Zigbee, no Wi-Fi sensors, no Home Assistant, no Frigate.** Owned code, minimal dependencies.
