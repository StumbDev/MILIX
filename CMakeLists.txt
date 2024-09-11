# Minimum version of CMake
cmake_minimum_required(VERSION 3.0)

# Project name and version
project(MILILX VERSION 1.0)

# Set output directories for binaries
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Include directories
include_directories(include)

# Kernel
add_executable(kernel source/kernel.c)
target_compile_options(kernel PRIVATE -m16)  # Compile in 16-bit mode for DOS

# Shell
add_executable(command source/command.c)

# Text Editor
add_executable(editor source/edit/edit.c)

# Package Manager
add_executable(pkg_manager source/packagemgr/npkg.cpp)



# Path to mtools (adjust if needed)
set(MTOOLS_PATH "C:/path_to/mtools")

# Custom target for creating an image file (.img)
add_custom_target(
  create_img ALL
  COMMAND ${MTOOLS_PATH}/mformat -i ${CMAKE_BINARY_DIR}/mililx.img ::                          # Format as FAT12
  COMMAND ${MTOOLS_PATH}/mmd -i ${CMAKE_BINARY_DIR}/mililx.img ::/boot                         # Create /boot directory
  COMMAND ${MTOOLS_PATH}/mcopy -i ${CMAKE_BINARY_DIR}/mililx.img ${CMAKE_BINARY_DIR}/bin/kernel ::/boot  # Copy kernel to boot sector
  COMMAND ${MTOOLS_PATH}/mcopy -i ${CMAKE_BINARY_DIR}/mililx.img ${CMAKE_BINARY_DIR}/bin/command ::/bin    # Copy shell to bin directory
  COMMAND ${MTOOLS_PATH}/mcopy -i ${CMAKE_BINARY_DIR}/mililx.img ${CMAKE_BINARY_DIR}/bin/edit ::/bin   # Copy text editor to bin directory
  COMMAND ${MTOOLS_PATH}/mcopy -i ${CMAKE_BINARY_DIR}/mililx.img ${CMAKE_BINARY_DIR}/bin/npkg ::/bin  # Copy package manager to bin directory
  COMMENT "Creating mililx.img"
)
