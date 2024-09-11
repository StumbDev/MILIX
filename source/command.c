#include <iostream>
#include <string>
#include <vector>
#include <dos.h> // For MS-DOS interrupt handling

void execute_command(const std::string& cmd) {
    if (cmd == "ls") {
        // Call DOS interrupt to list files
        union REGS regs;
        regs.h.ah = 0x4E; // DOS Find First File
        intdos(&regs, &regs);
        std::cout << "Listing files...\n";
    }
    else if (cmd == "exit") {
        exit(0);
    }
    else {
        std::cout << "Unknown command\n";
    }
}

int main() {
    std::string input;
    while (true) {
        std::cout << "mililx> ";
        std::getline(std::cin, input);
        execute_command(input);
    }
    return 0;
}
