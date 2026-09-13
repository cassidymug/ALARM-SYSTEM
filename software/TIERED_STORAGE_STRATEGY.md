# Guardian Tiered Storage Strategy - 5-Year Retention

## The Challenge

**5-year retention changes everything:**

| Scale | Cameras | 30-day Storage | 5-year Storage (60× more!) |
|-------|---------|----------------|---------------------------|
| Home | 8 | 2.6 TB | **156 TB** |
| Small Business | 16 | 5.2 TB | **312 TB** |
| Medium Business | 32 | 10.4 TB | **624 TB** |
| School/University | 64 | 20.8 TB | **1.2 PB** |
| Large Farm | 128 | 41.6 TB | **2.5 PB** |
| Corporation | 220+ | 71.5 TB | **4.3 PB** |

**Problem:** Storing everything on expensive NVMe/SSD/HDD for 5 years = **bankruptcy**

**Solution:** ✅ **Tiered storage** - hot/warm/cold tiers with automatic archival

## Three-Tier Storage Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                    Storage Tiers                                │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  HOT TIER (0-7 days)                                    │   │
│  │  - Fast NVMe/SSD                                        │   │
│  │  - Instant playback                                     │   │
│  │  - Motion search, AI analysis                           │   │
│  │  - Cost: $0.10/GB/year                                  │   │
│  └──────────────────┬──────────────────────────────────────┘   │
│                     │ Auto-archive after 7 days                 │
│                     ▼                                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  WARM TIER (7 days - 6 months)                          │   │
│  │  - Spinning HDD                                         │   │
│  │  - Moderate speed (3-5s seek)                           │   │
│  │  - Event-triggered recording only                       │   │
│  │  - Cost: $0.02/GB/year                                  │   │
│  └──────────────────┬──────────────────────────────────────┘   │
│                     │ Auto-archive after 6 months               │
│                     ▼                                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  COLD TIER (6 months - 5 years)                         │   │
│  │  - LTO-9 Tape or Cloud Glacier                          │   │
│  │  - Slow retrieval (hours)                               │   │
│  │  - Important events only                                │   │
│  │  - Cost: $0.005/GB/year (tape) or $0.001/GB/month (S3) │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### Tier Details

| Tier | Duration | Technology | Speed | Cost/GB/year | Use Case |
|------|----------|------------|-------|--------------|----------|
| **Hot** | 0-7 days | NVMe/SSD | Instant | $0.10 | Live monitoring, recent playback |
| **Warm** | 7d-6mo | HDD | 3-5s | $0.02 | Incident review, investigations |
| **Cold** | 6mo-5yr | Tape/Glacier | Hours | $0.005-$0.012 | Legal compliance, rare retrieval |

## Recording Strategies by Tier

### Hot Tier (Recent = Critical)
- **Record everything** (continuous + motion)
- **Full resolution** (4K/8K)
- **AI analysis enabled** (person/vehicle detection)
- **Instant search** by time, camera, event type

### Warm Tier (Recent History)
- **Motion-triggered only** (90% storage savings)
- **Compressed** (lower bitrate, smaller files)
- **Indexing** for fast search
- **Moderate access speed**

### Cold Tier (Archive)
- **Events only** (alarm triggers, flagged recordings)
- **Heavily compressed** (H.265 high CRF or AV1)
- **Metadata-indexed** (retrieve by event ID)
- **Slow but cheap**

## Market Segment Configurations

### 1. Home (8 cameras, 1080p)

**Profile:**
- 8× 1080p cameras
- Continuous recording: 7 days
- Motion-triggered: 6 months
- Events archived: 5 years

**Storage Breakdown:**
```
Hot (7 days continuous):
  8 cams × 2.5 Mbps × 7 days = 151 GB → 256GB NVMe ($30)

Warm (6 months motion @ 10% duty):
  8 cams × 2.5 Mbps × 180 days × 10% = 3.9 TB → 4TB HDD ($80)

Cold (4.5 years events @ 1% duty):
  8 cams × 2.5 Mbps × 1642 days × 1% = 3.6 TB → Cloud ($4/month)
```

**Hardware:**
- **Hub**: Mini PC (Intel N100, 16GB RAM, 256GB NVMe + 4TB HDD) - $400
- **Network**: 8-port PoE switch - $80
- **Cameras**: 8× 1080p (user provides)
- **Total**: **$480 + $48/year cloud**

**5-year TCO**: $720 (hardware amortized over 5 years) + $240 cloud = **$960**

### 2. Small Business (16 cameras, 1080p/4K mix)

