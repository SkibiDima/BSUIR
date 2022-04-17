	.model small
	.stack 100h
	.data

	msg1 db "Input string:", 0dh, 0ah, '$' 
	msg2 db 0dh, 0ah, "Enter the substring you want to delete:", 0dh, 0ah, '$'
	msg3 db 0dh, 0ah, "Result: $" 
	msg4 db 0dh, 0ah, "Enter new substring: $"
	error_message db "Buffer overlflow",0Dh,0Ah,'$'
	string db 40805 dup("$")
	sbstrToRemove db 202 dup("$")
	sbstrToInsert db 202 dup("$")
	capacity EQU 200
	string_size dw 0
	sbstrToRemove_size dw 0
	sbstrToInsert_size dw 0
	flag dw 0

	.code

ReplaceSubstring proc

	Cycle:
	mov flag, 1
	push si
	push di
	push cx

	mov bx, si

	xor cx, cx
	mov cx, sbstrToRemove_size

	repe cmpsb
	je FOUND
	jne NOT_FOUND

	FOUND:
	call DeleteSubstring
	mov ax, bx
	call InsertSubstring
	mov dx, sbstrToInsert_size
	add string_size, dx      
	mov flag, dx

	NOT_FOUND:
	pop cx
	pop di
	pop si
	add si, flag

	Loop Cycle

	ret
endp ReplaceSubstring  

DeleteSubstring proc

	push si
	push di
	mov cx, string_size
	mov di, bx

	repe movsb

	pop di
	pop si

	ret                
endp DeleteSubstring

InsertSubstring proc

	lea cx, string   ; string[2] 1st symbol address,string[1] is string lenght
	add cx, string_size   ; add string length to get to next symbol after the last
	mov si, cx          ; last symbol as a source 
	dec si              ; at the last symbol
	mov bx, si          ; save last symbol in bx
	add bx, sbstrToInsert_size ; now there is the last symbol of new string in bx
	mov di, bx          ; new last symbol is reciever            

	mov dx, ax          ; ax is a place to insert
	sub cx, dx          ; after last symbol -= place to insert
	std                 ; moving backward
	repe movsb

	lea si, sbstrToInsert ; source is sbstr 1st symbol
	mov di, ax          ; reciever is a place to insert
	xor cx, cx          ; set cx to zero
	mov cx, sbstrToInsert_size ; sbstr length to cx
	cld                 ; moving forward
	repe movsb            

ret
endp InsertSubstring                


	; I/O procedures
	;GETSTR
gets proc   

	mov cx,capacity-1    ; количество итераций для ввода
    
start_input_string:     
    
	mov ah,01h              ; 01h - считать символ с клавиатуры
	int 21h                 ; символ автоматически помещ. в регистр al
	cmp al,36				;сравнение символа с '$'
	je end_input_string
	cmp al,13               ; сравнение символа с "enter"
	je end_input_string     ; если ZF = 1, то есть если истина

	mov [bx], al            ; помещаем введенный символ по адресу bx 
	inc bx                  ; увеличиваем значение расп. по адресу в bx на 1
	inc dx                  ; увеличиваем действительный размер строки
    
	loop start_input_string
    
end_input_string:

	ret
endp gets


puts proc
	mov ah, 9 
	int 21h
	ret
endp puts

start:
	mov ax, @data
	mov ds, ax
	mov es, ax     

	lea dx, msg1
	call puts
	mov dx,string_size
	lea bx,string
	call gets
	mov string_size,dx

	lea dx, msg2
	call puts
	mov dx, sbstrToRemove_size
	lea bx, sbstrToRemove
	call gets
	mov sbstrToRemove_size,dx        

	lea dx, msg4
	call puts
	mov dx,sbstrToInsert_size
	lea bx, sbstrToInsert
	call gets
	mov sbstrToInsert_size,dx

	xor ax,ax
	mov ax,string_size
	mul sbstrToInsert_size
	cmp ax, 30000
	ja end_err

	xor cx, cx
	mov cx, string_size
	sub cx, sbstrToRemove_size
	jb endjb
	inc cx
	cld

	lea si, string
	lea di, sbstrToRemove

	call ReplaceSubstring

endjb:   
	lea dx, msg3
	call puts
	lea dx, string
	call puts

	mov ah, 4ch
	int 21h

end_err:
	lea dx, error_message
	call puts
	mov ah, 4ch
	int 21h

	ret
end start
