#!/bin/bash

DEBUG=1

let error=0
let fError=0
errorStr="ERROR..."
blockSz="1024"

diskutil list

echo -e "Please type in the Device Path (example: /dev/desk4) and press ENTER"
echo -e "Hint: Check the list of drives above and pick the DVD drive"
echo -e "Hint: if you can't figure it out you can leave this blank for auto mode"
read device
echo -e "Please drag in the destination folder and press ENTER"
read destDir
echo -e "Please enter the DVD Title and press ENTER"
read title

dateStr=`date`
if [[ -z $device ]]; then
  device=$(diskutil list | grep -A 2 "external, physical" | tail -n 1 | awk '{print $NF}')
fi

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
        echo -e "mavisNum =\t$title"
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

ddrescue -b $blockSz $device "${destDir}/${title}.iso" "${destDir}/${title}.iso.log"

drutil eject

exit 0
