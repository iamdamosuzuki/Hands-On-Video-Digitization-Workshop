#!/bin/bash
# Launcher for discRipper_mac script
# Runs the discRipper with a hardcoded output folder, then asks for MAVIS number

pgmRoot=$(dirname "$(readlink -f "$0")")
scriptPath=$pgmRoot/"discRipper_mac.sh"
outPath="/Users/mmorel/Documents/Disc Workflows/dvd rip"
echo "Please enter the MAVIS number"
read mavis
/bin/bash $scriptPath $mavis "$outPath"
