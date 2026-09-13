#!/bin/bash
# Guardian Storage Calculator
# Calculates storage requirements based on camera configuration

set -e

echo "====================================="
echo " Guardian Storage Calculator"
echo "====================================="
echo ""

# Input
read -p "Number of cameras: " NUM_CAMERAS
read -p "Resolution (hd/4k/8k): " RESOLUTION
read -p "Recording hours per day (24 for continuous): " HOURS_PER_DAY
read -p "Retention days: " RETENTION_DAYS
read -p "Enable compression? (y/n): " COMPRESSION

# Bitrates (Mbps)
case "$RESOLUTION" in
    hd|HD|1080p)
        BITRATE_MBPS=4
        RES_NAME="Full HD (1080p)"
        ;;
    4k|4K|2160p)
        BITRATE_MBPS=25
        RES_NAME="4K (2160p)"
        ;;
    8k|8K|4320p)
        BITRATE_MBPS=100
        RES_NAME="8K (4320p)"
        ;;
    *)
        echo "Unknown resolution. Using HD."
        BITRATE_MBPS=4
        RES_NAME="Full HD (1080p)"
        ;;
esac

# Calculate storage
# Bitrate (Mbps) * Hours * 3600 seconds * Cameras / 8 bits per byte / 1024 MB per GB
GB_PER_DAY=$(echo "scale=2; $BITRATE_MBPS * $HOURS_PER_DAY * 3600 * $NUM_CAMERAS / 8 / 1024" | bc)
TOTAL_GB=$(echo "scale=2; $GB_PER_DAY * $RETENTION_DAYS" | bc)
TOTAL_TB=$(echo "scale=2; $TOTAL_GB / 1024" | bc)

# Compression estimate (typical H.265 gets ~30% savings)
if [[ "$COMPRESSION" == "y" || "$COMPRESSION" == "Y" ]]; then
    COMPRESSED_GB=$(echo "scale=2; $TOTAL_GB * 0.7" | bc)
    COMPRESSED_TB=$(echo "scale=2; $COMPRESSED_GB / 1024" | bc)
fi

echo ""
echo "====================================="
echo " Storage Requirements"
echo "====================================="
echo "Configuration:"
echo "  - Cameras: $NUM_CAMERAS"
echo "  - Resolution: $RES_NAME"
echo "  - Bitrate: $BITRATE_MBPS Mbps per camera"
echo "  - Recording: $HOURS_PER_DAY hours/day"
echo "  - Retention: $RETENTION_DAYS days"
echo ""
echo "Storage per day: $GB_PER_DAY GB"
echo "Total storage required: $TOTAL_GB GB ($TOTAL_TB TB)"
echo ""

if [[ "$COMPRESSION" == "y" || "$COMPRESSION" == "Y" ]]; then
    echo "With H.265 compression (~30% savings):"
    echo "  - Compressed storage: $COMPRESSED_GB GB ($COMPRESSED_TB TB)"
    echo ""
fi

# Recommendations
echo "====================================="
echo " Recommended Configurations"
echo "====================================="

STORAGE_TB_INT=$(echo "$TOTAL_TB" | cut -d. -f1)

if (( $(echo "$TOTAL_TB < 2" | bc -l) )); then
    echo "Single Drive Option:"
    echo "  - 4TB HDD (plenty of headroom)"
    echo "  - 2TB SSD (if performance critical)"
    
elif (( $(echo "$TOTAL_TB < 8" | bc -l) )); then
    echo "Single Drive Option:"
    echo "  - 10TB HDD (recommended)"
    echo "  - 12TB HDD (extra headroom)"
    echo ""
    echo "RAID Option (redundancy):"
    echo "  - 2× 10TB HDDs in RAID 1 (mirror)"
    
elif (( $(echo "$TOTAL_TB < 20" | bc -l) )); then
    echo "RAID Configuration (recommended):"
    echo "  - 3× 10TB HDDs in RAID 5 (usable: 20TB, 1 drive redundancy)"
    echo "  - 2× 12TB HDDs in RAID 1 (usable: 12TB, mirror)"
    echo ""
    echo "Single Drive Option:"
    echo "  - 1× 20TB HDD (no redundancy)"
    
elif (( $(echo "$TOTAL_TB < 40" | bc -l) )); then
    echo "RAID Configuration (recommended):"
    echo "  - 4× 12TB HDDs in RAID 6 (usable: 24TB, 2 drive redundancy)"
    echo "  - 4× 16TB HDDs in RAID 6 (usable: 32TB, 2 drive redundancy)"
    echo ""
    echo "LVM Option (easier expansion):"
    echo "  - 4× 12TB HDDs in LVM (usable: 48TB, no redundancy)"
    
elif (( $(echo "$TOTAL_TB < 80" | bc -l) )); then
    echo "RAID Configuration (recommended):"
    echo "  - 6× 16TB HDDs in RAID 6 (usable: 64TB, 2 drive redundancy)"
    echo "  - 8× 12TB HDDs in RAID 6 (usable: 72TB, 2 drive redundancy)"
    
else
    # Very large installations
    DRIVES_NEEDED=$(echo "scale=0; ($TOTAL_TB / 12) + 2" | bc)
    echo "Enterprise Configuration:"
    echo "  - $DRIVES_NEEDED× 16TB HDDs in RAID 6"
    echo "  - Consider multiple RAID arrays"
    echo "  - Tiered storage: SSD (hot) + HDD (warm) + Cloud (cold)"
    echo ""
    echo "Consult storage specialist for installations > 80TB"
fi

echo ""
echo "====================================="
echo " Filesystem Recommendations"
echo "====================================="
echo "For large HDDs (10TB+):"
echo "  - Filesystem: XFS (best for large files)"
echo "  - Format: mkfs.xfs -f -b size=4096 -m reflink=1 /dev/sdb1"
echo "  - Mount: defaults,noatime,nodiratime,logbufs=8"
echo ""
echo "For SSDs (2TB+):"
echo "  - Filesystem: XFS or ext4"
echo "  - Format: mkfs.xfs -f -K /dev/nvme0n1p1"
echo "  - Mount: defaults,noatime,nodiratime,discard"
echo ""
echo "For RAID arrays:"
echo "  - Use XFS with stripe unit/width tuning"
echo "  - Enable write-back cache for performance"
echo ""
echo "====================================="
echo ""
echo "See docs/STORAGE.md for complete storage setup guide."
echo ""
