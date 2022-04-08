	IDEAL

	MODEL small

	DATASEG

	max_str 	EQU 200
	str_init	db 201 dup("$")
	sub_str_rep 	db 201 dup("$")
	sub_str_new 	db 201 dup("$")

	msg_input_init	db "Input string:", 0Dh, 0Ah, '$'
	msg_input_rep 	db 0Dh, 0Ah, "Input substring to replace:", 0Dh, 0Ah, '$'
	msg_input_new 	db 0Dh, 0Ah, "Input new substring:", 0Dh, 0Ah, '$'
	msg_result	db 0Dh, 0Ah, "Result:", 0Dh, 0Ah, '$'
	
	msg_too_long	db 0Dh, 0Ah, "Substring is too long for this purpose!", 0Dh, 0Ah, '$'

	msg_ach_200 	db 0Dh, 0Ah, "Maximum is 200, string stopped", 0Dh, 0Ah, '$'	

	str_0DAh 	db 0Dh, 0Ah, '$'

	str_init_len	db 0
	str_rep_len 	db 0
	str_new_len	db 0

	flag 		dw 0	

	STACK		256

	CODESEG


	;=====================================
	;MACROSES

MACRO Print_str str

	lea 		dx, [str]
	mov 		ah, 09h
	int		21h	
ENDM Print_str 

MACRO Input_str 

	mov 		cx, max_str	
	xor 		dx, dx
@@Inp_loop:	
	mov		ah, 01h
	int 		21h

	cmp		al, 0Dh
	je		@@Quit

	mov     	[bx], al
        inc   		bx
	inc 		dl
	LOOP		@@Inp_loop

	Print_str	msg_ach_200
	Print_str	str_0DAh 
@@Quit:
	
ENDM Input_str

MACRO Clear_str

	push 		ax
	mov 		cx, max_str
	mov 		al, '$'

@@Clear_loop:
	mov 		[bx], al	
	inc 		bx
	cmp 		al, [bx]
	je 		@@Q
	LOOP 		@@Clear_loop
@@Q:
	pop 		ax
ENDM Clear_str

	
	;MACROSES
	;=====================================
	;FUNCTIONS 

PROC Replace_substr

Rep_loop:
	push 		si
	push 		di
	push 		cx

	mov 		[flag], 1

	mov 		bx, si
	
	xor 		cx, cx
	mov 		cl, [str_rep_len]

	repe 		cmpsb
	je 		Found
	jne 		Not_found

Found:

	call 		Delete_substr
	mov 		ax, bx
	call 		Insert_substr
	mov 		dl, [str_new_len]
	add 		[str_init_len], dl        
	mov 		[flag], 0

Not_found:
	pop 		cx
	pop 		di
	pop 		si
	
	add 		si, [flag]
	
	LOOP 		Rep_loop

	ret
ENDP Replace_substr	
	
PROC Delete_substr

	push		si
	push 		di
	
	mov 		cl, [str_init_len]
	mov 		di, bx

	repe 		movsb

	pop 		di
	pop 		si
	
	ret
ENDP Delete_substr

PROC Insert_substr
	lea 		cx, [str_init]	     ; str {-->1...$}
	add 		cl, [str_init_len]   ; + len
	mov 		si, cx               ; str {1..9-->$} 
	dec		si             	     ; str {1..-->9$}
	mov		bx, si         	     ; save last symbol in bx
	add 		bl, [str_new_len]    ; now there is the last symbol of new string in bx
	mov 		di, bx               ; new last symbol is reciever             

	mov 		dx, ax               ; ax is a place to insert
	sub 		cx, dx               ; after last symbol -= place to insert
	std            			     ; moving backward
	repe		movsb

	lea 		si, [sub_str_new]    ; source is sbstr 1st symbol
	mov 		di, ax               ; reciever is a place to insert
	xor		cx, cx               ; set cx to zero
	mov 		cl, [str_new_len]    ; sbstr length to cx
	cld             		     ; moving forward
	repe 		movsb            

	ret
ENDP Insert_substr

	;FUNCTIONS
	;=====================================

Start:
	mov 		ax, @data
	mov 		ds, ax
	
	;=====================================
	;GET STRINGS		          

	Print_str 	msg_input_init
	lea 		bx, [str_init]	
	Input_str 	
	mov 		[str_init_len], dl
	
	;IS REPLACE STRING LONGER THAN INITIAL STRING?
	;IF YES -- CLEAR AND REWRITE REPLACE STRING
Rep_long_check:

	mov 		[str_rep_len], 0
	Print_str	msg_input_rep
	lea 		bx, [sub_str_rep]
	Input_str 	
	mov 		[str_rep_len], dl
	
	push 		ax
	mov 		al, [str_init_len]
	cmp		al, [str_rep_len]
	pop 		ax	
	jz 		End_check 		; init = rep
	jnb		End_check		; init > rep

	Print_str 	msg_too_long
	lea 		bx, [sub_str_rep]
	Clear_str
	jmp 		Rep_long_check

End_check:
	
	Print_str	msg_input_new 
	lea 		bx, [sub_str_new] 
	Input_str		
	mov 		[str_new_len], dl
 
	;GET STRINGS
	;=====================================
	

	;=====================================
	;REPLACE		 
	 
	
	xor 		cx, cx
	mov 		cl, [str_init_len]
	sub 		cl, [str_rep_len]
	jb 		Exit
	inc 		cl
	cld

	lea 		si, [str_init]
	lea 		di, [sub_str_rep]
	call 		Replace_substr

	;REPLACE
	;=====================================

	Print_str	msg_result	
	Print_str	str_init
Exit:	
	mov 		ax, 4C00h
	int 		21h

END Start
	ENDS