#!/usr/bin/env sh

set -e

cat << Introduction
This script will format the *entire* disk with a 512MB boot partition
(labelled NIXBOOT), allocating the rest to ZFS.

The following ZFS datasets will be created:
    - zroot/local/root (mounted at / with blank snapshot)
    - zroot/local/nix (mounted at /nix)
    - zroot/safe/home (mounted at /home with blank snapshot)
    - zroot/safe/persist (mounted at /persist)

Introduction

USESWAP="0";
while true; do
    read -p "Create a swap disk? [y/n] " yn
    case $yn in
        [Yy]* )
            USESWAP="1";
            break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# in a vm, special case
if [[ -b "/dev/vda" ]]; then
DISK="/dev/vda"

BOOTDISK="${DISK}3"
SWAPDISK="${DISK}2"
ZFSDISK="${DISK}1"
# normal disk
else
cat << FormatWarning
Please enter the disk by id to be formatted *without* the part number.
(e.g. nvme-eui.0123456789). Your devices are shown below:

FormatWarning

ls -al /dev/disk/by-id

echo ""

read DISKINPUT

DISK="/dev/disk/by-id/${DISKINPUT}"

BOOTDISK="${DISK}-part3"
SWAPDISK="${DISK}-part2"
ZFSDISK="${DISK}-part1"
fi

echo "Boot Partiton: $BOOTDISK"
if [[ $USESWAP == "1" ]]; then
    echo "SWAP Partiton: $SWAPDISK"
fi
echo "ZFS Partiton: $ZFSDISK"

while true; do
    read -p "This irreversibly formats the entire disk. Are you sure? [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Creating partitions"
sudo sgdisk -Z $DISK
sudo wipefs -a $DISK

sudo sgdisk -n3:1M:+512M -t3:EF00 $DISK
# create swap partition if USESWAP
if [[ $USESWAP == "1" ]]; then
    sudo sgdisk -n2:0:+16G -t2:8200 $DISK
fi
sudo sgdisk -n1:0:0 -t1:BF01 $DISK

# notify kernel of partition changes
sudo sgdisk -p $DISK > /dev/null
sleep 5

if [[ $USESWAP == "1" ]]; then
    echo "Creating Swap"
    sudo mkswap $SWAPDISK
    sudo swaplabel --label "SWAP" $SWAPDISK
    sudo swapon $SWAPDISK
fi
echo "Creating Boot Disk"
sudo mkfs.fat -F 32 $BOOTDISK
sudo fatlabel $BOOTDISK NIXBOOT

echo "Creating base zpool"
sudo zpool create -f \
    -o ashift=12 \
    -o autotrim=on \
    -O compression=on \
    -O acltype=posixacl \
    -O atime=off \
    -O xattr=sa \
    -O normalization=formD \
    -O mountpoint=none \
    zroot $ZFSDISK

# create top level datasets
sudo zfs create -o mountpoint=legacy zroot/local
sudo zfs create -o mountpoint=legacy zroot/safe

echo "Creating /"
sudo zfs create -o mountpoint=legacy zroot/local/root
sudo zfs snapshot zroot/local/root@blank
sudo mount -t zfs zroot/local/root /mnt

echo "Mounting /boot (efi)"
sudo mkdir -p /mnt/boot
sudo mount $BOOTDISK /mnt/boot

echo "Creating /nix"
sudo zfs create -o mountpoint=legacy zroot/local/nix
sudo mkdir -p /mnt/nix
sudo mount -t zfs zroot/local/nix /mnt/nix

echo "Creating /home"
sudo zfs create -o mountpoint=legacy zroot/safe/home
sudo zfs snapshot zroot/safe/home@blank
sudo mkdir -p /mnt/home
sudo mount -t zfs zroot/safe/home /mnt/home

echo "Creating /persist"
sudo zfs create -o mountpoint=legacy zroot/safe/persist
sudo mkdir -p /mnt/persist
sudo mount -t zfs zroot/safe/persist /mnt/persist