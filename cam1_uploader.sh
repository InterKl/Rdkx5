#!/bin/bash

VID_DIR="/home/sunrise/Desktop/ram_video"
BUCKET="idrive_e2_rdkx5:rdkx5/Chulapat14"

# 1. UPLOAD TO IDRIVE E2
rclone move "$VID_DIR" "$BUCKET" \
    --include "*.mkv" \
    --min-age 6m \
    --transfers 2 \
    --tpslimit 5 \
    --contimeout 60s \
    --timeout 300s \
    --retries 3 \
    --log-file /home/sunrise/rclone_upload.log \
    --log-level INFO

# 2. CHECK DISK USAGE
DISK_USAGE=$(df "$VID_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$DISK_USAGE" -gt 80 ]; then
    echo "WARNING: Disk at ${DISK_USAGE}% - running cleanup!"

    find "$VID_DIR" -type f -name "*.mp4" \
        -printf '%T+ %p\n' | sort | head -n 10 \
        | awk '{print $2}' | xargs -r rm -f
fi
