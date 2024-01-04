; Big nums are numbers that go beyond the limitations of the system one works on
; For example allowing higher than 32-bit mathematics on a 32-bit processor
; There are 4 main math operations that are needed to be handled
; 1) Addition
; 2) Substruction
; 3) Multiplication
; 4) Division (Some choose to ignore this, but I want to make one for fun)
; Additional functionality I want to add:
; 5) Bitshifting


; All operations 1-4 need 4 arguments to work. Two pointers to the numbers, and a number of (bits) bytes to operate on, destination pointer
; To make this easier on myself I will not be using bits as a measurement but bytes instead (8bits), since anyways there cannot be 1 bit alone
; so the function call in c would look like bignum_add(bignum *one, bignum *two, size_t bytes, bignum *dst)

; Numbers are in little endian

; LETS GET CRACKING

; for now only handles numbers as unsigned, I will make a signed library at some point, perhaps next coding session

section .data
section .bss
section .text
    global _start
    global bignum_add
    global bignum_sub

extern fd_printnum
bignum_add: ; requires pointer to the first number in eax, pointer to second number in ebx and number of bytes in ecx, pointer to dest on edx
    push ebp
    mov ebp, esp
    add ecx, dword 24 ; ecx for the dst size and 12 for the three pointers of the locations and two copies of the original ecx
    sub esp, ecx
    mov [esp], eax ; bignum one
    mov [esp+4], ebx ; bignum two
    sub ecx, dword 24
    dec ecx, ; since we are zero indexed
    mov [esp+8], dword 0 ; iterator
    mov [esp+12], ecx ; copy of original value
    mov [esp+16], edx ; bignum dst
    mov [esp+20], dword 0
_addition_loop:
    mov ecx, dword [esp+8]
;get_the_correct_bytes:
    mov eax, [esp]
    add eax, ecx
    movzx ebx, byte [eax]
    mov eax, ebx
    mov ebx, [esp+4]
    add ebx, ecx
    movzx edx, byte [ebx]
    mov ebx, edx
;add_them:
    add al, bl
    jnc _bignum_add_save_byte
    mov ebx, [esp]
    inc ecx
    add ebx, ecx
    mov edx, dword 1
    mov [esp+20], eax
_bignum_add_carry_over_loop:
    cmp ecx, dword [esp+12]
    ja _bignum_add_carry_done
    movzx eax, byte [ebx]
    add al, dl
    mov edx, dword 0
    seto dl ; set dl to one if we overflowed again
    mov [ebx], al
    inc ebx
    inc ecx
    jmp _bignum_add_carry_over_loop
_bignum_add_carry_done:
    mov eax, dword [esp+20]
    mov [esp+20], dword 0
_bignum_add_save_byte:
    mov ecx, dword [esp+8]
    lea ebx, [esp+24+ecx]
    mov [ebx], al
_addition_loop_inc:
    mov ecx, dword [esp+8]
    inc ecx
    mov edx, dword [esp+12]
    cmp ecx, edx
    ja _bignum_add_mov_to_dst
    mov [esp+8], ecx
    jmp _addition_loop
_bignum_add_mov_to_dst:
    mov ecx, dword [esp+12]
    mov eax, [esp+16]
    add eax, ecx
    lea ebx, [esp+24+ecx]
    mov dl,byte [ebx]
    mov [eax], dl
    cmp ecx, dword 0
    je _bignum_add_ret
    dec ecx
    mov [esp+12], ecx
    jmp _bignum_add_mov_to_dst
_bignum_add_ret:
    mov esp, ebp
    pop ebp
    ret

bignum_sub:; requires pointer to the first number in eax, pointer to second number in ebx and number of bytes in ecx, pointer to dest on edx
    push ebp
    mov ebp, esp
    add ecx, dword 24 ; ecx for the dst size and 12 for the three pointers of the locations and two copies of the original ecx
    sub esp, ecx
    mov [esp], eax ; bignum one
    mov [esp+4], ebx ; bignum two
    sub ecx, dword 24
    dec ecx, ; since we are zero indexed
    mov [esp+8], ecx ; iterator
    mov [esp+12], ecx ; copy of original value
    mov [esp+16], edx ; bignum dst
    mov [esp+20], dword 0
_bignum_sub_loop:
    mov ecx, dword [esp+8]
;get_the_correct_bytes:
    mov eax, [esp]
    add eax, ecx
    movzx ebx, byte [eax]
    mov eax, ebx
    mov ebx, [esp+4]
    add ebx, ecx
    movzx edx, byte [ebx]
    mov ebx, edx
    cmp ax, bx
    jb _bignum_sub_carry
    sub ax, bx
    jmp _bignum_sub_save_byte
_bignum_sub_carry:
    add ax, 256
    sub ax, bx
    mov [esp+20], eax
    cmp ecx, dword 0
    je _bignum_sub_carry_done
    dec ecx
_bignum_sub_carry_loop:
    mov eax, [esp]
    add eax, ecx
    mov bl, byte [eax]
    cmp bl, 0
    jna _bignum_sub_carry_inc
    dec bl
    mov [eax], bl
    jmp _bignum_sub_carry_done
    _bignum_sub_carry_inc
    cmp ecx, 0
    je _bignum_sub_carry_done ; albeit wrongfully
    dec ecx
    jmp _bignum_sub_carry_loop
_bignum_sub_carry_done:
    mov eax, dword [esp+20]
    mov [esp+20], dword 0
_bignum_sub_save_byte:
    mov ecx, dword [esp+8]
    lea ebx, [esp+24+ecx]
    mov [ebx], al
_substraction_loop_inc:
    mov ecx, dword [esp+8]
    cmp ecx, 0
    je _bignum_sub_mov_to_dst
    dec ecx
    mov [esp+8], ecx
    jmp _bignum_sub_loop
_bignum_sub_mov_to_dst:
    mov ecx, dword [esp+12]
    mov eax, [esp+16]
    add eax, ecx
    lea ebx, [esp+24+ecx]
    mov dl,byte [ebx]
    mov [eax], dl
    cmp ecx, dword 0
    je _bignum_add_ret
    dec ecx
    mov [esp+12], ecx
    jmp _bignum_sub_mov_to_dst
_bignum_sub_ret:
    mov esp, ebp
    pop ebp
    ret

_start:
    sub esp, dword 24 ; 3 64 bit numbers
    mov [esp], dword 4294967294 ; num 1
    mov [esp+4], dword 0 ; num 1 second part
    mov [esp+8], dword 122 ; num 2
    mov [esp+12], dword 0 ; num 2 second part
    mov [esp+16], dword 0 ; dst
    mov [esp+20], dword 0 ; dst
    lea eax, [esp]
    lea ebx, [esp+8]
    mov ecx, dword 8 ; 64-bits so 4 bytes
    lea edx, [esp+16]
    call bignum_add
    mov eax, dword [esp+16]
    mov ebx, dword 1
    call fd_printnum
    lea eax, [esp+16]
    lea ebx, [esp]
    lea edx, [esp+16]
    mov ecx, dword 8
    call bignum_sub
_test:
    mov eax, dword [esp+16]
    mov ebx, dword 1
    call fd_printnum
    mov eax, 1
    mov ebx, 42
    int 0x80 ; sys_exit
