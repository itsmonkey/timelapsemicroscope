#!/bin/bash

# Default parameters
TARGET_DURATION=24
FIXED_FPS=""
MAXFPS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --duration)
            TARGET_DURATION="$2"
            shift 2
            ;;
        --fps)
            FIXED_FPS="$2"
            shift 2
            ;;
        --maxfps)
            MAXFPS="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Yesterday's date
Y=$(date -d "yesterday" +%Y)
M=$(date -d "yesterday" +%m)
D=$(date -d "yesterday" +%d)

DAYPATH="/var/image/$Y/$M/$D"
OUTFILE="/var/image/videos/${Y}-${M}-${D}.mp4"

# Count frames
COUNT=$(find "$DAYPATH" -type f -name "*.jpg" | wc -l)

if [[ "$COUNT" -lt 2 ]]; then
    echo "Not enough images to build video"
    exit 1
fi

# Determine FPS
if [[ -n "$FIXED_FPS" ]]; then
    FPS="$FIXED_FPS"
else
    FPS=$(echo "$COUNT / $TARGET_DURATION" | bc -l)
fi

# Apply maxfps if set
if [[ -n "$MAXFPS" ]]; then
    FPS=$(awk -v fps="$FPS" -v max="$MAXFPS" 'BEGIN {print (fps>max)?max:fps}')
fi

/usr/bin/ffmpeg -y \
    -framerate "$FPS" \
    -pattern_type glob -i "$DAYPATH/*.jpg" \
    -c:v libx264 -pix_fmt yuv420p \
    "$OUTFILE"
