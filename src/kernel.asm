; kernel.asm
org 0x100                ; Origin - code starts at address 0x100

; Print message
mov ah, 0x0E             ; BIOS teletype function
mov al, 'K'
int 0x10

mov al, 'e'
int 0x10

mov al, 'r'
int 0x10

mov al, 'n'
int 0x10

mov al, 'e'
int 0x10

mov al, 'l'
int 0x10

mov al, ' '
int 0x10

mov al, 'R'
int 0x10

mov al, 'u'
int 0x10

mov al, 'n'
int 0x10

mov al, 'n'
int 0x10

mov al, 'i'
int 0x10

mov al, 'n'
int 0x10

mov al, 'g'
int 0x10

mov al, ' '
int 0x10

mov al, 'K'
int 0x10

mov al, 'e'
int 0x10

mov al, 'r'
int 0x10

mov al, 'n'
int 0x10

mov al, 'e'
int 0x10

mov al, 'l'
int 0x10

mov al, ' '
int 0x10

mov al, 'P'
int 0x10

mov al, 'r'
int 0x10

mov al, 'e'
int 0x10

mov al, 's'
int 0x10

mov al, 's'
int 0x10

mov al, ' '
int 0x10

mov al, 'a'
int 0x10

mov al, ' '
int 0x10

mov al, 'k'
int 0x10

mov al, 'e'
int 0x10

mov al, 'y'
int 0x10

mov al, '.'
int 0x10

mov al, 0x0D          ; Carriage return
int 0x10

mov al, 0x0A          ; Line feed
int 0x10

; Wait for key press
mov ah, 0x00         ; Wait for key press
int 0x16             ; BIOS keyboard interrupt

; Exit to DOS
mov ah, 0x4C         ; Terminate program
int 0x21             ; DOS interrupt

times 510 - ($ - $$) db 0
dw 0xAA55            ; Boot signature
