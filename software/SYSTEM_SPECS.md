# Guardian System Specifications

## Hardware Requirements

### Standard Configuration (Recommended)
- **CPU**: Quad-core x86-64 or ARM64, 2.0+ GHz
- **RAM**: **16GB DDR4** (standard)
- **Storage**:
  - **OS/Services**: 256GB NVMe SSD (fast, for OS + event database)
  - **Recordings**: 2-8TB HDD (slow, bulk storage)
- **Network**: Gigabit Ethernet (for PoE camera traffic)
- **Optional**: TPU/NPU for AI acceleration (Google Coral, Intel Movidius)

### Minimum Configuration (Development/Testing)
- **CPU**: Dual-core x86-64, 1.5+ GHz
- **RAM**: 8GB DDR4
- **Storage**: 128GB SSD
- **Network**: Gigabit Ethernet

### Why 16GB RAM Standard?

With 16GB, we can comfortably run:

| Component | RAM Usage | Notes |
|-----------|-----------|-------|
| **Debian OS** | 500MB | Base system, systemd, network |
| **Guardian services** | 800MB | All 9 services + UI |
| **RTSP buffers** | 2GB | 16 cameras × 128MB buffer |
| **AI detection** | 4GB | YOLOv8 model + frame buffers |
| **Event database** | 1GB | SQLite cache, event history |
| **Recordings cache** | 2GB | Write buffer before HDD flush |
| **System headroom** | 5.7GB | Future features, safety margin |

**Total**: ~10.3GB used, leaving **5.7GB free** for growth.

## Camera Capacity

### With 16GB RAM

| Resolution | Cameras | Bitrate/cam | Total Network | RAM per cam | AI FPS |
|------------|---------|-------------|---------------|-------------|--------|
| **1080p**  | 32      | 4 Mbps      | 128 Mbps      | 128MB       | 5 fps  |
| **4K**     | 16      | 8 Mbps      | 128 Mbps      | 256MB       | 2 fps  |
| **Mixed**  | 24      | ~5 Mbps     | 120 Mbps      | ~170MB      | 3 fps  |

**Recommended**: 16-24 cameras (mix of 1080p and 4K)

## Storage Sizing

### Recording Retention

Assumes **motion-triggered recording** (not 24/7 continuous):
- **Motion activity**: 10% of the time (industry average for homes/small business)
- **Retention**: 30 days

| Cameras | Resolution | Bitrate | Daily Recording | 30-day Storage |
|---------|-----------|---------|-----------------|----------------|
| 8       | 1080p     | 4 Mbps  | 346 GB          | 10 TB          |
| 16      | 1080p     | 4 Mbps  | 691 GB          | 20 TB          |
| 16      | 4K        | 8 Mbps  | 1.38 TB         | 41 TB          |
| 24      | Mixed     | 5 Mbps  | 1.04 TB         | 31 TB          |

**Recommendation**: 
- **Home (8-12 cameras)**: 4-8TB HDD
- **Small business (16-24 cameras)**: 12-20TB HDD or 2× HDDs in RAID1

### Event Database Storage
- **SQLite database**: `/var/lib/guardian/events.db`
- **Size**: ~10MB per 100K events
- **Typical**: 50K events/year = 5MB/year
- **Retention**: Keep forever (negligible size)

## Network Requirements

### Bandwidth

**Camera traffic** (RTSP inbound):
- 16 cameras × 4 Mbps = **64 Mbps** (1080p)
- 16 cameras × 8 Mbps = **128 Mbps** (4K)

**Mobile access** (outbound):
- Live view: 2-4 Mbps per stream
- Playback: 4-8 Mbps

**Recommendation**: Gigabit Ethernet (1000 Mbps) — plenty of headroom

### PoE Power Budget
If using PoE switch to power cameras:
- **PoE (802.3af)**: 15.4W per port → 8 cameras max on 120W switch
- **PoE+ (802.3at)**: 25.5W per port → 16 cameras max on 400W switch

## AI Detection Performance

With 16GB RAM, we can run **local AI inference** (no cloud):

### YOLOv8 on CPU (x86-64)
- **Model**: YOLOv8n (nano, 6MB)
- **Input**: 640×640 frame
- **Speed**: 50ms/frame (20 FPS) on quad-core 3GHz CPU
- **Concurrent cameras**: 4-8 streams analyzed simultaneously

