; dosbox.asm
org 0x100

section .data
    VERSION db 'DOSBox v0.1', 0xD, 0xA, 0
    USAGE db 'Usage: dosbox [command] [arguments]', 0xD, 0xA, 0
    
    ; Command table
    CMD_TABLE:
        dw cmd_cat,   cmd_cat_str
        dw cmd_ls,    cmd_ls_str
        dw cmd_cp,    cmd_cp_str
        dw cmd_mv,    cmd_mv_str
        dw cmd_rm,    cmd_rm_str
        dw cmd_mkdir, cmd_mkdir_str
        dw cmd_rmdir, cmd_rmdir_str
        dw cmd_echo,  cmd_echo_str
        dw cmd_more,  cmd_more_str
        dw cmd_find,  cmd_find_str
        dw cmd_grep,  cmd_grep_str
        dw cmd_head,  cmd_head_str
        dw cmd_tail,  cmd_tail_str
        dw cmd_wc,    cmd_wc_str
        dw cmd_date,  cmd_date_str
        dw cmd_help,  cmd_help_str
        dw 0, 0                    ; Table terminator

    ; Command strings
    cmd_cat_str   db 'cat', 0
    cmd_ls_str    db 'ls', 0
    cmd_cp_str    db 'cp', 0
    cmd_mv_str    db 'mv', 0
    cmd_rm_str    db 'rm', 0
    cmd_mkdir_str db 'mkdir', 0
    cmd_rmdir_str db 'rmdir', 0
    cmd_echo_str  db 'echo', 0
    cmd_more_str  db 'more', 0
    cmd_find_str  db 'find', 0
    cmd_grep_str  db 'grep', 0
    cmd_head_str  db 'head', 0
    cmd_tail_str  db 'tail', 0
    cmd_wc_str    db 'wc', 0
    cmd_date_str  db 'date', 0
    cmd_help_str  db 'help', 0

    ; Error messages
    ERR_NOTFOUND db 'Command not found', 0xD, 0xA, 0
    ERR_ARGS     db 'Invalid arguments', 0xD, 0xA, 0
    ERR_FILE     db 'File error', 0xD, 0xA, 0

    ; Buffers
    buffer    times 1024 db 0
    file_buf  times 4096 db 0
    path_buf  times 256  db 0
    DTA       times 43   db 0

section .bss
    argc    resw 1
    argv    resw 32
    cmdline resb 128

section .text
start:
    ; Parse command line
    call parse_cmdline
    
    ; If no arguments, show usage
    cmp word [argc], 1
    jle show_usage
    
    ; Find and execute command
    call find_command
    jc command_not_found
    
    ; Exit
    mov ax, 0x4C00
    int 0x21

; Command implementations
cmd_cat:
    ; Check arguments
    cmp word [argc], 2
    jl .error_args
    
    ; Open file
    mov dx, [argv + 2]
    mov ax, 0x3D00
    int 0x21
    jc .error_file
    
    mov bx, ax
    
    ; Read and print loop
.read_loop:
    mov ah, 0x3F
    mov cx, 4096
    mov dx, file_buf
    int 0x21
    
    jc .error_read
    or ax, ax
    jz .done
    
    mov cx, ax
    mov dx, file_buf
    mov ah, 0x40
    mov bx, 1
    int 0x21
    
    jmp .read_loop
    
.done:
    ret
    
.error_args:
    mov dx, ERR_ARGS
    jmp .print_error
.error_file:
    mov dx, ERR_FILE
.print_error:
    mov ah, 0x09
    int 0x21
    ret
.error_read:
    mov ah, 0x3E
    int 0x21
    jmp .error_file

cmd_ls:
    ; Set up DTA
    mov ah, 0x1A
    mov dx, DTA
    int 0x21
    
    ; Get search pattern
    mov dx, [argv + 2]
    test dx, dx
    jnz .use_pattern
    mov dx, cmd_ls_pat
.use_pattern:
    
    ; Find first
    mov cx, 0x0000
    mov ah, 0x4E
    int 0x21
    jc .done
    
