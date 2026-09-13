# Camera Resolution Profiles and Storage Planning

## Resolution Profiles

| Profile | Resolution | Bitrate (est.) | Storage/day (continuous) |
|---------|-----------|----------------|--------------------------|
| full_hd | 1920x1080 | ~4 Mbps | ~42 GB |
| uhd_4k | 3840x2160 | ~25 Mbps | ~270 GB |
| uhd_8k | 7680x4320 | ~100 Mbps | ~1080 GB (1 TB) |

## Example Configurations

### Configuration 1: Mixed HD/4K (recommended)
- 2x 4K cameras (gate/door intercom): ~540 GB/day
- 10x Full HD cameras: ~420 GB/day
- **Total: ~960 GB/day (~28 TB/month)**
- Recommended: 4TB NVMe + 8TB HDD for 7-14 day retention

### Configuration 2: All Full HD
- 12x Full HD cameras: ~500 GB/day (~15 TB/month)
- Recommended: 4TB NVMe for 7-8 day retention

### Configuration 3: Heavy 4K/8K (high-end)
- 1x 8K perimeter overview: ~1080 GB/day
- 4x 4K key locations: ~1080 GB/day
- 7x Full HD: ~294 GB/day
- **Total: ~2.4 TB/day (~72 TB/month)**
- Recommended: 8TB NVMe + 16TB HDD pool, hardware encoding mandatory

## Hardware Encoding Recommendations

### For 4K (2-4 cameras)
- Intel Quick Sync (11th gen or newer)
- NVIDIA NVENC (GTX 1650 or newer)
- AMD VCN (Ryzen 5000 series or newer)

### For 8K (1-2 cameras)
- Intel Quick Sync (12th gen or newer with AV1 support)
- NVIDIA NVENC (RTX 4000 series)
- May require transcoding to 4K for remote viewing

## Substream Usage

Always configure substream URLs for:
- Remote grid view (lower bandwidth)
- Motion detection (lower CPU)
- Recording main stream at max resolution

Typical substream: 640x360 @ 1 Mbps

## Per-Camera Settings

```json
{
  "id": "cam_front_gate",
  "max_resolution": "uhd_4k",
  "rtsp_url": "rtsp://cam-ip:554/stream1",
  "rtsp_substream_url": "rtsp://cam-ip:554/stream2"
}
```

## Backup Considerations

### Scope: events_only
- ~10-50 GB/month (minimal)
- Suitable for: alarm clips only

### Scope: events_plus_rolling
- ~500 GB - 2 TB/month
- Suitable for: 7-day rolling window + events

### Scope: full_continuous
- Full mirror of local storage
- Not recommended for 4K/8K setups due to cost
- Bandwidth cap essential

## Bandwidth Calculations

### Remote Viewing
- Grid (12 cams, substream): ~12 Mbps
- Tap-to-HD (1 cam, Full HD): ~4 Mbps
- Tap-to-HD (1 cam, 4K): ~25 Mbps
- 8K not streamed remotely (transcoded to 4K on demand)

### Upload (Backup)
- 20 Mbps cap = ~216 GB/day = ~6.5 TB/month
- Configure backup_bandwidth_cap_mbps to protect uplink
