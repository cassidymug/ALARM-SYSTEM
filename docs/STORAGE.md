# Guardian Storage Architecture

## Overview

Guardian supports **very large storage drives** for continuous recording:
- **HDDs**: 10TB, 12TB, 16TB, 18TB, 20TB+ per drive
- **SSDs**: 2TB, 4TB, 8TB+ for high-performance scenarios
- **RAID arrays**: Multiple drives in RAID 5/6/10 for redundancy
- **Mixed storage**: Fast SSD for recent recordings, HDD for archive

## Filesystem Recommendations

### For HDDs (10TB+)

**XFS** (Recommended for large HDDs):
```bash
mkfs.xfs -f -b size=4096 -m reflink=1,crc=1 -i size=512 /dev/sdb1
```

**Benefits**:
- ✅ Excellent performance with large files (recording segments)
- ✅ Scales to 500TB+ per filesystem
- ✅ Efficient allocation for video files
- ✅ Good metadata performance
- ✅ Online defragmentation support

**Mount options**:
```bash
/dev/sdb1  /srv/guardian/recordings  xfs  defaults,noatime,nodiratime,logbufs=8,logbsize=256k  0  2
```

### For SSDs (2TB+)

**ext4** or **XFS** (both work well):
```bash
# ext4 with SSD optimizations
mkfs.ext4 -F -O ^has_journal -E nodiscard /dev/nvme0n1p1

# XFS with SSD optimizations  
mkfs.xfs -f -K /dev/nvme0n1p1
```

**Mount options for SSD**:
```bash
# ext4
/dev/nvme0n1p1  /srv/guardian/recordings  ext4  defaults,noatime,nodiratime,discard  0  2

# XFS
/dev/nvme0n1p1  /srv/guardian/recordings  xfs  defaults,noatime,nodiratime,discard  0  2
```

### For RAID Arrays

**mdadm RAID + XFS**:
```bash
# RAID 6 (2 disk redundancy) with 4x 12TB drives
mdadm --create /dev/md0 --level=6 --raid-devices=4 /dev/sd[b-e]1
mkfs.xfs -f -d su=256k,sw=2 /dev/md0
```

## Storage Capacity Planning

### Recording Bitrates

From `configs/examples/RESOLUTION_GUIDE.md`:

| Resolution | Estimated Bitrate | Storage per Hour | Storage per Day (24h) |
|------------|-------------------|------------------|-----------------------|
| Full HD    | 4 Mbps            | 1.8 GB           | 43 GB                 |
| 4K (2160p) | 25 Mbps           | 11 GB            | 264 GB                |
| 8K (4320p) | 100 Mbps          | 45 GB            | 1,080 GB (1.08 TB)    |

### Example Scenarios

**Scenario 1: Small Home (4 cameras, Full HD)**
- 4 cameras × 43 GB/day = **172 GB/day**
- 30-day retention = **5.2 TB total**
- **Recommended**: 8TB HDD (single drive)

**Scenario 2: Medium Home (8 cameras, mixed HD/4K)**
- 4× Full HD: 4 × 43 GB = 172 GB/day
- 4× 4K: 4 × 264 GB = 1,056 GB/day
- Total: **1.2 TB/day**
- 30-day retention = **36 TB total**
- **Recommended**: 4× 10TB HDDs in RAID 6 (usable: ~20TB after redundancy)

**Scenario 3: Large Property (16 cameras, 4K/8K)**
- 12× 4K: 12 × 264 GB = 3,168 GB/day
- 4× 8K: 4 × 1,080 GB = 4,320 GB/day
- Total: **7.5 TB/day**
- 30-day retention = **225 TB total**
- **Recommended**: 8× 16TB HDDs in RAID 6 (usable: ~96TB) or 12× 12TB

**Scenario 4: Enterprise (32 cameras, 4K, 90-day retention)**
- 32× 4K: 32 × 264 GB = 8,448 GB/day
- Total: **8.4 TB/day**
- 90-day retention = **756 TB total**
- **Recommended**: Multiple RAID arrays + tiered storage

