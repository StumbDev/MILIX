#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>  // For getch() and other console functions

#define MAX_ROWS 25
#define MAX_COLS 80
#define MAX_BUFFER 1024

// Data structure to hold the text buffer
char buffer[MAX_ROWS][MAX_COLS]; // Text buffer with 25 rows and 80 columns

// Cursor position
int cursor_row = 0, cursor_col = 0;

// Function to load a file into the buffer
void load_file(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        printf("File not found, starting with a new file.\n");
        return;
    }
    
    char line[MAX_COLS];
    int row = 0;
    while (fgets(line, MAX_COLS, file) && row < MAX_ROWS) {
        strcpy(buffer[row], line);
        buffer[row][strcspn(buffer[row], "\n")] = '\0'; // Remove newline character
        row++;
    }
    
    fclose(file);
    printf("File loaded successfully.\n");
}

// Function to save the buffer into a file
void save_file(const char *filename) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        printf("Error saving file.\n");
        return;
    }

    for (int i = 0; i < MAX_ROWS; i++) {
        fprintf(file, "%s\n", buffer[i]);
    }

    fclose(file);
    printf("File saved successfully.\n");
}

// Function to display the text buffer on the screen
void display_buffer() {
    system("cls"); // Clear the console
    for (int i = 0; i < MAX_ROWS; i++) {
        printf("%s\n", buffer[i]);
    }

    // Move the cursor back to the current editing position
    gotoxy(cursor_col + 1, cursor_row + 1);
}

// Function to handle user input
void handle_input(char *filename) {
    char ch;
    while (1) {
        ch = getch();
        
        // Arrow key navigation
        if (ch == 0 || ch == 0xE0) { // Arrow keys
            ch = getch();
            switch (ch) {
                case 72: // Up
                    if (cursor_row > 0) cursor_row--;
                    break;
                case 80: // Down
                    if (cursor_row < MAX_ROWS - 1) cursor_row++;
                    break;
                case 75: // Left
                    if (cursor_col > 0) cursor_col--;
                    break;
                case 77: // Right
                    if (cursor_col < strlen(buffer[cursor_row])) cursor_col++;
                    break;
            }
        } 
        else if (ch == 27) { // ESC key to quit
            printf("\nDo you want to save the file before quitting? (y/n): ");
            char confirm = getch();
            if (confirm == 'y' || confirm == 'Y') {
                save_file(filename);
            }
            break;
        }
        else if (ch == 13) { // Enter key
            if (cursor_row < MAX_ROWS - 1) {
                cursor_row++;
                cursor_col = 0;
            }
        }
        else if (ch == 8) { // Backspace key
            if (cursor_col > 0) {
                memmove(&buffer[cursor_row][cursor_col - 1], &buffer[cursor_row][cursor_col], strlen(&buffer[cursor_row][cursor_col]) + 1);
                cursor_col--;
            }
        }
        else { // Normal character input
            if (cursor_col < MAX_COLS - 1) {
                memmove(&buffer[cursor_row][cursor_col + 1], &buffer[cursor_row][cursor_col], strlen(&buffer[cursor_row][cursor_col]) + 1);
                buffer[cursor_row][cursor_col] = ch;
                cursor_col++;
            }
        }

        display_buffer(); // Refresh the display after each input
    }
}

int main() {
    char filename[100];
    
    // Ask the user for the file to open/edit
    printf("Enter the file name to edit: ");
    scanf("%s", filename);
    
    // Initialize the buffer with empty spaces
    for (int i = 0; i < MAX_ROWS; i++) {
        memset(buffer[i], ' ', MAX_COLS);
        buffer[i][MAX_COLS - 1] = '\0'; // Null-terminate each line
    }

    // Load the file if it exists
    load_file(filename);

    // Display the buffer for the first time
    display_buffer();

    // Start handling user input for editing
    handle_input(filename);

    return 0;
}
