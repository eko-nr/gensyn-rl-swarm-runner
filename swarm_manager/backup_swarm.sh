#!/bin/bash

target_dir="../rl-swarm/swarm.pem"
backup_dir="../backup"

# Check if source file exists
if [ ! -f "$target_dir" ]; then
    echo ">> File not found: $target_dir"
    exit 1
fi

# Create destination directory if it doesn't exist
if [ ! -d "$backup_dir" ]; then
    echo ">> Destination directory not found. Creating: $backup_dir"
    mkdir -p "$backup_dir"
fi

backup_path="$backup_dir/swarm.pem"

# Warn if file will be overwritten
if [ -f "$backup_path" ]; then
    echo ">> File already exists at destination. It will be overwritten: $backup_path"
fi

# Move with overwrite
mv -f "$target_dir" "backup_path"

if [ $? -eq 0 ]; then
    echo ">> Successfully recovery swarm.pem"
else
    echo ">> Failed to move file"
fi
