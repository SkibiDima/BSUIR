.model  small
.stack 256

.data 
block dw 0
		dw 0
overlay_offset dw ?
overlay_seg dw ?
code_seg dw ?
cmd_line db 127 dup (0)						;Buffer for cmd line args
cmd_size dw 0

c_plus equ '+'
c_minus equ '-'
c_div equ '/'
c_mult equ '*'                   

is_neg dw 0
is_neg_first dw 0
is_end dw 0
result dw 0

current_op db 0
prev_op dw 5

number db 10 dup (?)
num_size dw 0

p_ov db "p_ov.exe", 0
s_ov db "s_ov.exe", 0
m_ov db "m_ov.exe", 0
d_ov db "d_ov.exe", 0

e_number_is_too_large db "Provided number is too large", 10, 13
e_check_args_str db "Bad arguments provided", 10, 13, "$"
e_cmd_line_example_str db "Example: lab7.exe [1+2*3+2/2]", 10, 13, "$"
e_not_enough_cmdl_len_str db "ERROR: Not enough command line arguments.", 10, 13, "$"
e_overflow db "ERROR: Arithmetic overflow", 10, 13, "$"
e_zero_division db "ERROR: Zero division", 10, 13, "$"
e_lost_division db "ERROR Division forms reminder", 10, 13, "$"
e_call_overlay db "ERROR: unsupported operation", 10, 13, "$"
s_optimised_operation db "Used loaded overlay", 10, 13, "$"

.code
jmp start


print_str MACRO out_str   					;Prints str to screen
        push ax
        push dx   
        push di
        push ds
        mov ax, @data
        mov ds, ax
        xor di, di
		mov ah, 09h
		mov dx, offset out_str
		int 21h 
		pop ds
		pop di   
		pop dx
		pop ax
ENDM 

strlen macro stroke							;finds amount of characters before 0, returns length in cx
	push di 
	push cx
	mov al, 0
	mov di, offset stroke
	mov cx, 70h
	repne scasb
	inc cx
	mov ax, 70h
	sub ax, cx
	pop cx
	pop di 
endm strlen

make_str_from_integer proc 
    push di 
    push dx
    push cx     
    push si   
    push ax
    mov si, offset number 
    mov cx, 10      
    make_str_loop:
    xor dx, dx
    div cx
    xchg ax, dx
    add al, '0'
    mov [si], al
    xchg ax, dx      
    inc si
    cmp ax, 0
    jne make_str_loop
    clc
    dec si
    end_makestr:        
    push si
    pop di            
    
    mov si, offset number
    call reverse
    inc di
    mov [di], '$'
    pop ax
    pop si
    pop cx
    pop dx  
    pop di
    ret      
endp      

parse_cmd proc 							;Reads input file path from cmd, and then call proc, that reads substrs
	mov ax, @data
    mov es,ax
    
    xor cx,cx
    mov cl, ds:[80h] 
	cmp cl, 1
	ja cmdl_parse_continue
	mov ds, ax
	print_str e_not_enough_cmdl_len_str 	;If commandline_args str is too short
	print_str e_cmd_line_example_str
	jmp bend
	cmdl_parse_continue:
	mov es:cmd_size, cx
	dec es:cmd_size
	mov di, offset cmd_line
	mov si, 82h  
	rep movsb  							;Read all cmd to cmd_line str

	mov ds, ax  
	
	params_end:
	ret
parse_cmd endp

