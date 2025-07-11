#!/bin/bash

target_dir="../rl-swarm"

read -p "Enter the path of the file to move: " source_file

# Check if source file exists
if [ ! -f "$source_file" ]; then
    echo ">> File not found: $source_file"
    exit 1
fi

# Create destination directory if it doesn't exist
if [ ! -d "$target_dir" ]; then
    echo ">> Destination directory not found. Creating: $target_dir"
    mkdir -p "$target_dir"
fi

target_path="$target_dir/swarm.pem"

# Warn if file will be overwritten
if [ -f "$target_path" ]; then
    echo ">> File already exists at destination. It will be overwritten: $target_path"
fi

cp -f "$source_file" "$target_path"

if [ $? -eq 0 ]; then
    echo ">> Successfully recovery swarm.pem"
else
    echo ">> Failed to move file"
fi