## Storage Tiers

### Hot Storage (Recent, Fast Access)
- **Last 7 days**: SSD or fast HDD RAID 10
- **Use case**: Live viewing, quick review, AI detection
- **Example**: 2TB NVMe SSD for 7-day cache

### Warm Storage (Archive, Standard Access)
- **8-30 days**: Large HDD RAID 6
- **Use case**: Event review, incident investigation
- **Example**: 4× 10TB HDDs in RAID 6

### Cold Storage (Long-term, Slow Access)
- **30+ days**: Encrypted offsite backup (Hetzner)
- **Use case**: Compliance, legal, long-term archive
- **Example**: Hetzner Object Storage (unlimited)

## Automatic Storage Management

### Retention Policies (guardian-recorder)

The recorder will support:

**1. Time-based retention**:
```json
{
  "retention": {
    "continuous": "30d",    // Keep all recordings 30 days
    "events": "90d",        // Keep event-triggered recordings 90 days
    "important": "365d"     // Keep flagged/important recordings 1 year
  }
}
```

**2. Space-based retention**:
```json
{
  "retention": {
    "max_storage_gb": 10000,        // Max 10TB
    "min_free_space_gb": 500,       // Keep 500GB free
    "cleanup_when_below_gb": 600    // Start cleanup at 600GB free
  }
}
```

**3. Hybrid retention**:
```json
{
  "retention": {
    "continuous_days": 30,
    "max_storage_gb": 10000,
    "cleanup_priority": [
      "continuous",     // Delete continuous recordings first
      "events",         // Then event recordings
      "important"       // Keep important recordings longest
    ]
  }
}
```

### Storage Monitoring

The recorder will monitor:
- Total storage capacity
- Used space
- Free space
- Write speed (MB/s)
- I/O wait time
- SMART health status (for drives that support it)

Alerts when:
- Free space < 10%
- Free space < 500 GB
- Write speed drops below threshold
- SMART errors detected

## Partition Layout

### Single Large Drive (10TB+ HDD)

```
/dev/sdb1  /srv/guardian/recordings  xfs  ...
```

**Full capacity** for recordings.

### Multiple Drives

**Option 1: RAID Array (Recommended for reliability)**
```bash
# 4× 10TB drives in RAID 6
/dev/md0  /srv/guardian/recordings  xfs  ...
# Usable: ~20TB (2 drives for parity)
```

**Option 2: Separate Drives (Maximum capacity)**
```bash
/dev/sdb1  /srv/guardian/recordings/drive1  xfs  ...
/dev/sdc1  /srv/guardian/recordings/drive2  xfs  ...
/dev/sdd1  /srv/guardian/recordings/drive3  xfs  ...
# Recorder writes round-robin across drives
```

**Option 3: Tiered Storage (Performance + Capacity)**
```bash
# SSD for hot tier (last 7 days)
/dev/nvme0n1p1  /srv/guardian/recordings/hot  xfs  ...

# HDD array for warm tier (8-30 days)
/dev/md0  /srv/guardian/recordings/warm  xfs  ...

# Automatic promotion/demotion based on age
```

## LVM (Logical Volume Manager)

**Benefits**:
- ✅ Resize filesystems online
- ✅ Add drives without downtime
- ✅ Snapshot support
- ✅ Thin provisioning

**Setup**:
```bash
# Create physical volumes
pvcreate /dev/sdb1 /dev/sdc1

# Create volume group
vgcreate guardian-storage /dev/sdb1 /dev/sdc1

# Create logical volume (use all space)
lvcreate -l 100%FREE -n recordings guardian-storage

# Format
mkfs.xfs /dev/guardian-storage/recordings

# Mount
mount /dev/guardian-storage/recordings /srv/guardian/recordings

# Add more drives later
pvcreate /dev/sdd1
vgextend guardian-storage /dev/sdd1
lvextend -l +100%FREE /dev/guardian-storage/recordings
xfs_growfs /srv/guardian/recordings
```

