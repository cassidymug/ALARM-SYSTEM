# Network Configuration for Guardian

## VLAN Isolation (Recommended)

```
Router/Firewall
  |
  +-- VLAN 1 (Main) - 192.168.1.0/24
  |     |
  |     +-- Guardian Hub: 192.168.1.10
  |     +-- Phones, laptops, etc.
  |
  +-- VLAN 10 (Cameras) - 192.168.10.0/24
        |
        +-- Cameras: 192.168.10.100-115
        +-- Hub uplink to cameras
```

### Benefits
- Isolate cameras from main network
- Prevent lateral movement if camera compromised
- Hub bridges both VLANs (controlled access)

## Firewall Rules

### VLAN 10 (Cameras) → Hub
- Allow: RTSP (554), HTTP/HTTPS for camera config
- Allow: Multicast (ONVIF discovery)

### VLAN 10 (Cameras) → Internet
- **Deny all** (disable vendor cloud, UPnP, etc.)

### Hub → Internet
- Allow: HTTPS (443) to relay.guardian.example.com
- Allow: HTTPS (443) to Hetzner Object Storage
- Allow: NTP, DNS

### Main VLAN → Hub
- Allow: SSH (22) for admin (or disable after setup)
- Allow: HTTPS (8080) for local UI/API access
- **Do not** expose Hub API/UI on WAN

## Camera Configuration

For each camera:
1. Set static IP in 192.168.10.x range
2. Disable vendor cloud services
3. Disable UPnP
4. Set strong unique password (not default)
5. Enable RTSP main + substream
6. Configure audio if supported
7. Update firmware (offline update if possible)

## PoE Switch Configuration

- Place on Camera VLAN (VLAN 10)
- Tag/trunk uplink to router for multi-VLAN
- Verify PoE budget for camera count
- Reserve ports for expansion

## DNS and Time

- Hub uses systemd-resolved or NetworkManager
- NTP via systemd-timesyncd
- Critical for mTLS certificate validation

## Example /etc/network/interfaces (Hub)

```
# Main uplink
auto eth0
iface eth0 inet static
    address 192.168.1.10
    netmask 255.255.255.0
    gateway 192.168.1.1

# Camera VLAN (if using VLAN tagging on single NIC)
auto eth0.10
iface eth0.10 inet static
    address 192.168.10.1
    netmask 255.255.255.0
    vlan-raw-device eth0
```

Or use separate physical NIC for camera network.