**Profile:**
- 12× 1080p + 4× 4K cameras
- Continuous recording: 7 days
- Motion-triggered: 6 months
- Events archived: 5 years

**Storage Breakdown:**
```
Hot (7 days continuous):
  12 cams × 2.5 Mbps + 4 cams × 15 Mbps = 504 GB → 1TB NVMe ($80)

Warm (6 months motion @ 10% duty):
  Mixed streams = 13 TB → 16TB HDD ($320)

Cold (4.5 years events @ 1% duty):
  Mixed streams = 11.4 TB → Cloud ($11/month) or LTO-8 tape ($50 one-time)
```

**Hardware:**
- **Hub**: Workstation (Ryzen 7, 32GB RAM, 1TB NVMe + 16TB HDD) - $1,500
- **Network**: 24-port PoE switch - $200
- **Cameras**: 16× mixed (user provides)
- **Backup**: LTO-8 tape drive + 5× tapes ($1,500) OR cloud
- **Total**: **$3,200 one-time** OR **$1,700 + $132/year cloud**

**5-year TCO (tape)**: **$3,200**  
**5-year TCO (cloud)**: **$2,360**

### 3. Medium Business / School (64 cameras, 4K)

**Profile:**
- 64× 4K cameras
- Continuous recording: 7 days
- Motion-triggered: 6 months
- Events archived: 5 years

**Storage Breakdown:**
```
Hot (7 days continuous):
  64 cams × 15 Mbps × 7 days = 8.1 TB → 2× 4TB NVMe RAID1 ($640)

Warm (6 months motion @ 10% duty):
  64 cams × 15 Mbps × 180 days × 10% = 104 TB → 6× 20TB HDD RAID6 ($1,800)

Cold (4.5 years events @ 1% duty):
  64 cams × 15 Mbps × 1642 days × 1% = 91 TB → LTO-9 tapes ($500)
```

**Hardware:**
- **Recorder**: 2× nodes (i9 + RTX 4070, 64GB RAM each) - $5,000
- **Storage**: 8TB NVMe + 120TB HDD - $2,440
- **Network**: 2× 48-port PoE switches - $2,400
- **Backup**: LTO-9 tape drive + 10× tapes ($2,000)
- **Total**: **$11,840**

**5-year TCO**: **$11,840** (no ongoing cloud costs)

### 4. University / Large Farm (128 cameras, 4K/8K mix)

**Profile:**
- 96× 4K + 32× 8K cameras
- Continuous recording: 7 days
- Motion-triggered: 6 months
- Events archived: 5 years

**Storage Breakdown:**
```
Hot (7 days continuous):
  96× 4K + 32× 8K = 32.6 TB → 4× 8TB NVMe RAID10 ($2,560)

Warm (6 months motion @ 10% duty):
  Mixed streams = 418 TB → 24× 20TB HDD RAID6 (usable: 440TB) ($7,200)

Cold (4.5 years events @ 1% duty):
  Mixed streams = 368 TB → 40× LTO-9 tapes ($2,000)
```

**Hardware:**
- **Recorders**: 4× nodes (Ryzen 9 + RTX 4080, 64GB each) - $12,000
- **Storage**: 32TB NVMe + 480TB HDD - $9,760
- **Network**: Core switch + 3× 48-port PoE - $4,800
- **Backup**: 2× LTO-9 drives + 40 tapes ($4,000)
- **Total**: **$30,560**

**5-year TCO**: **$30,560**

### 5. Corporation (220 cameras, 8K)

**Profile:**
- 220× 8K cameras
- Continuous recording: 7 days
- Motion-triggered: 6 months
- Events archived: 5 years

**Storage Breakdown:**
```
Hot (7 days continuous):
  220× 8K = 100 TB → 25× 4TB NVMe RAID10 (distributed) ($20,000)

Warm (6 months motion @ 10% duty):
  220× 8K @ 10% = 1.3 PB → TrueNAS cluster (see below) ($90,000)

Cold (4.5 years events @ 1% duty):
  220× 8K @ 1% = 1.1 PB → Tape library or S3 Glacier (~$60,000 or $1,100/month)
```

**Hardware:**
- **Recorders**: 7× nodes (as designed earlier) - $21,000
- **Hot storage**: Distributed NVMe across nodes - $20,000
- **Warm storage**: 3× TrueNAS (1.5 PB total) - $90,000
- **Cold storage**: Tape library (1.2 PB capacity) - $60,000
- **Network**: As designed earlier - $7,500
- **Total**: **$198,500**

