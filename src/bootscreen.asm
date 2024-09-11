; Enhanced Boot Screen with Shell Execution - BootScreen.asm

org 100h  ; Origin for .COM file

section .data
    boot_msg db 'Welcome to MILIX!', 0
    boot_sub_msg db 'Initializing...', 0

section .text
start:
    ; Set video mode to 80x25 color text mode
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Set the background color to dark blue and text color to light cyan
    mov ah, 0x0B
    mov bl, 0x1F  ; Light cyan text on dark blue background
    int 0x10

    ; Clear the screen
    mov ah, 0x06
    mov al, 0x00
    mov ch, 0x00
    mov cl, 0x00
    mov dh, 0x19
    mov dl, 0x4F
    int 0x10

    ; Print boot message
    mov ah, 0x0E
    mov si, boot_msg
print_boot_msg:
    lodsb
    cmp al, 0
    je end_print_boot_msg
    int 0x10
    jmp print_boot_msg
end_print_boot_msg:

    ; Print new line
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10

    ; Print initializing message
    mov si, boot_sub_msg
print_boot_sub_msg:
    lodsb
    cmp al, 0
    je end_print_boot_sub_msg
    int 0x10
    jmp print_boot_sub_msg
end_print_boot_sub_msg:

    ; Delay for 2 seconds
    mov cx, 0xFFFF
delay:
    loop delay

    ; Load and execute the shell program (shell.com)
    mov ah, 0x4B       ; DOS function to load and execute a program
    lea dx, [shell_name]
    int 0x21

    ; Exit to DOS if shell execution fails
    mov ah, 0x4C
    int 0x21

section .data
shell_name db 'SHELL.COM', 0
