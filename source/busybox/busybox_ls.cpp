#include "dos.h" // For DOS interrupts

void ls_command() {
    // DOS Find First File interrupt (int 0x21, AH=0x4E)
    struct REGPACK regs;
    regs.r_ax = 0x4E00; // Find First File function
    regs.r_dx = (unsigned int)"*.*"; // File mask
    intr(0x21, &regs); // Call DOS interrupt

    if (regs.r_ax == 0) {
        std::cout << "Files in current directory:" << std::endl;
        // List files here (you need to fetch file details and print)
    } else {
        std::cout << "No files found" << std::endl;
    }
}