**5-year TCO (tape)**: **$198,500**  
**5-year TCO (cloud)**: **$141,500 + $66,000 cloud = $207,500**

## Storage Technology Deep Dive

### Hot Tier: NVMe/SSD

**Use:** 0-7 days, all recordings

| Capacity | Technology | Cost | $/GB |
|----------|-----------|------|------|
| 1 TB | Samsung 990 Pro | $80 | $0.08 |
| 2 TB | Samsung 990 Pro | $140 | $0.07 |
| 4 TB | Samsung 990 Pro | $260 | $0.065 |
| 8 TB | Samsung PM9A3 (enterprise) | $800 | $0.10 |

**Performance:** 7,000 MB/s read, 5,000 MB/s write - handles 20+ concurrent 4K streams

**Lifespan:** 600 TBW (terabytes written) = 5-10 years for recording

### Warm Tier: HDD

**Use:** 7 days - 6 months, motion-triggered recordings

| Capacity | Technology | Cost | $/GB |
|----------|-----------|------|------|
| 4 TB | WD Red Plus (CMR) | $80 | $0.020 |
| 8 TB | WD Red Plus | $140 | $0.0175 |
| 12 TB | WD Red Pro | $240 | $0.020 |
| 18 TB | WD Ultrastar HC550 | $300 | $0.0167 |
| 20 TB | WD Ultrastar HC650 | $350 | $0.0175 |
| 22 TB | Seagate Exos X22 | $380 | $0.0173 |

**Performance:** 250 MB/s sequential - handles 8-10 concurrent 4K streams

**Lifespan:** 2.5M hours MTBF = 10-15 years

**RAID Recommendation:**
- **Home/SMB**: RAID1 (mirror, 50% usable)
- **Medium**: RAID6 (dual parity, 67% usable with 6 drives)
- **Enterprise**: RAID-Z2 (ZFS, similar to RAID6)

### Cold Tier: Tape or Cloud

#### Option A: LTO Tape (Recommended for >10TB archive)

| Generation | Capacity | Cost/Tape | $/GB | Transfer Speed |
|------------|----------|-----------|------|----------------|
| LTO-8 | 12 TB | $50 | $0.0042 | 360 MB/s |
| LTO-9 | 18 TB | $60 | $0.0033 | 400 MB/s |
| LTO-10 | 36 TB (2025) | $100 est | $0.0028 | 500 MB/s |

**Tape drive cost:**
- LTO-8: $1,500 (external USB/Thunderbolt)
- LTO-9: $2,000
- LTO-10: $3,000 (when available)

**Pros:**
- No ongoing cost (buy tape once)
- Offline (ransomware-proof)
- 30-year shelf life
- Fast writes (360+ MB/s)

**Cons:**
- Slow retrieval (load tape, seek = 1-5 minutes)
- Requires tape drive
- Manual management

**Best for:** Schools, universities, corporations with >50TB to archive

#### Option B: Cloud Glacier (Recommended for <10TB archive)

| Service | Storage Cost | Retrieval Cost | Speed |
|---------|-------------|----------------|-------|
| **AWS S3 Glacier Instant** | $0.004/GB/mo | $0.03/GB | Instant |
| **AWS S3 Glacier Flexible** | $0.0036/GB/mo | $0.01/GB | 1-5 hours |
| **AWS S3 Glacier Deep** | $0.00099/GB/mo | $0.02/GB | 12 hours |
| **Backblaze B2** | $0.005/GB/mo | $0.01/GB | Minutes |
| **Wasabi** | $0.0059/GB/mo | Free | Instant |

**Pros:**
- No hardware to buy
- Unlimited scale
- Accessible from anywhere
- Automatic replication

**Cons:**
- Ongoing monthly cost
- Egress fees (download costs)
- Privacy concerns (data in cloud)
- Internet dependency

**Best for:** Homes, small businesses with <10TB to archive

## Modular Storage Expansion

### Start Small, Grow as Needed

**Example: Small Business starts with 8 cameras, grows to 32:**

#### Year 1: 8 cameras
```
Hardware: Mini PC ($400) + 4TB HDD ($80)
Storage: 4 TB warm tier
Cost: $480
```

#### Year 2: Add 8 cameras (16 total)
```
Add: 8TB HDD ($140)
Total storage: 12 TB warm tier
Incremental cost: $140
```

#### Year 3: Add 8 cameras (24 total)
```
Add: 12TB HDD ($240)
Total storage: 24 TB warm tier
Incremental cost: $240
```

