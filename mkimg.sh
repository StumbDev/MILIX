#!/bin/bash

nasm installer.asm
link16 installer.obj
dd if=/dev/zero of=mililx_installer.img bs=512 count=2880
sudo mount -o loop mililx_installer.img /mnt
cp ./build/bin/kernel.com /mnt
cp ./build/bin/busybox.com /mnt
cp ./build/bin/editor.com /mnt
cp ./build/bin/shell.com /mnt
cp ./build/bin/bootscreen.com /mnt
cp ./build/bin/milix.com /mnt
cp ./installer.bat /mnt
sudo umount /mnt