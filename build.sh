#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p ./build/bin

# Assemble the kernel
nasm -f bin ./src/kernel.asm -o ./build/bin/kernel.com

# Assemble the busybox
nasm -f bin ./src/busybox.asm -o ./build/bin/busybox.com

# Assemble the editor
nasm -f bin ./src/editor.asm -o ./build/bin/editor.com

# Assemble the shell
nasm -f bin ./src/shell.asm -o ./build/bin/shell.com

# Assemble the boot screen
nasm -f bin ./src/bootscreen.asm -o ./build/bin/bootscreen.com

# Assemble the kernel Manager

nasm -f bin ./src/KernelManager.asm -o ./build/bin/kernelmgr.com

# Assemble the bootstrap loader
nasm -f bin ./src/milix.asm -o ./build/bin/milix.com

echo "Build completed successfully."