.print_loop:
    ; Print filename
    mov dx, DTA + 30
    mov ah, 0x09
    int 0x21
    
    ; Print newline
    mov dx, newline
    int 0x21
    
    ; Find next
    mov ah, 0x4F
    int 0x21
    jnc .print_loop
    
.done:
    ret

cmd_cp:
    ; Check arguments
    cmp word [argc], 3
    jl .error_args
    
    ; Open source
    mov dx, [argv + 2]
    mov ax, 0x3D00
    int 0x21
    jc .error_file
    
    mov [src_handle], ax
    
    ; Create destination
    mov dx, [argv + 4]
    mov cx, 0x0000
    mov ah, 0x3C
    int 0x21
    jc .error_create
    
    mov [dst_handle], ax
    
    ; Copy loop
.copy_loop:
    mov bx, [src_handle]
    mov cx, 4096
    mov dx, file_buf
    mov ah, 0x3F
    int 0x21
    
    jc .error_read
    or ax, ax
    jz .done
    
    mov cx, ax
    mov bx, [dst_handle]
    mov dx, file_buf
    mov ah, 0x40
    int 0x21
    
    jc .error_write
    
    jmp .copy_loop
    
.done:
    ; Close files
    mov bx, [src_handle]
    mov ah, 0x3E
    int 0x21
    
    mov bx, [dst_handle]
    mov ah, 0x3E
    int 0x21
    ret
    
.error_args:
    mov dx, ERR_ARGS
    jmp .print_error
.error_file:
    mov dx, ERR_FILE
.print_error:
    mov ah, 0x09
    int 0x21
    ret
.error_create:
    mov bx, [src_handle]
    mov ah, 0x3E
    int 0x21
    jmp .error_file
.error_read:
.error_write:
    mov bx, [src_handle]
    mov ah, 0x3E
    int 0x21
    mov bx, [dst_handle]
    mov ah, 0x3E
    int 0x21
    jmp .error_file

; More command implementations...
[Additional commands would be implemented here]

; Utility functions
parse_cmdline:
    ; Get command line
    mov si, 0x81
    mov di, cmdline
    
.copy_loop:
    lodsb
    cmp al, 0x0D
    je .done
    stosb
    jmp .copy_loop
    
.done:
    mov byte [di], 0
    
    ; Parse arguments
    mov si, cmdline
    mov di, argv
    mov word [argc], 0
    
.parse_loop:
    call skip_spaces
    jc .parse_done
    
    mov [di], si
    add di, 2
    inc word [argc]
    
    call find_end
    jmp .parse_loop
    
.parse_done:
    ret

find_command:
    mov si, [argv + 2]
    mov di, CMD_TABLE
    
.search_loop:
    mov ax, [di + 2]
    or ax, ax
    jz .not_found
    
    push si
    push di
    mov di, ax
    call strcmp
    pop di
    pop si
    
    jz .found
    
    add di, 4
    jmp .search_loop
    
.found:
    mov ax, [di]
    call ax
    clc
    ret
    
.not_found:
    stc
    ret

; String utility functions
strcmp:
    push si
    push di
.loop:
    lodsb
    mov ah, [di]
    inc di
    
    or al, al
    jz .check_end
    
    cmp al, ah
    jne .not_equal
    
    jmp .loop
    
.check_end:
    cmp ah, 0
    jne .not_equal
    
    xor ax, ax
    jmp .done
    
.not_equal:
    mov ax, 1
    
.done:
    pop di
    pop si
    ret

skip_spaces:
    lodsb
    cmp al, ' '
    je skip_spaces
    cmp al, 0
    je .end
    dec si
    clc
    ret
.end:
    stc
    ret

find_end:
    lodsb
    cmp al, ' '
    je .found
    cmp al, 0
    je .found
    jmp find_end
.found:
    dec si
    mov byte [si], 0
    inc si
    ret

show_usage:
    mov dx, USAGE
    mov ah, 0x09
    int 0x21
    ret

command_not_found:
    mov dx, ERR_NOTFOUND
    mov ah, 0x09
    int 0x21
    ret

section .data
    newline db 0xD, 0xA, '$'
    cmd_ls_pat db '*.*', 0
    src_handle dw 0
    dst_handle dw 0

times 510-($-$$) db 0
dw 0xAA55