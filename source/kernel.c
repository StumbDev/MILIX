#include <dos.h>  // MS-DOS specific headers
#include <stdio.h> 

void syscall_handler(int syscall_id) {
    switch (syscall_id) {
        case 1: // e.g. SYS_EXIT
            dos_exit();
            break;
        case 2: // e.g. SYS_WRITE
            dos_write();
            break;
        default:
            printf("Unknown syscall\n");
    }
}

void main_kernel_loop() {
    // Main kernel loop
    while(1) {
        int syscall_id = wait_for_syscall();
        syscall_handler(syscall_id);
    }
}

int main() {
    // Kernel initialization
    main_kernel_loop();
    return 0;
}