### YOLOv8 on Google Coral TPU (optional)
- **Model**: YOLOv8n (Edge TPU compiled)
- **Speed**: 10ms/frame (100 FPS)
- **Concurrent cameras**: 16+ streams

### Detection Classes
- Person
- Vehicle (car, truck, motorcycle)
- Animal (dog, cat, etc.)
- Package
- Custom (train your own)

## Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| **Camera startup** | <5 sec | RTSP connect + first frame |
| **Detection latency** | <100ms | Frame → AI → event |
| **Alarm trigger** | <50ms | Zone open → siren |
| **Mobile live view** | <2 sec | Tap camera → video starts |
| **Recording search** | <1 sec | Query 30 days of events |
| **System boot** | <60 sec | Power on → all services running |
| **Uptime** | 99.9%+ | 8 hours downtime/year max |

## Power Consumption

### Hub Appliance
- **Idle**: 15-30W (depends on CPU)
- **Active** (16 cameras recording): 40-60W
- **Peak** (AI inference): 80-100W

### PoE Cameras
- 16 cameras × 8W = **128W**

### Total System
- **Typical**: 170W (hub 42W + cameras 128W)
- **UPS**: 1500VA / 900W UPS recommended (5-hour runtime)

## Example Hardware Configurations

### Budget Build (~$600)
- **HP EliteDesk 800 G4 Mini** (used, $200)
  - i5-8500T (6-core), 16GB RAM, 256GB SSD
- **8TB WD Purple HDD** ($180)
- **PoE+ switch 16-port** ($120)
- **8× 1080p PoE cameras** ($30 each = $240)

### Mid-Range Build (~$1200)
- **Intel NUC 12 Pro** ($500)
  - i5-1240P (12-core), 16GB RAM, 512GB NVMe
- **12TB WD Purple HDD** ($280)
- **PoE+ switch 24-port** ($200)
- **16× 1080p/4K PoE cameras** ($40 each = $640)

### High-End Build (~$2500)
- **Custom mini-ITX build** ($900)
  - Ryzen 7 7700, 32GB RAM, 1TB NVMe, Google Coral TPU
- **2× 12TB WD Purple RAID1** ($560)
- **PoE++ switch 24-port** ($400)
- **24× 4K PoE cameras** ($60 each = $1440)

## Operating System Footprint

### Disk Usage
```
/                  20GB   (Debian base + Guardian services)
/srv/guardian      2-20TB (Recordings)
/var/lib/guardian  1GB    (Event database, state)
/var/log/guardian  500MB  (Logs, rotated daily)
/etc/guardian      10MB   (Config files)
```

### Memory Map (16GB)
```
Kernel:           500MB
systemd:          50MB
guardian-api:     80MB
guardian-recorder: 200MB (8 cameras × 25MB)
guardian-detect:  4000MB (AI model + buffers)
guardian-alarm:   50MB
guardian-sensors: 40MB
guardian-gateway: 60MB
guardian-intercom: 100MB
guardian-backup:  80MB
guardian-ui:      120MB
SQLite cache:     1000MB
Buffers/cache:    2000MB
Free:             7720MB
```

## Scalability

With 16GB RAM standard:
- ✅ **16-24 cameras** comfortably
- ✅ **Local AI detection** on all streams
- ✅ **64 zones** (2× expanders)
- ✅ **Multi-site** (manage 4-5 Guardians from one relay)
- ✅ **30-day retention** at reasonable storage cost
- ✅ **Future features** without hardware upgrade

## Comparison to Mainstream Systems

| Feature | Mainstream DVR | Guardian (16GB) |
|---------|----------------|-----------------|
| **RAM** | 512MB-2GB | 16GB |
| **Cameras** | 8-16 | 16-24+ |
| **AI** | Cloud subscription | Local, free |
| **Storage** | 1-4TB | Unlimited (add HDDs) |
| **Expandability** | Locked | Add services, features |
| **Security** | Hardcoded passwords | Modern Linux hardening |
| **Updates** | Never | APT security updates |
| **Cost** | $400-800 + $200/year cloud | $600-1200, no subscription |

16GB gives us **enterprise features at prosumer prices**.
