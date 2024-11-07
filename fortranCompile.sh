#!/bin/sh

# Check if the source file is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <source_file.f>"
    exit 1
fi

# Set the source file and output file
SOURCE_FILE="$1"
OUTPUT_FILE="${SOURCE_FILE%.f}.exe"

# Compile the Fortran code using MFC
if mfc -c -Zi -Od -Fo"$OUTPUT_FILE" "$SOURCE_FILE"; then
    echo "Compilation successful. Output file: $OUTPUT_FILE"
else
    echo "Compilation failed."
    exit 1
fi