#### Year 4: Add 8 cameras (32 total)
```
Upgrade hub: Workstation ($1,500)
Add: 16TB HDD ($320) + LTO-8 drive ($1,500)
Total: Now medium business scale
Incremental cost: $3,320
```

**Total over 4 years: $4,180** (amortized growth)

### Storage Modules (DIY)

**Hot Tier Module** (expandable NVMe):
- 4-bay NVMe enclosure (PCIe 4.0 x16) - $200
- 4× 4TB NVMe drives (RAID10) = 8TB usable - $1,040
- **Total: $1,240 for 8TB hot storage**

**Warm Tier Module** (expandable HDD):
- 8-bay JBOD enclosure (USB3/Thunderbolt) - $400
- 8× 20TB drives (RAID6) = 120TB usable - $2,800
- **Total: $3,200 for 120TB warm storage**

**Cold Tier Module** (tape):
- LTO-9 drive (external) - $2,000
- 10× LTO-9 tapes (180TB capacity) - $600
- **Total: $2,600 for 180TB cold archive**

## Automatic Tiering Implementation

### Archival Policy Engine (Zig)

```zig
pub const ArchivalPolicy = struct {
    hot_tier_days: u32 = 7,
    warm_tier_days: u32 = 180,
    cold_tier_days: u32 = 1825, // 5 years
    
    motion_threshold_warm: f32 = 0.1, // Only 10% with motion go to warm
    event_threshold_cold: f32 = 0.01, // Only 1% flagged events go to cold
    
    pub fn shouldArchive(self: *ArchivalPolicy, segment: RecordingSegment) ?Tier {
        const age_days = segment.getAgeDays();
        
        // Move to warm tier after 7 days (if motion detected)
        if (age_days >= self.hot_tier_days) {
            if (segment.has_motion or segment.is_event) {
                return .warm;
            } else {
                // Delete continuous non-motion recordings
                return .delete;
            }
        }
        
        // Move to cold tier after 6 months (if important event)
        if (age_days >= self.warm_tier_days) {
            if (segment.is_event or segment.is_flagged) {
                return .cold;
            } else {
                // Delete old motion recordings
                return .delete;
            }
        }
        
        return null; // Keep in current tier
    }
};

pub const ArchivalEngine = struct {
    policy: ArchivalPolicy,
    hot_tier: HotStorage,
    warm_tier: WarmStorage,
    cold_tier: ColdStorage,
    
    pub fn run(self: *ArchivalEngine) !void {
        while (true) {
            // Scan hot tier for old segments
            const hot_segments = try self.hot_tier.listSegments();
            for (hot_segments) |segment| {
                if (self.policy.shouldArchive(segment)) |tier| {
                    switch (tier) {
                        .warm => try self.moveToWarm(segment),
                        .cold => try self.moveToCold(segment),
                        .delete => try self.deleteSegment(segment),
                        else => {},
                    }
                }
            }
            
            // Scan warm tier for archive candidates
            const warm_segments = try self.warm_tier.listSegments();
            for (warm_segments) |segment| {
                if (self.policy.shouldArchive(segment)) |tier| {
                    switch (tier) {
                        .cold => try self.moveToCold(segment),
                        .delete => try self.deleteSegment(segment),
                        else => {},
                    }
                }
            }
            
            // Sleep for 1 hour before next scan
            std.time.sleep(3600 * std.time.ns_per_s);
        }
    }
    
    fn moveToWarm(self: *ArchivalEngine, segment: RecordingSegment) !void {
        log.info("archival", "Moving {s} to warm tier", .{segment.path});
        
        // Transcode to lower bitrate (optional)
        const compressed_path = try self.compressSegment(segment);
        
        // Copy to HDD
        try self.warm_tier.store(compressed_path);
        
        // Delete from hot tier
        try self.hot_tier.delete(segment.path);
        
        // Update database
        try self.updateSegmentLocation(segment, .warm, compressed_path);
    }
    
    fn moveToCold(self: *ArchivalEngine, segment: RecordingSegment) !void {
        log.info("archival", "Moving {s} to cold tier", .{segment.path});
        
        // Write to tape or upload to cloud
        try self.cold_tier.archive(segment);
        
        // Delete from warm tier
        try self.warm_tier.delete(segment.path);
        
        // Update database
        try self.updateSegmentLocation(segment, .cold, null);
    }
};
```

### Metadata Database (PostgreSQL)

