	.286

	.MODEL small

	.STACK 256

	.DATA

	MAX_ARRAY_SIZE equ 6
   	Array          dw MAX_ARRAY_SIZE dup(0)
   	digit          db 8 dup('$')
         	
	
   	median_digit        dw 1 dup('0')
	median_digit_dot    dw 1 dup('0')
   	median_digit_symbol db 7 dup('0')
   	start_msg      db "Number limit from -32768 to 32767", 10, 13, '$'
   	error_get_msg  db 10, 13, "Error. This is not a number/number too long", 10, 13, '$'
  	error_atoi_msg db 10, 13, "Error. Number is not within specified limits", 10, 13, '$'
  	enter_msg      db 10, 13, '$'
        get_digit_msg  db 10, 13, "Enter digit: ", '$'
	answer_msg     db 10, 13, "Answer: ", 10, 13, '$'
	new_line       db 10, 13, '$'
	integer_part   db ' -- integer part', '$'
	has_fraction   db '.5', '$'
	has_fraction_bool db 0
	overflow_str   db 10, 13, 'Register overflow', '$'

  	DIGIT_SYMBOL_LIMIT equ 8
    
	.CODE

Print_str macro str
	lea dx, [str]
	mov ah, 09h
	int 21h
endm

get_digit proc
        pusha
        cld
        out_get_msg:
            Print_str get_digit_msg
        get:
            lea dx, digit
	    mov ah, 0Ah
            int 21h
	    Print_str enter_msg 
        check:
	    
            mov di, offset digit + 2
            xor cx, cx
            mov cl, byte ptr[digit + 1]
            xor ax, ax
            jmp check_negative
            check_negative:
                mov al, '-'
                xor bx, bx
                mov bl, byte ptr[di]
                cmp al, bl
                je negative_digit
                cmp cx, DIGIT_SYMBOL_LIMIT
                ja error_get
                jmp start_check
            negative_digit:
                inc di
                dec cx
                cmp cx, DIGIT_SYMBOL_LIMIT
                ja error_get
                jmp start_check
            start_check: 
                xor bx, bx
                mov bl, byte ptr[di] 
                mov al, '0'
                cmp al, bl
                ja error_get
                mov al, '9'
                cmp al, bl
                jb error_get
                inc di
                loop start_check
                jmp end_get
            error_get:
                Print_str error_get_msg
                
                jmp out_get_msg
        end_get:  
        popa
        ret
    get_digit endp
    
    
    atoi proc
        pop bp
        pop si
        push bp
        pusha
           convert_to_int:
                mov di, offset digit + 2
                push di
                xor cx, cx
                xor dx, dx
                xor ax, ax
                xor bx, bx
                mov cl, byte ptr[digit + 1]
                check_minus_exsistense:
                    mov al, '-'
                    cmp al, byte ptr[di]
                    je skip_minus
                    xor ax, ax
                    jmp start_converting
                skip_minus:
                    inc di
                    dec cx
                    xor ax, ax
                start_converting:
                    mov bl, 10
                    mul bx
                    jo clear_stack
                    mov bl, byte ptr [di]
                    sub bl, '0'
                    add ax, bx     
                    js remember_sf
                    inc di
                    loop start_converting
                    jmp continue
                remember_sf:
                    mov dl, 1
                continue:
                    pop di
                check_negative_digit:
                    xor bx, bx
                    mov bl, '-'
                    cmp bl, byte ptr[di]
                    je set_negative
                    cmp dl, 1
                    je error_atoi
                    jmp set_digit
                set_negative:
                    cmp dl, 1
                    je check_low_border
                    neg ax
                    jmp set_digit
                set_digit:
                    mov word ptr[si], ax
                    jmp end_atoi
                check_low_border:
                    cmp ax, 8000h
                    je set_digit
                    jmp error_atoi
                clear_stack:
                    pop di
                error_atoi:
                    Print_str error_atoi_msg
                    
                    call get_digit
                    jmp convert_to_int
        end_atoi:
        popa
        ret
    atoi endp
    
    swap proc
        pusha
        sub di, 2
        sub si, 2
        mov ax, word ptr[di]
        mov bx, word ptr[si]
        mov word ptr[di], bx 
        mov word ptr[si], ax
        popa
        ret
    swap endp
    
    bubble_sort proc
        pusha
        
        xor cx, cx
        xor di, di
        xor si, si
        xor dx, dx
        mov di, offset array
        mov si, offset array
        add si, 2
        mov cx, MAX_ARRAY_SIZE
        dec cx
        mov dx, MAX_ARRAY_SIZE*2
        _outer_loop:
            _inner_loop:
                 cmpsw
                 jl swap_digits
                 jmp _continue_inner_loop
                 swap_digits:
                    call swap
                 _continue_inner_loop:
                    sub di, 2
                    cmp si, dx
                    je _continue_outer_loop
                    jmp _inner_loop
            _continue_outer_loop:
                add di, 2
                mov si, di
                add si, 2
        loop _outer_loop
       
        popa
        ret
    bubble_sort endp
    
    get_median proc
        pusha

        cld
        xor cx, cx
        xor di, di
        xor bx, bx
        xor si, si

        mov si, offset array
        add si, 4

        mov ax, word ptr[si]	;3rd

	add si, 2

	add ax, word ptr[si]	;+4th
	
	push ax
	and ax, 10000000b
	cmp ax, 10000000b
	je overflow 
	pop ax

	;push ax
	;and eax, 1111111100000000b
	;cmp eax, 1111111100000000b
	;je overflow 
	;pop ax

	push dx
	mov bl, 2
	div bl
	
	xor bx, bx
	mov bl, al
	
        mov word ptr[median_digit], bx

	cmp ah, 1
	jne net_ostatka

	mov [has_fraction_bool], 1
	xor bx, bx
	mov bx, 5
	mov word ptr[median_digit_dot], bx

	pop dx
        popa
        ret

