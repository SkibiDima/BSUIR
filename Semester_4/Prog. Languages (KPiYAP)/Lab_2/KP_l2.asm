	IDEAL

	MODEL small

MACRO Print_str str

	lea 		dx, [str]
	mov 		ah, 09h
	int		21h	
ENDM Print_str 		

	DATASEG
	str_init	db 401 dup("$")
	sub_str_rep 	db 201 dup("$")
	sub_str_new 	db 201 dup("$")

	msg_input_init	db "Input string:", 0Dh, 0Ah, '$'
	msg_input_rep 	db 0Dh, 0Ah, "Input substring to replace:", 0Dh, 0Ah, '$'
	msg_input_new 	db 0Dh, 0Ah, "Input new substring:", 0Dh, 0Ah, '$'
	msg_result	db 0Dh, 0Ah, "Result:", 0Dh, 0Ah, '$'
	
	msg_too_long	db 0Dh, 0Ah, "Substring is too long for this purpose!", 0Dh, 0Ah, '$'

	msg_ach_200 	db 0Dh, 0Ah, "Maximum is 200, string stopped", 0Dh, 0Ah, '$'	

	str_0DAh 	db 0Dh, 0Ah, '$'

	max_str 	EQU 200

	flag dw 0	

	STACK 256

	CODESEG

PROC Input_str 

	mov 		cx, max_str	

@@inp_loop:	
	mov		ah, 01h
	int 		21h

	cmp		al, 0Dh
	je		@@quit

	mov     	[bx], al
        inc   		bx
	LOOP		@@inp_loop

	Print_str	msg_ach_200
	Print_str	str_0DAh 
@@quit:
	ret
ENDP Input_str 

PROC Clear_str

	push 		ax
	mov 		cx, max_str
	mov 		al, '$'

@@rep_loop:
	mov 		[bx], al	
	inc 		bx
	cmp 		al, [bx]
	je 		@@quit
	LOOP @@rep_loop
@@quit:
	pop 		ax
	ret
ENDP Clear_str


PROC Find_substr

	
	ret
ENDP Find_substr

Start:
	mov 		ax, @data
	mov 		ds, ax
	
	;=====================================
	;GET STRINGS		          
	
	Print_str 	msg_input_init
	lea 		bx, [str_init]	
	call 		Input_str 
	
	;IS REPLACE STRING LONGER THAN INITIAL STRING?
	;IF YES -- CLEAR AND REWRITE REPLACE STRING
Rep_long_check:

	Print_str	msg_input_rep
	lea 		bx, [sub_str_rep]
	call 		Input_str 
	
	std				; go from the end "...$$"
	lea 		si, [str_init + max_str]
	lea 		di, [sub_str_rep + max_str]	
	mov 		cx, max_str
	repe		cmpsb
	jne		Check_$_init	; strings are not equal somewhere
	jmp		End_check

Check_$_init:
		
	mov 		al, '$'
	
	mov 		bx, di
	cmp 		al, [di]	; is rep_str shorter?
	je 		End_check	; if = $, shorter, it's OK

	mov 		bx, si
	cmp 		al, [si]	; is int_str shorter?
	jne 		End_check	; if != $, longer, it's OK	

	Print_str 	msg_too_long
	lea 		bx, [sub_str_rep]
	call 		Clear_str
	jmp 		Rep_long_check

End_check:
	
	Print_str	msg_input_new 
	lea 		bx, [sub_str_new] 
	call 		Input_str
	;=====================================
	
	;=====================================
	;REPLACE		 
	
	
	
;	inc 		cl
;	cld 
	
;	lea 		si, [str_init]
;	lea 		di, [sub_str_rep]
;	call 		Find_substr


Exit:	
	mov 		ax, 4C00h
	int 		21h

END Start
	ENDS