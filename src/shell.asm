; MILIX Shell - shell.asm

org 100h  ; Origin for .COM file

section .data
    prompt_root db 'root@milix / # ', 0
    prompt_user db 'user@milix / $ ', 0
    login_prompt_msg db 'Login: ', 0
    password_prompt_msg db 'Password: ', 0
    login_success_msg db 'Login successful!', 0
    login_failure_msg db 'Login failed. Press any key to try again...', 0
    hello_msg db 'Hello, MILIX user!', 0
    date_msg db 'Current date: 2024-09-11', 0
    unknown_cmd_msg db 'Unknown command', 0
    default_username db 'user', 0  ; Default username
    default_password db 'password', 0  ; Default password
    user_input db 128 dup (0) ; Buffer for user input

section .bss
    buffer resb 128   ; Reserve space for user input buffer

section .text
start:
    ; Set video mode to 80x25 text mode (default)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Clear the screen
    mov ah, 0x06
    mov al, 0x00
    mov ch, 0x00
    mov cl, 0x00
    mov dh, 0x19
    mov dl, 0x4F
    int 0x10

    ; Display login prompt
    call display_login_prompt

    ; Read username
    call read_username

    ; Display password prompt
    call display_password_prompt

    ; Read password
    call read_password

    ; Validate login
    call validate_login

    ; CLI loop
cli_loop:
    ; Display user prompt based on username
    call display_user_prompt

    ; Read user input
    call read_input

    ; Process command
    call process_command

    ; Loop back to CLI
    jmp cli_loop

display_login_prompt:
    mov ah, 0x0E
    mov si, login_prompt_msg
print_login_prompt:
    lodsb
    cmp al, 0
    je end_print_login_prompt
    int 0x10
    jmp print_login_prompt
end_print_login_prompt:
    ret

display_password_prompt:
    mov ah, 0x0E
    mov si, password_prompt_msg
print_password_prompt:
    lodsb
    cmp al, 0
    je end_print_password_prompt
    int 0x10
    jmp print_password_prompt
end_print_password_prompt:
    ret

read_username:
    lea di, [buffer]
read_username_loop:
    mov ah, 0x00       ; DOS function to read character from input
    int 0x16           ; BIOS keyboard interrupt
    cmp al, 0Dh        ; Enter key
    je check_password
    mov [di], al       ; Store character in buffer
    inc di
    jmp read_username_loop
check_password:
    ret

read_password:
    lea di, [buffer]
read_password_loop:
    mov ah, 0x00       ; DOS function to read character from input
    int 0x16           ; BIOS keyboard interrupt
    cmp al, 0Dh        ; Enter key
    je validate_login
    mov [di], al       ; Store character in buffer
    inc di
    jmp read_password_loop
validate_login:
    ; Hardcoded credentials
    lea si, [buffer]
    lea di, [default_username]
    mov cx, 4          ; Length of username
check_username:
    lodsb
    cmp al, [di]
    jne login_failed
    inc di
    loop check_username

    lea si, [buffer]
    lea di, [default_password]
    mov cx, 8          ; Length of password
check_password_again:
    lodsb
    cmp al, [di]
    jne login_failed
    inc di
    loop check_password_again

    ; Login successful
    ; Set user to root
    lea si, [root_user]
    mov [buffer], si

    ; Print success message
    mov ah, 0x0E
    lea si, [login_success_msg]
print_login_success:
    lodsb
    cmp al, 0
    je end_print_login_success
    int 0x10
    jmp print_login_success
end_print_login_success:
    ret

display_user_prompt:
    lea si, [buffer]
    cmp byte [si], 'r' ; Check if username starts with 'r' (root)
    je print_root_prompt
    ; Display user prompt
    mov ah, 0x0E
    lea si, [prompt_user]
    jmp print_prompt

print_root_prompt:
    ; Display root prompt
    mov ah, 0x0E
    lea si, [prompt_root]

print_prompt:
    lodsb
    cmp al, 0
    je end_print_prompt
    int 0x10
    jmp print_prompt
end_print_prompt:
    ret

read_input:
    lea di, [buffer]
    mov ah, 0x00       ; DOS function to read character from input
    int 0x16           ; BIOS keyboard interrupt
    cmp al, 0Dh        ; Enter key
    je process_command
    mov [di], al       ; Store character in buffer
    inc di
    ret

process_command:
    lea si, [buffer]
    cmp byte [si], 'h'
    jne check_date
    mov byte [si], 0
    ; Print hello message
    mov ah, 0x0E
    lea si, [hello_msg]
print_hello:
    lodsb
    cmp al, 0
    je end_print_hello
    int 0x10
    jmp print_hello
end_print_hello:
    ret

check_date:
    ; Compare command with 'date'
    lea si, [buffer]
    cmp byte [si], 'd'
    jne unknown_command
    inc si
    cmp byte [si], 'a'
    jne unknown_command
    inc si
    cmp byte [si], 't'
    jne unknown_command
    inc si
    cmp byte [si], 'e'
    jne unknown_command
    mov byte [si], 0
    ; Print date message
    mov ah, 0x0E
    lea si, [date_msg]
print_date:
    lodsb
    cmp al, 0
    je end_print_date
    int 0x10
    jmp print_date
end_print_date:
    ret

unknown_command:
    ; Print unknown command message
    mov ah, 0x0E
    lea si, [unknown_cmd_msg]
print_unknown:
    lodsb
    cmp al, 0
    je end_print_unknown
    int 0x10
    jmp print_unknown
end_print_unknown:
    ret

login_failed:
    ; Print login failure message
    mov ah, 0x0E
    lea si, [login_failure_msg]
print_login_failure:
    lodsb
    cmp al, 0
    je end_print_login_failure
    int 0x10
    jmp print_login_failure
end_print_login_failure:
    ; Wait for any key press
    mov ah, 0x00
    int 0x16
    jmp display_login_prompt

section .data
root_user db 'root', 0
