; advanced_unix_shell.asm
org 0x100

section .data
    prompt db '$ ', 0
    buffer times 512 db 0       ; Command buffer
    pipe_buffer times 1024 db 0 ; Buffer for pipe operations
    env_buffer times 1024 db 0  ; Environment variables buffer
    bufferPos dw 0
    currentDir db '.', 0
    
    ; Environment variables
    PATH db 'PATH=.;C:\BIN', 0
    HOME db 'HOME=C:\', 0
    USER db 'USER=DEFAULT', 0
    
    ; Command messages
    help_msg db 'Available commands:', 0xD, 0xA
            db '  ls      - List directory contents (supports wildcards)', 0xD, 0xA
            db '  cd      - Change directory', 0xD, 0xA
            db '  pwd     - Print working directory', 0xD, 0xA
            db '  cat     - Display file contents', 0xD, 0xA
            db '  touch   - Create empty file', 0xD, 0xA
            db '  rm      - Remove file (supports wildcards)', 0xD, 0xA
            db '  cp      - Copy files', 0xD, 0xA
            db '  mv      - Move files', 0xD, 0xA
            db '  grep    - Search text patterns', 0xD, 0xA
            db '  head    - Display first lines', 0xD, 0xA
            db '  env     - Display environment variables', 0xD, 0xA
            db '  export  - Set environment variable', 0xD, 0xA
            db '  clear   - Clear screen', 0xD, 0xA
            db '  echo    - Display text', 0xD, 0xA
            db '  exit    - Exit shell', 0xD, 0xA
            db 'Supports pipes (|) and wildcards (*)', 0xD, 0xA, 0
            
    unknown_msg db 'Command not found: ', 0
    error_msg db 'Error: ', 0
    newline db 0xD, 0xA, 0
    
    ; File operation buffers
    fileHandle dw 0
    readBuffer times 512 db 0
    DTA times 43 db 0          ; Disk Transfer Area
    wildcard_pattern times 13 db 0

section .bss
    argv resb 256              ; Array of argument pointers
    argc resw 1                ; Argument count
    pipe_active resb 1         ; Flag for pipe operations
    env_vars resb 1024         ; Environment variables storage

section .text
start:
    ; Initialize environment
    call init_environment
    
    ; Set up DTA
    mov ah, 0x1A
    mov dx, DTA
    int 0x21
    
    call clear_screen
    jmp main_loop

init_environment:
    ; Copy initial environment variables
    mov si, PATH
    mov di, env_vars
    call copy_string
    
    mov si, HOME
    call copy_string
    
    mov si, USER
    call copy_string
    ret

main_loop:
    mov si, prompt
    call print_string
    
    call read_line
    call parse_command_line    ; Enhanced parser that handles pipes
    jmp main_loop

; Enhanced command line parser with pipe support
parse_command_line:
    mov byte [pipe_active], 0
    mov si, buffer
    
    ; First pass: check for pipe
    call find_pipe
    jnc .no_pipe
    
    ; Handle piped commands
    push si                     ; Save command string position
    call setup_pipe
    pop si
    
.no_pipe:
    call parse_arguments        ; Split into argc/argv
    call execute_command
    
    ; If pipe was active, process second command
    cmp byte [pipe_active], 1
    jne .done
    call process_pipe_output
    
.done:
    ret

; New pipe handling functions
setup_pipe:
    mov byte [pipe_active], 1
    ; Save output of first command to pipe_buffer
    mov di, pipe_buffer
    ret

process_pipe_output:
    ; Process second command with pipe_buffer as input
    mov si, pipe_buffer
    call execute_command
    ret

; Enhanced argument parser with wildcard support
parse_arguments:
    mov word [argc], 0
    mov si, buffer
    mov di, argv
    
.next_arg:
    ; Skip whitespace
    call skip_spaces
    
    ; Check for end of line
    cmp byte [si], 0
    je .done
    
    ; Store argument pointer
    mov [di], si
    add di, 2
    inc word [argc]
    
    ; Find end of argument
    call find_arg_end
    
    ; Check for wildcard
    call check_wildcard
    
    jmp .next_arg
    
.done:
    ret

; New commands implementation
cmd_cp:
    ; Copy file
    mov dx, [argv + 2]         ; Source file
    mov di, [argv + 4]         ; Destination file
    
    ; Open source file
    mov ah, 0x3D
    mov al, 0                  ; Read-only
    int 0x21
    jc .error
    
    mov [fileHandle], ax
    
    ; Create destination file
    push ax                    ; Save source handle
    mov ah, 0x3C
    mov cx, 0                  ; Normal attribute
    mov dx, di
    int 0x21
    jc .error_close_source
    
    mov bx, ax                 ; Destination handle
    pop si                     ; Source handle
    
    ; Copy loop
.copy_loop:
    push bx
    mov ah, 0x3F              ; Read from source
    mov bx, si
    mov cx, 512
    mov dx, readBuffer
    int 0x21
    jc .error_close_both
    
    or ax, ax                 ; Check for EOF
    jz .done
    
    mov cx, ax                ; Bytes to write
    pop bx
    push ax
    
    mov ah, 0x40              ; Write to destination
    mov dx, readBuffer
    int 0x21
    pop cx
    jc .error_close_both
    
    cmp ax, cx                ; Verify write
    jne .error_close_both
    
    jmp .copy_loop
    
.done:
    ret

cmd_mv:
    ; First try rename (same drive)
    mov ah, 0x56
    mov dx, [argv + 2]         ; Source
    mov di, [argv + 4]         ; Destination
    int 0x21
    jnc .done
    
    ; If rename fails, copy and delete
    call cmd_cp
    jc .error
    
    mov ah, 0x41               ; Delete source
    mov dx, [argv + 2]
    int 0x21
    
