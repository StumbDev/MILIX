; shell.asm
org 0x100

mov ah, 0x0E
mov al, '#'
int 0x10

; Loop to read input and echo it
read_loop:
    mov ah, 0x00       ; Read character function
    int 0x16           ; BIOS keyboard interrupt
    mov ah, 0x0E       ; Print character function
    int 0x10           ; BIOS video interrupt
    cmp al, 0x1B       ; ESC key to exit
    je exit
    jmp read_loop

exit:
    mov ah, 0x4C       ; Terminate program function
    int 0x21

times 510 - ($ - $$) db 0
dw 0xAA55
