#!/bin/bash

# Directories
SRC_DIR=source
BUILD_DIR=build
BIN_DIR=$BUILD_DIR/bin

# Create directories
mkdir -p $BIN_DIR

# Compile source files
echo "Compiling source files..."
gcc -m16 -O2 -Iinclude -c $SRC_DIR/kernel.c -o $BIN_DIR/kernel.o
# Repeat for other source files as needed

# Link object files
echo "Linking object files..."
gcc -m16 -nostartfiles -nostdlib -o $BIN_DIR/kernel $BIN_DIR/kernel.o

# Create disk image
echo "Creating disk image..."
dd if=/dev/zero of=disk.img bs=512 count=2880
mformat -i disk.img ::
mcopy -i disk.img $BIN_DIR/* ::

echo "Build completed successfully."