## Performance Optimization

### Write Performance

**For HDDs**:
- Use XFS with `logbufs=8,logbsize=256k`
- Align partitions to 1MB boundaries
- Use RAID stripe size that matches segment size
- Disable access time updates (`noatime,nodiratime`)

**For SSDs**:
- Enable TRIM/discard
- Align partitions to erase block size
- Consider disabling journal for ext4 (if OK with risk)
- Use appropriate I/O scheduler (none/noop for NVMe)

### Read Performance

**Parallel reads**:
- Recorder can read from multiple drives simultaneously
- UI fetches different cameras from different drives

**Caching**:
- Keep recent segments in page cache
- OS will naturally cache frequently accessed files

## Storage Calculator

We'll add a storage calculator tool:

```bash
./guardian-storage-calc

Cameras: 8
Resolution (hd/4k/8k): 4k
Recording hours per day: 24
Retention days: 30

Estimated storage required: 63.36 TB
Recommended configuration:
  - 4× 16TB HDDs in RAID 6 (usable: 32TB, allows for growth)
  OR
  - 8× 10TB HDDs in RAID 6 (usable: 60TB)

With compression (if enabled): 44.35 TB
```

## Large Filesystem Support

### ext4 Limits
- Max file size: 16 TB
- Max filesystem size: 1 EB (exabyte)
- Max directory entries: Unlimited (with dir_index)

### XFS Limits
- Max file size: 8 EB
- Max filesystem size: 8 EB
- Max directory entries: 2^64

Both support the largest consumer drives available (20TB+ HDDs, 8TB+ SSDs).

## Security for Large Storage

**Encryption at rest**:
```bash
# LUKS full-disk encryption
cryptsetup luksFormat /dev/sdb1
cryptsetup open /dev/sdb1 recordings-crypt
mkfs.xfs /dev/mapper/recordings-crypt
```

**Considerations**:
- ⚠️ ~10-20% performance overhead
- ⚠️ Requires unlocking on boot (store key on separate USB or use TPM)
- ✅ Protects data if drive is stolen
- ✅ Recommended for sensitive installations

**Alternative**: Client-side encryption for offsite backup only (faster for local storage).

## Testing Large Storage

```bash
# Write test (sequential)
dd if=/dev/zero of=/srv/guardian/recordings/test.bin bs=1M count=10000 oflag=direct
# Should achieve 150-200 MB/s for HDD, 500+ MB/s for SSD

# Read test
dd if=/srv/guardian/recordings/test.bin of=/dev/null bs=1M iflag=direct
# Similar speeds to write

# Random I/O test (for detection workloads)
fio --name=random-read --ioengine=libaio --rw=randread --bs=4k --numjobs=4 --size=1g --directory=/srv/guardian/recordings
```

## Monitoring Tools

```bash
# Filesystem usage
df -h /srv/guardian/recordings

# I/O statistics
iostat -x 1

# SMART status (drive health)
smartctl -a /dev/sdb

# RAID status
cat /proc/mdstat

# LVM status
vgs
lvs
```

## Summary

Guardian supports **enterprise-scale storage**:

✅ **10TB+ HDDs** - XFS filesystem, optimal mount options
✅ **Multi-TB SSDs** - TRIM support, SSD-optimized settings
✅ **RAID arrays** - mdadm RAID 5/6/10 for redundancy
✅ **LVM** - Online resizing, add drives without downtime
✅ **Tiered storage** - SSD + HDD for performance and capacity
✅ **Automatic retention** - Time-based and space-based cleanup
✅ **Storage monitoring** - Capacity, health, performance alerts
✅ **Large filesystem limits** - ext4/XFS support up to exabytes

No artificial limits on storage size. System scales from 1TB to 100TB+ installations.
