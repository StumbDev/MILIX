; Simple Text Editor - Editor.asm

org 100h  ; Origin for .COM file

section .data
    filename db 'test.txt', 0
    msg db 'Press any key to exit...', 0
    buffer db 1024 dup(0)  ; Buffer to hold file contents

section .bss
    bytes_read resb 2  ; Reserve space for number of bytes read

section .text
start:
    ; Open file
    mov ah, 0x0F        ; DOS function: Open file
    lea dx, [filename]  ; File name
    mov al, 0           ; Read-only mode
    int 21h             ; DOS interrupt
    jc open_error       ; Jump if carry flag is set (error)

    ; Read file
    mov ah, 0x0A        ; DOS function: Read file
    mov bx, ax          ; File handle
    lea dx, [buffer]    ; Buffer to store file contents
    mov cx, 1024        ; Number of bytes to read
    int 21h             ; DOS interrupt
    jc read_error       ; Jump if carry flag is set (error)

    ; Print file contents
    mov ah, 0x09        ; DOS function: Print string
    lea dx, [buffer]    ; Address of buffer
    int 21h             ; DOS interrupt

    ; Exit
    mov ah, 0x4C        ; DOS function: Terminate program
    int 21h             ; DOS interrupt

open_error:
    ; Handle file open error
    mov ah, 0x09
    lea dx, [msg]
    int 21h
    jmp exit

read_error:
    ; Handle file read error
    mov ah, 0x09
    lea dx, [msg]
    int 21h

exit:
    mov ah, 0x4C        ; DOS function: Terminate program
    int 21h