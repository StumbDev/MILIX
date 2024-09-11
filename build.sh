#!/bin/bash

# Define directories
BUILD_DIR="build"
BIN_DIR="$BUILD_DIR/bin"
SRC_DIR="source"
INCLUDE_DIR="include"

# Ensure build directories exist
mkdir -p "$BIN_DIR"

# Compile source files
echo "Compiling source files..."
i586-pc-msdosdjgpp-gcc -m16 -O2 -I"$INCLUDE_DIR" -I"$INCLUDE_DIR/miniz" -c "$SRC_DIR/packagemgr/npkg.cpp" -o "$BIN_DIR/npkg.o" || { echo "Failed to compile npkg.cpp"; exit 1; }

# Link object files
echo "Linking object files..."
i586-pc-msdosdjgpp-gcc -m16 -O2 -o "$BIN_DIR/packagemgr" "$BIN_DIR/npkg.o" || { echo "Failed to link object files"; exit 1; }

# Create disk image
echo "Creating disk image..."
dd if=/dev/zero of=disk.img bs=512 count=2880 || { echo "Failed to create disk image"; exit 1; }
mformat -i disk.img :: || { echo "Failed to format disk image"; exit 1; }
mcopy -i disk.img "$BIN_DIR/packagemgr" :: || { echo "Failed to copy files to disk image"; exit 1; }

echo "Build completed successfully."
