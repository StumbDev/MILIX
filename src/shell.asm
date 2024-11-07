; enhanced_shell.asm
org 0x100

section .data
    prompt db '#> ', 0
    buffer times 64 db 0   ; Input buffer
    bufferPos dw 0         ; Current position in buffer
    
    ; Command messages
    help_msg db 'Commands: help, clear, echo, exit', 0xD, 0xA, 0
    unknown_msg db 'Unknown command', 0xD, 0xA, 0
    newline db 0xD, 0xA, 0

section .text
start:
    ; Clear screen on startup
    call clear_screen
    
main_loop:
    ; Print prompt
    mov si, prompt
    call print_string
    
    ; Read input
    call read_line
    
    ; Parse and execute command
    call parse_command
    
    jmp main_loop

; Function to read a line of input
read_line:
    mov word [bufferPos], 0    ; Reset buffer position
    
.loop:
    mov ah, 0                  ; Read character
    int 0x16
    
    cmp al, 0x0D              ; Check for Enter
    je .done
    
    cmp al, 0x08              ; Check for Backspace
    je .backspace
    
    ; Store character and echo it
    mov di, buffer
    add di, [bufferPos]
    mov [di], al
    inc word [bufferPos]
    
    mov ah, 0x0E              ; Echo character
    int 0x10
    jmp .loop
    
.backspace:
    cmp word [bufferPos], 0   ; Don't backspace if at start
    je .loop
    
    dec word [bufferPos]      ; Remove last character
    
    mov ah, 0x0E              ; Echo backspace
    mov al, 0x08
    int 0x10
    mov al, ' '               ; Clear character
    int 0x10
    mov al, 0x08             ; Move back
    int 0x10
    jmp .loop
    
.done:
    mov di, buffer            ; Null terminate
    add di, [bufferPos]
    mov byte [di], 0
    
    mov si, newline          ; Print newline
    call print_string
    ret

; Function to parse and execute command
parse_command:
    mov si, buffer
    
    ; Compare with known commands
    mov di, si
    
    ; Check for "help"
    cmp byte [di], 'h'
    jne .check_clear
    cmp byte [di+1], 'e'
    jne .check_clear
    cmp byte [di+2], 'l'
    jne .check_clear
    cmp byte [di+3], 'p'
    jne .check_clear
    cmp byte [di+4], 0
    jne .check_clear
    
    mov si, help_msg
    call print_string
    ret
    
.check_clear:
    cmp byte [di], 'c'
    jne .check_exit
    cmp byte [di+1], 'l'
    jne .check_exit
    cmp byte [di+2], 'e'
    jne .check_exit
    cmp byte [di+3], 'a'
    jne .check_exit
    cmp byte [di+4], 'r'
    jne .check_exit
    
    call clear_screen
    ret
    
.check_exit:
    cmp byte [di], 'e'
    jne .unknown
    cmp byte [di+1], 'x'
    jne .unknown
    cmp byte [di+2], 'i'
    jne .unknown
    cmp byte [di+3], 't'
    jne .unknown
    
    mov ah, 0x4C             ; Exit program
    int 0x21
    
.unknown:
    mov si, unknown_msg
    call print_string
    ret

; Function to print null-terminated string
print_string:
    push ax
.loop:
    lodsb                   ; Load byte from SI into AL
    or al, al              ; Check for null terminator
    jz .done
    mov ah, 0x0E           ; Print character
    int 0x10
    jmp .loop
.done:
    pop ax
    ret

; Function to clear screen
clear_screen:
    mov ah, 0x00           ; Set video mode
    mov al, 0x03           ; Text mode 80x25
    int 0x10
    ret

times 510 - ($ - $$) db 0  ; Pad to 510 bytes
dw 0xAA55                  ; Boot signature
