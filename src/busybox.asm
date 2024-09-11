; busybox.asm
org 0x100

; Print a message
mov ah, 0x0E
mov al, 'B'
int 0x10

mov al, 'u'
int 0x10

mov al, 's'
int 0x10

mov al, 'y'
int 0x10

mov al, 'B'
int 0x10

mov al, 'o'
int 0x10

mov al, 'x'
int 0x10

mov al, ' '
int 0x10

mov al, 'I'
int 0x10

mov al, 'm'
int 0x10

mov al, 'p'
int 0x10

mov al, 'l'
int 0x10

mov al, 'e'
int 0x10

mov al, 'm'
int 0x10

mov al, 'e'
int 0x10

mov al, 'n'
int 0x10

mov al, 't'
int 0x10

mov al, 0x0D          ; Carriage return
int 0x10

mov al, 0x0A          ; Line feed
int 0x10

; Wait for key press
mov ah, 0x00
int 0x16

; Exit to DOS
mov ah, 0x4C
int 0x21

times 510 - ($ - $$) db 0
dw 0xAA55