```sql
CREATE TABLE recording_segments (
    id BIGSERIAL PRIMARY KEY,
    camera_id VARCHAR(64) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    duration_ms INTEGER NOT NULL,
    
    -- Storage tier tracking
    tier VARCHAR(10) NOT NULL, -- 'hot', 'warm', 'cold'
    hot_path TEXT,
    warm_path TEXT,
    cold_location TEXT, -- tape barcode or cloud URL
    
    -- Metadata for archival decisions
    has_motion BOOLEAN DEFAULT false,
    is_event BOOLEAN DEFAULT false,
    is_flagged BOOLEAN DEFAULT false,
    
    -- File info
    file_size_bytes BIGINT NOT NULL,
    codec VARCHAR(16) NOT NULL,
    
    created_at TIMESTAMP DEFAULT NOW(),
    archived_at TIMESTAMP,
    
    INDEX idx_camera_time (camera_id, start_time),
    INDEX idx_tier_age (tier, created_at)
);

-- Archival candidates query
SELECT id, camera_id, hot_path, created_at
FROM recording_segments
WHERE tier = 'hot'
  AND created_at < NOW() - INTERVAL '7 days'
  AND (has_motion = true OR is_event = true)
ORDER BY created_at
LIMIT 1000;
```

## Cost Comparison: 5-Year Retention

### Home (8× 1080p cameras, 156TB total over 5 years)

| Strategy | Year 0 | Year 5 Total | Notes |
|----------|--------|--------------|-------|
| **All NVMe** | $15,600 | $15,600 | Insane |
| **All HDD** | $3,120 | $3,120 | Slow |
| **Tiered (recommended)** | $480 | $960 | 16× cheaper than NVMe |
| **Cloud only** | $0 | $9,360 | No hardware but $$$ ongoing |

### Medium Business (32× 4K cameras, 624TB over 5 years)

| Strategy | Year 0 | Year 5 Total | Notes |
|----------|--------|--------------|-------|
| **All NVMe** | $62,400 | $62,400 | Not practical |
| **All HDD** | $12,480 | $12,480 | Slow for recent |
| **Tiered (recommended)** | $11,840 | $11,840 | Best balance |
| **Cloud only** | $0 | $37,440 | 3× more expensive |

### Corporation (220× 8K cameras, 4.3PB over 5 years)

| Strategy | Year 0 | Year 5 Total | Notes |
|----------|--------|--------------|-------|
| **All NVMe** | $430,000 | $430,000 | Impossible |
| **All HDD** | $86,000 | $86,000 | Slow, no scale |
| **Tiered (recommended)** | $198,500 | $198,500 | Optimal |
| **Cloud only** | $0 | $258,000 | $1,100/month adds up |

## Summary by Market Segment

| Segment | Cameras | 5-Year Storage | Solution | Cost (5 years) |
|---------|---------|----------------|----------|----------------|
| **Home** | 8× 1080p | 156 TB | Mini PC + HDD + Cloud | **$960** |
| **Small Business** | 16× mixed | 312 TB | Workstation + HDD + Tape | **$3,200** |
| **Medium Business** | 32× 4K | 624 TB | 2 nodes + HDD RAID + Tape | **$11,840** |
| **School/University** | 64× 4K | 1.2 PB | 2 nodes + NAS + Tape | **$30,560** |
| **Large Farm** | 128× mixed | 2.5 PB | 4 nodes + NAS + Tape | **$30,560** |
| **Corporation** | 220× 8K | 4.3 PB | 7 nodes + NAS + Tape Library | **$198,500** |

## Key Recommendations

### 1. **Start with what you need, expand modularly**
- Begin with hot+warm tiers
- Add cold tier when warm fills up
- Buy storage in chunks (not all upfront)

### 2. **Use tape for >10TB archives** (cost-effective, offline, safe)
- LTO-9: $0.003/GB one-time cost
- Cloud: $0.001-0.012/GB/month (adds up over 5 years!)

### 3. **Motion-triggered recording saves 90%**
- Continuous: 100% duty cycle
- Motion: 10% duty cycle (saves 90% storage!)

### 4. **Delete non-motion continuous recordings after 7 days**
- Keep: All motion + all events
- Delete: Boring continuous footage (empty parking lot at 3am)

### 5. **Use lower bitrates for archived footage**
- Hot tier: High quality (CRF 20)
- Warm tier: Medium quality (CRF 23)
- Cold tier: Lower quality (CRF 26) - still readable, 40% smaller

**Result:** Cost-effective, scalable, modular, and you own it forever.

**Want me to implement the automatic tiering/archival engine?**
