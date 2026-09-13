# Large Storage Configuration Examples

## Example 1: Single 10TB HDD

### /etc/fstab
```
UUID=xxxx-xxxx  /srv/guardian/recordings  xfs  defaults,noatime,nodiratime,logbufs=8,logbsize=256k  0  2
```

### site.json
```json
{
  "storage": {
    "recordings_path": "/srv/guardian/recordings",
    "max_storage_gb": 9500,
    "min_free_space_gb": 500,
    "cleanup_threshold_gb": 600,
    "retention": {
      "continuous_days": 60,
      "events_days": 90,
      "important_days": 365
    }
  }
}
```

**Use case**: Small home, 4-6 cameras, Full HD/4K mix


## Example 2: 4× 12TB HDDs in RAID 6

### Setup
```bash
# Create RAID 6 (usable: ~24TB)
mdadm --create /dev/md0 --level=6 --raid-devices=4 /dev/sd[b-e]1

# Format with XFS optimized for RAID
mkfs.xfs -f -d su=256k,sw=2 /dev/md0

# Mount
mount /dev/md0 /srv/guardian/recordings
```

### /etc/fstab
```
/dev/md0  /srv/guardian/recordings  xfs  defaults,noatime,nodiratime,logbufs=8,logbsize=256k  0  2
```

### /etc/mdadm/mdadm.conf
```
ARRAY /dev/md0 metadata=1.2 name=guardian:0 UUID=xxxx-xxxx
```

### site.json
```json
{
  "storage": {
    "recordings_path": "/srv/guardian/recordings",
    "max_storage_gb": 23000,
    "min_free_space_gb": 1000,
    "cleanup_threshold_gb": 1500,
    "retention": {
      "continuous_days": 45,
      "events_days": 120,
      "important_days": 365
    }
  }
}
```

**Use case**: Medium-large home, 8-12 cameras, 4K, with redundancy


## Example 3: Tiered Storage (SSD + HDD)

### Setup
```bash
# Format SSD for hot tier (recent 7 days)
mkfs.xfs -f -K /dev/nvme0n1p1
mount /dev/nvme0n1p1 /srv/guardian/recordings/hot

# Format HDD array for warm tier (8-30 days)
mdadm --create /dev/md0 --level=6 --raid-devices=4 /dev/sd[b-e]1
mkfs.xfs -f -d su=256k,sw=2 /dev/md0
mount /dev/md0 /srv/guardian/recordings/warm
```

### /etc/fstab
```
UUID=xxxx  /srv/guardian/recordings/hot   xfs  defaults,noatime,discard        0  2
/dev/md0   /srv/guardian/recordings/warm  xfs  defaults,noatime,logbufs=8      0  2
```

### site.json
```json
{
  "storage": {
    "recordings_path": "/srv/guardian/recordings",
    "tiers": [
      {
        "name": "hot",
        "path": "/srv/guardian/recordings/hot",
        "max_age_days": 7,
        "max_storage_gb": 1500
      },
      {
        "name": "warm",
        "path": "/srv/guardian/recordings/warm",
        "max_age_days": 30,
        "max_storage_gb": 20000
      }
    ]
  }
}
```

**Use case**: Large property, 16+ cameras, 4K/8K, needs fast access to recent recordings


## Example 4: LVM for Easy Expansion

### Setup
```bash
# Create physical volumes
pvcreate /dev/sdb1 /dev/sdc1 /dev/sdd1

# Create volume group
vgcreate guardian-storage /dev/sdb1 /dev/sdc1 /dev/sdd1

# Create logical volume (90% of space, leave room for growth)
lvcreate -l 90%FREE -n recordings guardian-storage

# Format
mkfs.xfs /dev/guardian-storage/recordings

# Mount
mount /dev/guardian-storage/recordings /srv/guardian/recordings
```

### /etc/fstab
```
/dev/guardian-storage/recordings  /srv/guardian/recordings  xfs  defaults,noatime,nodiratime,logbufs=8  0  2
```

### Expand later (add another drive)
```bash
# Add new drive
pvcreate /dev/sde1
vgextend guardian-storage /dev/sde1

# Grow logical volume
lvextend -l +100%FREE /dev/guardian-storage/recordings

# Grow filesystem (online, no downtime!)
xfs_growfs /srv/guardian/recordings
```

### site.json
```json
{
  "storage": {
    "recordings_path": "/srv/guardian/recordings",
    "max_storage_gb": 0,
    "min_free_space_gb": 1000,
    "cleanup_threshold_gb": 1500,
    "retention": {
      "continuous_days": 30,
      "events_days": 90,
      "important_days": 365
    }
  }
}
```

**Use case**: Any size, prioritizes easy expansion over redundancy


## Example 5: Encrypted Large Storage

### Setup
```bash
# Encrypt drive with LUKS
cryptsetup luksFormat /dev/sdb1
cryptsetup open /dev/sdb1 recordings-crypt

# Format encrypted volume
mkfs.xfs /dev/mapper/recordings-crypt

# Mount
mount /dev/mapper/recordings-crypt /srv/guardian/recordings
```

### /etc/crypttab
```
recordings-crypt  /dev/sdb1  none  luks
```

