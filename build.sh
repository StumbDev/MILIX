#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p ./build/bin

# Assemble the busybox
nasm -f bin ./src/busybox.asm -o ./build/bin/busybox.com

nasm -f bin ./src/shell.asm -o ./build/bin/milix.com

echo "Build completed successfully."