check_args proc 
	push ax
	push cx
	push di
	mov di, 0
	mov cx, cmd_size
	dec cx

	check_args_loop:
		cmp cmd_line[di], c_plus			;If '+'
		je check_args_loop_end
		cmp cmd_line[di], c_minus			;If '-'
		je check_args_loop_end
		cmp cmd_line[di], c_div				;If '/'
		je check_args_loop_end
		cmp cmd_line[di], c_mult			;if '*'
		je check_args_loop_end
		cmp cmd_line[di], byte ptr 0dh
		je check_args_end

		cmp cmd_line[di], '0'
		jb check_args_error
		cmp cmd_line[di], '9'
		ja check_args_error

		check_args_loop_end:
		inc di
	loop check_args_loop

	cmp cmd_line[di], '0'
	jb check_args_error
	cmp cmd_line[di], '9'
	ja check_args_error

	jmp check_args_end

	check_args_error:
	print_str e_check_args_str
	print_str e_cmd_line_example_str
	jmp bend

	check_args_end:
	pop di
	pop cx
	pop ax
	ret
check_args endp

reverse PROC        ;si - begin, di - end of substring
          PUSH SI
          PUSH DI
          PUSH AX
          PUSH BX

          CLD    
          cycle:
               MOV AL, [SI]   ;swapping symbols
               MOV BL, [DI]
               MOV [SI], BL
               MOV [DI], AL 

               DEC DI    ;moving borders towards each other
               INC SI
               CMP SI, DI 
          JL cycle       ;if borders met -> ret  

          POP BX
          POP AX
          POP DI
          POP SI
          RET
     reverse ENDP 

convert PROC   
    push dx
    push bx    
    push si   
    mov si, offset number   
    jcxz convert_error   
    cmp is_neg, 0            
    je convert_cont    
    dec cx
    
    convert_cont:

    xor ax, ax 
    mov bx, 10
	xor dx, dx
	mov dl, [si]
    conv_loop:
	    mul bx 
	    mov bx, ax  
	    xor ax, ax
	    cmp dx, 0
	    jnz convert_error_too_big
	    mov al, [si]
	    cmp al, '0'
	    jb convert_error
	    cmp al, '9'
	    ja convert_error
	    sub al, '0'
	    add ax, bx
	    mov bx, 10
	    inc si
    loop conv_loop
    conv_clear_cf:
    jmp conv_end  

    convert_error: 
    print_str e_check_args_str
    print_str e_cmd_line_example_str
    jmp bend
    convert_error_too_big:
    jmp number_is_too_large_error

    conv_end:
    pop si
    pop bx 
    pop dx   
ret   
convert ENDP

create_gap proc 					;di - start, cx - gap size
	create_gap_loop:
		mov [di], byte ptr '#'
		inc di
	loop create_gap_loop
	ret 
create_gap endp 

