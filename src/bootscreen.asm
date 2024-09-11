; bootscreen.asm
org 100h               ; Set origin for .COM file

; Clear screen
mov ah, 0x00           ; Function 00h - Clear screen
int 10h                ; BIOS interrupt

; Set text mode color attributes
mov ah, 0x0E           ; Function 0Eh - Teletype output
mov al, 'M'            ; Character to display
mov bl, 0x07           ; Attribute (light gray on black)
int 10h                ; BIOS interrupt

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

; Wait for a key press
mov ah, 0x00           ; Function 00h - Wait for key press
int 16h                ; BIOS interrupt

; Exit program
mov ah, 0x4C           ; Function 4Ch - Terminate program
int 21h                ; DOS interrupt
