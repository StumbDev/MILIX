#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h> // For MS-DOS interrupt handling

void execute_command(const char *cmd) {
    if (strcmp(cmd, "ls") == 0) {
        // Call DOS interrupt to list files (dummy implementation)
        union REGS regs;
        regs.h.ah = 0x4E; // DOS Find First File
        intdos(&regs, &regs);
        printf("Listing files...\n");
    } 
    else if (strcmp(cmd, "exit") == 0) {
        exit(0);
    }
    else {
        printf("Unknown command\n");
    }
}

int main() {
    char input[256];
    while (1) {
        printf("# ");
        fgets(input, sizeof(input), stdin);
        // Remove newline character if present
        input[strcspn(input, "\n")] = '\0';
        execute_command(input);
    }
    return 0;
}
