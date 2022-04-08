	IDEAL                    

	MODEL small

	DATASEG

	hello db "Hello, asm!", 0Dh, 0Ah, '$'

	STACK 256

	CODESEG

Start:
	mov ax, @data ;        
	mov ds, ax

	lea dx, [hello]

	mov ah, 9h
	int 21h

Exit:
	mov ax, 4c00h
	int 21h

	END Start
	ends