process_high_priority_operations proc 
	mov di, offset cmd_line
	phpo_continue:
		call get_num
		mov al, [di]
		mov current_op, al
		inc di 

		cmp current_op, byte ptr 0dh
		jne phpo_not_end
		jmp phpo_end

		phpo_not_end:
		cmp current_op, c_mult
		je phpo_convert_num

		cmp current_op, c_div
		je phpo_convert_num
		jmp phpo_continue

		phpo_convert_num:
			push is_neg
			pop is_neg_first
			mov cx, num_size
			mov dx, num_size
			call convert
			mov bx, ax

		phpo_get_second:
			call get_num
			add dx, num_size
			inc dx 
			sub di, dx 
			mov cx, dx 
			call create_gap 
			mov cx, num_size  
			call convert
			xchg ax, bx

			cmp current_op, byte ptr '*'
			je phpo_process_mult

			cmp current_op, byte ptr '/'
			je phpo_process_div 
			jmp phpo_error

		phpo_process_mult:
			mov dx, offset m_ov
			call over
			jmp phpo_processed
		phpo_process_div:      
			mov dx, offset d_ov
			call over
			jmp phpo_processed
		phpo_processed:
			push ax          
			mov bx, is_neg_first
			xor is_neg, bx
			push is_neg
			cmp [di], byte ptr 0dh
			je phpo_end 
			cmp [di], byte ptr '/'
			je phpo_operate_with_stack
			cmp [di], byte ptr '*'
			je phpo_operate_with_stack
			inc di 
			jmp phpo_continue
		phpo_operate_with_stack:
			mov al, byte ptr [di]
			mov current_op, al 
			inc di 
			xor dx, dx      
			pop is_neg_first
			pop bx 
			jmp phpo_get_second

	phpo_end:  
	mov result, 0
	mov dx ,0
	mov is_neg_first, 0               
	mov di, offset cmd_line
	add di, cmd_size 
	dec di
	plpo_read_int:
		cmp is_end, 1
		jne plpo_not_end
		jmp plpo_end
		plpo_not_end: 
		cmp di, offset cmd_line
		jne not_cmd_begin
		jmp plpo_last_num
		not_cmd_begin:
		cmp [di], byte ptr '+'
		jne plpo_read_int_cnt
		dec di
		plpo_read_int_cnt:
		xor cx, cx
		cmp [di], byte ptr '#'
		je pop_stack_to_answer

		plpo_read_int_loop:
			cmp di, offset cmd_line
			jne plpo_not_last
			jmp plpo_last_num
			plpo_not_last:
			cmp [di], byte ptr '+'
			je plpo_process_int 
			cmp [di], byte ptr '-'     
			je plpo_process_int

			inc cx
			dec di
			jmp plpo_read_int_loop
	plpo_process_int:  
	    mov al, [di]     
	    mov current_op, al
		inc di
		call get_num   
		mov cx, num_size  
		sub di, cx  
		sub di, 2
		call convert   
		
		     
		mov bx, result
		cmp current_op, byte ptr '+'
		je plpo_make_add 
		jmp plpo_make_sub

	pop_stack_to_answer:
		pop dx
		pop ax 
		
		call skip_gap   
		cmp [di+1], byte ptr '-' 
		jne pop_stack_not_sub 
		xor dx, 1
		pop_stack_not_sub:
		mov bx, result
		cmp dx, 0 
		jne plpo_make_sub
		mov is_neg, 0
		jmp plpo_make_add
	plpo_make_add:         
	    mov dx, is_neg
	    cmp dx, is_neg_first
	    je add_continue  
	    
	    cmp bx, ax
	    jb plpo_add_to_sub
	    xchg bx, ax 
	    mov dx, offset s_ov 
	    call over 
	    jmp add_end
	    
	    plpo_add_to_sub:
	    mov dx, offset s_ov 
	    call over 
	    push is_neg 
	    pop is_neg_first
	    jmp add_end
	    
	    add_continue:     
		mov dx, offset p_ov
		call over   
	    add_end:
	    mov result, ax      
	    jmp plpo_read_int
	plpo_make_sub:  
	    mov is_neg, 1
	    cmp is_neg_first, 1
	    jne sub_cnt
	    jmp plpo_make_add  
	    
	    sub_cnt:
	    cmp bx, ax
	    ja simple_sub
	    mov is_neg_first, 1    
	    xchg bx, ax
	    simple_sub:  
	    xchg bx, ax 
	    mov dx, offset s_ov
	    call over
	    mov result, ax  
	    jmp plpo_read_int
	plpo_last_num:
		call get_num   
		mov cx, num_size  
		mov is_end, 1
		
		call convert
		mov bx, result
		cmp is_neg, 1
		je plpo_make_sub
		jmp plpo_make_add 
	
	plpo_end:
	mov ax, result
	call make_str_from_integer
	cmp is_neg_first, 1
	jne to_print_answer
	cmp ax, 0
	je to_print_answer
	mov dl, byte ptr '-'
	mov ah, 02h
	int 21h
	to_print_answer:
	print_str number
	
	ret
	phpo_error:
	jmp bad_args_error
process_high_priority_operations endp

skip_gap proc 
	skip_gap_loop:
		cmp di, offset cmd_line
		je skip_gap_in_end
		cmp [di], byte ptr '#'
		jne skip_gap_dec
		dec di 
	jmp skip_gap_loop 
	skip_gap_in_end:
	mov is_end, 1 
	jmp skip_gap_end
	skip_gap_dec:
	dec di
	skip_gap_end:
	ret
