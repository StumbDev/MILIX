; installer.asm
org 100h

; Setup the screen
mov ah, 0x02
mov bh, 0x00
mov dh, 0
mov dl, 0
int 10h

; Display a message
mov ah, 0x0E
mov al, 'I'
mov bh, 0
mov bl, 0x07
int 10h

mov al, 'n'
int 10h

mov al, 's'
int 10h

mov al, 't'
int 10h

mov al, 'a'
int 10h

mov al, 'l'
int 10h

mov al, 'l'
int 10h

mov al, 'i'
int 10h

mov al, 'n'
int 10h

mov al, 'g'
int 10h

mov al, ' '
int 10h

mov al, 'M'
int 10h

mov al, 'I'
int 10h

mov al, 'L'
int 10h

mov al, 'I'
int 10h

mov al, 'L'
int 10h

mov al, 'X'
int 10h

; Wait for key press
mov ah, 0x00
int 16h

; Exit
mov ah, 0x4C
mov al, 0
int 21h
