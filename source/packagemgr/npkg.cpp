#include <iostream>
#include <string>
#include <filesystem>
#include <miniz.h> // Include the miniz header

namespace fs = std::filesystem;

// Function to extract ZIP file contents
bool extract_zip(const std::string& zip_path, const std::string& dest_dir) {
    mz_zip_archive zip_archive;
    memset(&zip_archive, 0, sizeof(zip_archive));

    // Initialize the zip archive for reading
    if (!mz_zip_reader_init_file(&zip_archive, zip_path.c_str(), 0)) {
        std::cerr << "Failed to open ZIP file: " << zip_path << std::endl;
        return false;
    }

    // Get number of files in the archive
    int file_count = mz_zip_reader_get_num_files(&zip_archive);
    std::cout << "Extracting " << file_count << " files..." << std::endl;

    // Extract each file
    for (int i = 0; i < file_count; ++i) {
        mz_zip_archive_file_stat file_stat;
        if (!mz_zip_reader_file_stat(&zip_archive, i, &file_stat)) {
            std::cerr << "Failed to get file stat for file " << i << std::endl;
            mz_zip_reader_end(&zip_archive);
            return false;
        }

        // Check if it’s a directory or a file
        if (mz_zip_reader_is_file_a_directory(&zip_archive, i)) {
            fs::create_directories(dest_dir + "/" + file_stat.m_filename);
        } else {
            std::string full_path = dest_dir + "/" + file_stat.m_filename;
            std::cout << "Extracting: " << full_path << std::endl;

            if (!mz_zip_reader_extract_to_file(&zip_archive, i, full_path.c_str(), 0)) {
                std::cerr << "Failed to extract file: " << file_stat.m_filename << std::endl;
                mz_zip_reader_end(&zip_archive);
                return false;
            }
        }
    }

    // Close the ZIP archive
    mz_zip_reader_end(&zip_archive);
    return true;
}

int main() {
    std::string zip_file;
    std::string bin_dir = "C:/mililx/bin"; // Change to the actual path of MILILX's bin directory

    // Ask the user for the zip file location
    std::cout << "Enter the path to the package (zip file): ";
    std::cin >> zip_file;

    // Check if the zip file exists
    if (!fs::exists(zip_file)) {
        std::cerr << "Error: ZIP file does not exist!" << std::endl;
        return 1;
    }

    // Create bin directory if it doesn't exist
    if (!fs::exists(bin_dir)) {
        fs::create_directories(bin_dir);
    }

    // Extract the ZIP file to the bin directory
    if (extract_zip(zip_file, bin_dir)) {
        std::cout << "Package installed successfully!" << std::endl;
    } else {
        std::cerr << "Failed to install the package." << std::endl;
    }

    return 0;
}
