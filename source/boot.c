#include "dos.h"    // For DOS interrupt and delay
#include "conio.h"  // For text output functions
#include "time.h"   // For timing functions

// Video memory location for text mode
#define VIDEO_MEMORY 0xB800

// Define color codes
#define WHITE_ON_BLUE 0x1F  // White text on blue background
#define WHITE_ON_PURPLE 0x5F // White text on purple background

// Function to clear the screen and set the background color
void clear_screen_with_color(unsigned char color) {
    unsigned char far* video_memory = (unsigned char far*)VIDEO_MEMORY;
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        video_memory[i] = ' '; // Set space character
        video_memory[i + 1] = color; // Set the background color
    }
}

// Function to print text at specific position with color
void print_at(int row, int col, const char* text, unsigned char color) {
    unsigned char far* video_memory = (unsigned char far*)VIDEO_MEMORY;
    int offset = (row * 80 + col) * 2; // Calculate position in video memory
    while (*text) {
        video_memory[offset] = *text; // ASCII character
        video_memory[offset + 1] = color; // Color attribute
        offset += 2;
        text++;
    }
}

// Function to display the progress bar
void show_progress_bar(int duration_seconds) {
    unsigned char far* video_memory = (unsigned char far*)VIDEO_MEMORY;
    int bar_length = 40; // Progress bar is 40 characters long
    int row = 12, col = 20; // Position of the progress bar
    int delay_per_segment = duration_seconds * 1000 / bar_length; // Calculate delay per segment

    // Draw the empty progress bar
    for (int i = 0; i < bar_length; i++) {
        video_memory[((row * 80) + col + i) * 2] = ' '; // Empty space for progress bar
        video_memory[((row * 80) + col + i) * 2 + 1] = WHITE_ON_BLUE; // Blue background
    }

    // Fill the progress bar over time
    for (int i = 0; i < bar_length; i++) {
        delay(delay_per_segment); // Delay for progress bar animation
        video_memory[((row * 80) + col + i) * 2] = ' '; // Progress bar filled with space
        video_memory[((row * 80) + col + i) * 2 + 1] = WHITE_ON_PURPLE; // Purple background
    }
}

void show_boot_screen() {
    // Clear screen with blue background
    clear_screen_with_color(WHITE_ON_BLUE);

    // Display the boot message
    print_at(10, 30, "MILILX Booting...", WHITE_ON_BLUE);

    // Display the progress bar (takes 12 seconds to load)
    show_progress_bar(12);

    // Display "Boot Complete" message after progress bar finishes
    print_at(14, 25, "Boot complete. Press any key to continue...", WHITE_ON_BLUE);
    getch(); // Wait for user input
}

int main() {
    // Show the boot screen
    show_boot_screen();

    // Continue with the rest of the OS initialization
    return 0;
}