net_ostatka:
        xor bx, bx
	mov bx, 0
	mov word ptr[median_digit_dot], bx

	pop dx
        popa
        ret

overflow:
	Print_str overflow_str
	mov ax, 4C01h
        int 21h
    get_median endp
    
    itoa proc
        pusha
         
         mov [di+6], '$'
         add di, 5
         mov ax, word ptr[si]
         cmp ax,0
         jl _set_positive
         jmp _outer_loop_
         _set_positive:
            neg ax
         _outer_loop_:
            mov bx, 10
            xor dx, dx
            div bx
            add dl, '0'
            mov [di], dl
            dec di
            cmp ax, 0
            je _end_outer_loop_
            jmp _outer_loop_
        _end_outer_loop_:
        _check_negative:
            mov ax, word ptr[si]
            cmp ax, cx
            jl _set_negative_
            jmp _set_plus_
        _set_negative_:
            mov byte ptr[di], '-'
            jmp _ret_itoa
        _set_plus_:
            mov byte ptr[di], '+'
        _ret_itoa:       
        popa
        ret
    itoa endp
        
_start:     
    mov ax, @data
    mov ds, ax
    mov es, ax
    Print_str start_msg
                  
    mov di, offset median_digit_symbol
    mov [di+6], '$'           
    xor dx, dx
    xor cx, cx
    mov dx, offset array
    mov cx, MAX_ARRAY_SIZE
    initialize_array:
        call get_digit
        push dx
        call atoi
        add dx, 2
        loop initialize_array
    call bubble_sort
    call get_median

   
    Print_str answer_msg 
    xor si, si
    xor di, di
    mov si, offset median_digit
    mov di, offset median_digit_symbol
    call itoa
    Print_str median_digit_symbol

    cmp has_fraction_bool, 1
    jne _exit
    Print_str has_fraction
    ;xor si, si
    ;xor di, di
    ;mov si, offset median_digit_dot
    ;mov di, offset median_digit_symbol
    ;call itoa
    ;Print_str new_line	
    ;Print_str median_digit_symbol	
    ;Print_str fraction_part
   
    jmp _exit
_exit:
    mov ah, 4Ch
    int 21h
    end _start