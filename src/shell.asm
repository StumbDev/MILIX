; Simple Shell - Shell.asm

org 100h  ; Origin for .COM file

section .data
    prompt db '[root@milix]# ', 0
    buffer db 128 dup(0)  ; Buffer for user input
    msg_unknown db 'Unknown command', 0

section .bss
    bytes_read resb 1

section .text
start:
    ; Print prompt
print_prompt:
    mov ah, 0x09
    lea dx, [prompt]
    int 21h

    ; Read user input
    mov ah, 0x0A
    lea dx, [buffer]
    int 21h

    ; Parse and execute command
    lea si, [buffer + 1]  ; Skip length byte
    call parse_command
    jmp start

parse_command:
    ; Check for "ls" command
    cmp byte [si], 'l'
    jne check_cat
    cmp byte [si+1], 's'
    jne check_cat
    ; Execute ls
    call list_files
    ret

check_cat:
    ; Check for "cat" command
    cmp byte [si], 'c'
    jne check_exit
    cmp byte [si+1], 'a'
    jne check_exit
    cmp byte [si+2], 't'
    jne check_exit
    ; Execute cat
    call cat_file
    ret

check_exit:
    ; Check for "exit" command
    cmp byte [si], 'e'
    jne unknown_command
    cmp byte [si+1], 'x'
    jne unknown_command
    cmp byte [si+2], 'i'
    jne unknown_command
    cmp byte [si+3], 't'
    jne unknown_command
    ; Exit shell
    mov ah, 0x4C
    int 21h

unknown_command:
    ; Print unknown command message
    mov ah, 0x09
    lea dx, [msg_unknown]
    int 21h
    ret

list_files:
    ; Dummy implementation for ls command
    mov ah, 0x09
    lea dx, [msg_unknown]  ; For demonstration, just print "Unknown command"
    int 21h
    ret

cat_file:
    ; Dummy implementation for cat command
    mov ah, 0x09
    lea dx, [msg_unknown]  ; For demonstration, just print "Unknown command"
    int 21h
    ret
