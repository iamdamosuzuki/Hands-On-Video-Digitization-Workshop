#!/bin/bash
# Script for ripping DVDs and BluRay Discs
# Works on any disc, including copy protected DVDs
# Meant to work on Morgan's macbook pro, but will work on other macs as well.
# started 4/24/23, mmorel
# v1.0
#   Works with user input of disk drive
# v.2.0
#   Assumes the device by looking for "external, phsyical" in the diskutil drive list
#   Isues unmountDisk option if unmount doesn't work, this helps with non-video DVDs

DEBUG=1

let error=0
let fError=0
errorStr="ERROR..."
blockSz="1024"

let i=0

#device="/dev/sr2"

if [ "$#" -ne 2 ]; then
        echo ""
        echo "USAGE: $0 <source> MAVIS_Number <destination directory>"
        echo "Example:>$0 1234567-1-1 /tmp/iso"
        echo "Remember that your user must have read/write permisson for the destination directory."
        exit 1
fi

if ! [[ $1 =~ [0-9]{7}-[0-9]{1}-[0-9]{1} ]]; then
    echo "WARNING: Please enter a valid MAVIS Number"
fi

mavisNum="$1"
device="$1"
destDir="$2"
dateStr=`date`
device=$(diskutil list | grep -A 2 "external, physical" | tail -n 1 | awk '{print $NF}')

if [[ $device == *"disk"* ]]; then
    echo "Processing disc in device: "$device
else
    echo $device
    echo "Disk device path not found. Please enter disk device path (example: /dev/disk4)"
    read device
fi
if [[ $device == *"/dev/"* ]]; then
    echo "Processing disc in device: "$device
else
    device="/dev/"$device
    echo "Processing disc in device: "$device
fi

ls $device
RESULT0=$?

if [ $RESULT0 -eq 0 ]; then
    echo "Device found!"
else
    echo "Unable to find device: $device Exiting script."
    exit 0
fi

#mountedStr=`df -P "$device"`
#title="${mountedStr##*/}"

if (( DEBUG == 1 ));then
        echo -e "mavisNum =\t$mavisNum"
        echo -e "device\t=\t$device"
        echo -e "Destination Directory\t=\t$destDir"
        echo -e "date\t=\t$dateStr"
        #echo -e "mount String \t=\t$mountedStr"
        #echo -e "title \t=\t$title"
    fi
#exit 0

diskutil unmount "$device"
RESULT=$?

if [ $RESULT -eq 0 ]; then
    echo "Success Unmounting"
else
    echo "Failed to unmount normally, trying unmountDisk method."
    diskutil unmountDisk "$device"
    RESULT2=$?
    if [ $RESULT2 -eq 0 ]; then
        echo "Success Unmounting"
    else
        echo "Failed to unmount using unmountDisk method. Exiting script."
        exit 0
    fi
fi

ddrescue -b 2048 $device "${destDir}/${mavisNum}.iso" "${destDir}/${mavisNum}.iso.log"

drutil eject

exit 0