### /etc/fstab
```
/dev/mapper/recordings-crypt  /srv/guardian/recordings  xfs  defaults,noatime,nodiratime  0  2
```

### site.json
```json
{
  "storage": {
    "recordings_path": "/srv/guardian/recordings",
    "encrypted": true,
    "max_storage_gb": 9500,
    "min_free_space_gb": 500,
    "cleanup_threshold_gb": 600,
    "retention": {
      "continuous_days": 30,
      "events_days": 90,
      "important_days": 180
    }
  }
}
```

**Use case**: Sensitive installations, requires encryption at rest


## Storage Monitoring Script

Save as `/usr/local/bin/guardian-storage-check`:

```bash
#!/bin/bash
# Guardian storage health check

MOUNT_POINT="/srv/guardian/recordings"
ALERT_THRESHOLD=10  # Alert when free space < 10%

# Get filesystem stats
TOTAL=$(df -BG "$MOUNT_POINT" | tail -1 | awk '{print $2}' | sed 's/G//')
USED=$(df -BG "$MOUNT_POINT" | tail -1 | awk '{print $3}' | sed 's/G//')
FREE=$(df -BG "$MOUNT_POINT" | tail -1 | awk '{print $4}' | sed 's/G//')
PERCENT=$(df "$MOUNT_POINT" | tail -1 | awk '{print $5}' | sed 's/%//')

echo "Guardian Storage Status"
echo "======================="
echo "Total: ${TOTAL}GB"
echo "Used:  ${USED}GB"
echo "Free:  ${FREE}GB"
echo "Used:  ${PERCENT}%"

FREE_PERCENT=$((100 - PERCENT))

if [ $FREE_PERCENT -lt $ALERT_THRESHOLD ]; then
    echo ""
    echo "⚠️  WARNING: Low disk space!"
    logger -t guardian-storage "WARNING: Low disk space - ${FREE}GB free (${FREE_PERCENT}%)"
fi

# SMART status for physical drives
if command -v smartctl &> /dev/null; then
    echo ""
    echo "Drive Health (SMART):"
    for drive in $(lsblk -d -o NAME | grep -E '^sd|^nvme'); do
        HEALTH=$(smartctl -H /dev/$drive 2>/dev/null | grep "SMART overall-health" | awk '{print $NF}')
        if [ -n "$HEALTH" ]; then
            echo "  /dev/$drive: $HEALTH"
        fi
    done
fi
```

Add to cron for hourly monitoring:
```bash
0 * * * * /usr/local/bin/guardian-storage-check
```


## Performance Benchmarks

### Write Test (4K video segment simulation)
```bash
# Sequential write test
fio --name=video-write --rw=write --bs=4M --size=10G --numjobs=4 \
    --directory=/srv/guardian/recordings --group_reporting

# Target: 150+ MB/s for HDD, 500+ MB/s for SSD
```

### Read Test (playback simulation)
```bash
# Sequential read test
fio --name=video-read --rw=read --bs=4M --size=10G --numjobs=4 \
    --directory=/srv/guardian/recordings --group_reporting

# Target: 180+ MB/s for HDD, 500+ MB/s for SSD
```

### Mixed Workload (recording + playback)
```bash
# 70% write, 30% read
fio --name=mixed --rw=randrw --rwmixwrite=70 --bs=4M --size=5G \
    --numjobs=4 --directory=/srv/guardian/recordings --group_reporting

# Target: 100+ MB/s for HDD RAID, 300+ MB/s for SSD
```


## Troubleshooting

### "No space left on device" but df shows free space

**Cause**: Inode exhaustion (too many small files)

**Fix**:
```bash
# Check inodes
df -i /srv/guardian/recordings

# If inodes exhausted, increase segment size in recorder config
# to create fewer, larger files
```

### Slow write performance

**Causes**:
1. Drive health issues
2. Filesystem fragmentation
3. RAID resync in progress
4. I/O scheduler not optimized

**Checks**:
```bash
# Drive health
smartctl -a /dev/sdb

# RAID status
cat /proc/mdstat

# I/O stats
iostat -x 1

# Filesystem fragmentation (XFS)
xfs_db -r -c frag /dev/sdb1
```

### Drive failure in RAID

**Detection**:
```bash
cat /proc/mdstat
# Look for [U_] or [_U] (underscore = failed drive)
```

**Replace drive**:
```bash
# Mark failed
mdadm --manage /dev/md0 --fail /dev/sdb1
mdadm --manage /dev/md0 --remove /dev/sdb1

# Physical replacement...

# Add new drive
mdadm --manage /dev/md0 --add /dev/sdf1

# Monitor rebuild
watch cat /proc/mdstat
```


## Summary

Guardian supports **unlimited storage size**:
- ✅ Single drives: 10TB, 12TB, 16TB, 20TB+
- ✅ RAID arrays: 50TB, 100TB, 200TB+
- ✅ LVM for online expansion
- ✅ Tiered storage (SSD + HDD)
- ✅ Encryption support
- ✅ Automatic retention policies
- ✅ Storage monitoring and alerts

No artificial limits - scale to your needs!
