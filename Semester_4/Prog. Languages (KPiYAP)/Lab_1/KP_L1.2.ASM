	IDEAL                    

	MODEL tiny

	DATASEG

	hello db "Hello, asm!", 0Dh, 0Ah, '$'

	CODESEG
	org 256
Start:

	lea dx, [hello]

	mov ah, 9h
	int 21h

Exit:
	mov ax, 4c00h
	int 21h

	END Start
	ends