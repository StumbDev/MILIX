; editor.asm
org 0x100

; Print message
mov ah, 0x0E
mov al, 'E'
int 0x10

mov al, 'd'
int 0x10

mov al, 'i'
int 0x10

mov al, 't'
int 0x10

mov al, 'o'
int 0x10

mov al, 'r'
int 0x10

mov al, ' '
int 0x10

mov al, 'E'
int 0x10

mov al, 'd'
int 0x10

mov al, 'i'
int 0x10

mov al, 't'
int 0x10

mov al, 'o'
int 0x10

mov al, 'r'
int 0x10

mov al, 0x0D          ; Carriage return
int 0x10

mov al, 0x0A          ; Line feed
int 0x10

; Read and echo input
read_loop:
    mov ah, 0x00     ; Read character
    int 0x16         ; BIOS keyboard interrupt
    mov ah, 0x0E     ; Print character
    int 0x10         ; BIOS video interrupt
    cmp al, 0x1B     ; ESC key to exit
    je exit
    jmp read_loop

exit:
    mov ah, 0x4C     ; Terminate program
    int 0x21

times 510 - ($ - $$) db 0
dw 0xAA55
