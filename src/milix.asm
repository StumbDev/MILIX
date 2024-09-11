; milix.asm
org 100h               ; Set origin for .COM file

; Print a message indicating the system is starting
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

; Load and execute the kernel
mov ah, 0x4A           ; Function 4Ah - Load overlay
mov al, 1              ; Load overlay 1 (kernel)
mov bx, 0x1000         ; Segment where kernel will be loaded
int 21h                ; DOS interrupt

; Jump to the kernel segment
jmp 0x1000:0000        ; Jump to the kernel segment

; Exit program if loading fails
mov ah, 0x4C           ; Function 4Ch - Terminate program
int 21h                ; DOS interrupt
