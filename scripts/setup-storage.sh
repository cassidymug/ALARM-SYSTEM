#!/bin/bash
# Guardian Storage Setup Helper
# Interactive script to format and mount large drives

set -e

echo "====================================="
echo " Guardian Storage Setup"
echo "====================================="
echo ""
echo "WARNING: This script will FORMAT drives!"
echo "All data will be LOST!"
echo ""
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Available drives:"
lsblk -d -o NAME,SIZE,TYPE | grep disk

echo ""
read -p "Drive to format (e.g., sdb): " DRIVE
DEVICE="/dev/$DRIVE"

if [ ! -b "$DEVICE" ]; then
    echo "Error: $DEVICE is not a block device"
    exit 1
fi

echo ""
echo "Filesystem type:"
echo "  1) XFS (recommended for HDDs 10TB+)"
echo "  2) ext4 (good all-around)"
read -p "Choice (1/2): " FS_CHOICE

case $FS_CHOICE in
    1)
        FS_TYPE="xfs"
        ;;
    2)
        FS_TYPE="ext4"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "Drive type:"
echo "  1) HDD (spinning disk)"
echo "  2) SSD (solid state)"
read -p "Choice (1/2): " DRIVE_TYPE

echo ""
echo "====================================="
echo " Summary"
echo "====================================="
echo "Device: $DEVICE"
echo "Filesystem: $FS_TYPE"
echo "Drive type: $DRIVE_TYPE"
echo ""
read -p "FORMAT NOW? (yes/no): " FINAL_CONFIRM

if [ "$FINAL_CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Creating partition..."
parted -s $DEVICE mklabel gpt
parted -s $DEVICE mkpart primary 0% 100%
partprobe $DEVICE
sleep 2

PARTITION="${DEVICE}1"

echo "Formatting $PARTITION as $FS_TYPE..."

if [ "$FS_TYPE" == "xfs" ]; then
    if [ "$DRIVE_TYPE" == "2" ]; then
        # SSD optimizations
        mkfs.xfs -f -K $PARTITION
    else
        # HDD optimizations
        mkfs.xfs -f -b size=4096 -m reflink=1,crc=1 -i size=512 $PARTITION
    fi
elif [ "$FS_TYPE" == "ext4" ]; then
    if [ "$DRIVE_TYPE" == "2" ]; then
        # SSD optimizations (no journal)
        mkfs.ext4 -F -O ^has_journal -E nodiscard $PARTITION
    else
        # HDD standard
        mkfs.ext4 -F $PARTITION
    fi
fi

echo ""
echo "Creating mount point..."
MOUNT_POINT="/srv/guardian/recordings"
mkdir -p $MOUNT_POINT

echo "Getting UUID..."
UUID=$(blkid -s UUID -o value $PARTITION)

echo ""
echo "====================================="
echo " Setup Complete"
echo "====================================="
echo "Partition: $PARTITION"
echo "UUID: $UUID"
echo "Mount point: $MOUNT_POINT"
echo ""
echo "Add to /etc/fstab:"

if [ "$FS_TYPE" == "xfs" ]; then
    if [ "$DRIVE_TYPE" == "2" ]; then
        # SSD mount options
        echo "UUID=$UUID  $MOUNT_POINT  xfs  defaults,noatime,nodiratime,discard  0  2"
    else
        # HDD mount options
        echo "UUID=$UUID  $MOUNT_POINT  xfs  defaults,noatime,nodiratime,logbufs=8,logbsize=256k  0  2"
    fi
elif [ "$FS_TYPE" == "ext4" ]; then
    if [ "$DRIVE_TYPE" == "2" ]; then
        # SSD mount options
        echo "UUID=$UUID  $MOUNT_POINT  ext4  defaults,noatime,nodiratime,discard  0  2"
    else
        # HDD mount options
        echo "UUID=$UUID  $MOUNT_POINT  ext4  defaults,noatime,nodiratime  0  2"
    fi
fi

echo ""
echo "Mount now:"
echo "  mount $PARTITION $MOUNT_POINT"
echo ""
echo "Or add to fstab and:"
echo "  mount -a"
echo ""
echo "Set permissions:"
echo "  chown -R guardian:guardian $MOUNT_POINT"
echo "  chmod 750 $MOUNT_POINT"
echo ""