skip_gap endp

get_num proc 							;di - pos in cmd
	push cx
	push si    
	xor cx, cx
	mov si, offset number 
	mov is_neg, 0           
	cmp [di], byte ptr 0dh
	je get_num_end
	cmp [di], byte ptr '-'
	jne get_num_not_neg
	mov is_neg, 1
	inc di        
	inc cx
	jmp get_num_continue
	get_num_not_neg:
	cmp [di], byte ptr '0'
	jb get_num_err
	cmp [di], byte ptr '9'
	ja get_num_err
	jmp get_digit

	get_num_continue:
		cmp cx, 6
		jl get_num_cnt
		jmp number_is_too_large_error
		get_num_cnt:
		cmp [di], byte ptr 0dh
		je get_num_end
		cmp [di], byte ptr '0'
		jb get_num_end
		cmp [di], byte ptr '9'
		ja get_num_end

		get_digit:
		mov al, [di]
		mov [si], al
		inc si 
		inc di 
		inc cx
	jmp get_num_continue

	get_num_end:	
	mov num_size, cx
	mov [si], byte ptr 	'$'
	pop si
	pop cx
	ret
	get_num_err:
	print_str e_check_args_str
		jmp bend
get_num endp

call_overlay proc 				;dx - overlay path
	push ax
	push bx

	cmp dx, offset p_ov
	jne co_not_plus
	mov ax, 0
	jmp co_continue
	co_not_plus:

	cmp dx, offset s_ov
	jne co_not_sum
	mov ax, 1
	jmp co_continue
	co_not_sum:

	cmp dx, offset m_ov
	jne co_not_mul
	mov ax, 2
	jmp co_continue
	co_not_mul:

	cmp dx, offset d_ov
	jne co_not_div
	mov ax, 3
	jmp co_continue
	co_not_div:
	jmp co_error

	co_continue:
	cmp prev_op, ax
	je co_cache

	mov prev_op, ax
	xor ax, ax 
	mov ah, 62h
	int 21h
	jc co_error

	mov es, bx
	mov ax, bx 
	mov bx, zseg
	sub bx, ax 
	mov ah, 4ah
	int 21h 
	jc co_error

	mov bx, 1000h
	mov ah, 48h
	int 21h 
	jc co_error

	mov block, ax 
	mov block+2, ax
	mov overlay_seg, ax 

	mov ax, ds 
	mov es, ax 

	mov bx, offset block
	mov ax, 4b03h
	int 21h
	jc co_error
	jmp co_end

	co_cache:
	;print_str s_optimised_operation

	co_end:
	pop bx
	pop ax
	ret
	co_error:
	print_str e_call_overlay
	jmp bend
call_overlay endp

over proc                   				;dx - path, ax, bx - numbers
	call call_overlay
	xor dx, dx 
	push ds 
	call dword ptr overlay_offset
	pop ds
	call check_flags
	ret 
over endp

check_flags proc 
	jc cf_overflow

	cmp prev_op, 3
	jne cf_not_division_over

	cmp dx, 0
	jne cf_division_over
	cf_not_division_over:
	cmp dx, 0
	jne cf_overflow

	jmp cf_end

	cf_division_over:
	print_str e_lost_division
	jmp bend

	cf_overflow:
	print_str e_overflow
	jmp bend

	cf_end:
 	ret 
check_flags endp

start:
	call parse_cmd
	call check_args
	mov ax, @data
	mov ds, ax 
	mov es, ax 

	call process_high_priority_operations     


bend: ;[Before end]
		mov ah, 4ch
		int 21h               
bad_args_error:
    print_str e_check_args_str
    print_str e_cmd_line_example_str
    jmp bend
number_is_too_large_error:
	print_str e_number_is_too_large
	jmp bend

zseg    segment 
zseg    ends
end start