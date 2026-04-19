#!/bin/bash

echo "Ran at $(date)" >> /opt/timelapse/cron.log


export PATH=/usr/bin:/bin:/usr/sbin:/sbin
# Base folder where images are stored
BASE="/var/image"

# Work out yesterday's date
Y=$(date -d "yesterday" +%Y)
M=$(date -d "yesterday" +%m)
D=$(date -d "yesterday" +%d)

DAYPATH="$BASE/$Y/$M/$D"
OUTDIR="$BASE/videos"
OUTFILE="$OUTDIR/${Y}-${M}-${D}.mp4"

# Ensure output folder exists
mkdir -p "$OUTDIR"

# Only proceed if the day folder exists and contains images
if [ -d "$DAYPATH" ]; then
    COUNT=$(find "$DAYPATH" -type f -name "*.jpg" | wc -l)
    if [ "$COUNT" -gt 0 ]; then
        /usr/bin/ffmpeg -y -framerate 10 -pattern_type glob -i "$DAYPATH/*.jpg" \
            -c:v libx264 -pix_fmt yuv420p "$OUTFILE"
    fi
fi