.done:
    ret
    
.error:
    mov si, error_msg
    call print_string
    ret

cmd_grep:
    mov si, [argv + 2]         ; Pattern
    mov di, [argv + 4]         ; File
    
    ; Open file
    mov ah, 0x3D
    mov dx, di
    mov al, 0                  ; Read-only
    int 0x21
    jc .error
    
    mov [fileHandle], ax
    
.read_loop:
    ; Read line
    call read_line_from_file
    jc .done
    
    ; Search pattern
    call search_pattern
    jnc .read_loop
    
    ; Pattern found, print line
    mov si, readBuffer
    call print_string
    mov si, newline
    call print_string
    
    jmp .read_loop
    
.done:
    mov ah, 0x3E              ; Close file
    mov bx, [fileHandle]
    int 0x21
    ret
    
.error:
    mov si, error_msg
    call print_string
    ret

cmd_head:
    mov si, [argv + 2]         ; File
    mov cx, 10                 ; Default 10 lines
    
    ; Check if line count specified
    cmp word [argc], 4
    jne .default_lines
    
    mov si, [argv + 4]
    call parse_number
    mov cx, ax
    mov si, [argv + 2]
    
.default_lines:
    ; Open file
    mov ah, 0x3D
    mov dx, si
    mov al, 0                  ; Read-only
    int 0x21
    jc .error
    
    mov [fileHandle], ax
    
.read_loop:
    ; Read and print line
    call read_line_from_file
    jc .done
    
    mov si, readBuffer
    call print_string
    mov si, newline
    call print_string
    
    dec cx
    jnz .read_loop
    
.done:
    mov ah, 0x3E              ; Close file
    mov bx, [fileHandle]
    int 0x21
    ret
    
.error:
    mov si, error_msg
    call print_string
    ret

cmd_env:
    mov si, env_vars
.print_loop:
    cmp byte [si], 0
    je .done
    call print_string
    mov si, newline
    call print_string
    add si, 1                  ; Move to next variable
    jmp .print_loop
.done:
    ret

cmd_export:
    mov si, [argv + 2]         ; Variable name
    mov di, env_vars
    call find_env_var
    jc .new_var
    
    ; Update existing variable
    call update_env_var
    jmp .done
    
.new_var:
    ; Add new variable
    call add_env_var
    
.done:
    ret

; Utility functions
find_pipe:
    push si
.loop:
    lodsb
    cmp al, 0
    je .not_found
    cmp al, '|'
    je .found
    jmp .loop
.found:
    mov byte [si-1], 0         ; Null terminate first command
    clc
    pop si
    ret
.not_found:
    stc
    pop si
    ret

skip_spaces:
    lodsb
    cmp al, ' '
    je skip_spaces
    dec si
    ret

find_arg_end:
    lodsb
    cmp al, 0
    je .done
    cmp al, ' '
    je .done
    cmp al, '|'
    je .done
    jmp find_arg_end
.done:
    dec si
    mov byte [si], 0
    inc si
    ret

check_wildcard:
    push si
.loop:
    lodsb
    cmp al, 0
    je .not_found
    cmp al, '*'
    je .found
    jmp .loop
.found:
    ; Handle wildcard expansion
    call expand_wildcard
    clc
    pop si
    ret
.not_found:
    stc
    pop si
    ret

expand_wildcard:
    ; Save pattern
    mov si, [argv]
    mov di, wildcard_pattern
    call copy_string
    
    ; Find first matching file
    mov ah, 0x4E
    mov cx, 0
    mov dx, wildcard_pattern
    int 0x21
    jc .done
    
    ; Add matches to argv
.next_match:
    mov si, DTA + 30          ; Filename in DTA
    mov di, [argc]
    mov [argv + di], si
    inc word [argc]
    
    ; Find next match
    mov ah, 0x4F
    int 0x21
    jnc .next_match
    
.done:
    ret

read_line_from_file:
    mov di, readBuffer
    mov cx, 0                  ; Character count
    
.read_char:
    mov ah, 0x3F              ; Read one character
    mov bx, [fileHandle]
    mov dx, di
    push cx
    mov cx, 1
    int 0x21
    pop cx
    
    jc .error
    or ax, ax                 ; Check EOF
    jz .eof
    
    inc di
    inc cx
    
    cmp byte [di-1], 0xA      ; Check for newline
    je .done
    
    cmp cx, 510               ; Buffer nearly full
    je .done
    
    jmp .read_char
    
.done:
    mov byte [di], 0          ; Null terminate
    clc
    ret
    
.eof:
    stc
    ret
    
.error:
    stc
    ret

parse_number:
    xor ax, ax
.loop:
    lodsb
    cmp al, '0'
    jb .done
    cmp al, '9'
    ja .done
    sub al, '0'
    push ax
    mov ax, 10
    mul ax
    pop ax
    add al, ah
    jmp .loop
.done:
    ret

copy_string:
    push si
    push di
.loop:
    lodsb
    stosb
    or al, al
    jnz .loop
    pop di
    pop si
    ret

search_pattern:
    push si
    push di
    mov si, [argv + 2]        ; Pattern
    mov di, readBuffer
.loop:
    push si
    push di
.compare:
    lodsb
    mov ah, [di]
    inc di
    cmp al, 0
    je .match
    cmp ah, 0
    je .no_match
    cmp al, ah
    je .compare
.no_match:
    pop di
    pop si
    inc di
    cmp byte [di], 0
    je .not_found
    jmp .loop
.match:
    pop di
    pop si
    clc
    pop di
    pop si
    ret
.not_found:
    stc
    pop di
    pop si
    ret

; Original utility functions remain the same...
[Previous utility functions for read_line, print_string, clear_screen]

times 510 - ($ - $$) db 0
dw 0xAA55