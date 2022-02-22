.model small
.stack 256

.data

Error_Write db "Write error!",0Dh,0Ah,'$'
Error_Read db "Read error!",0Dh,0Ah,'$'
Information db "Byte sent: $"

.code

jmp start

Init_COM1 proc
   xor ax,ax        ; clear ax
   mov al,10100011b ; baud 2400, stop-bit 1, 7 bit word
   mov dx,0         ; port-transmitter number
   int 14h 	    ; read
   ret
Init_COM1 endp

IsWrite_COM1 proc   ; verification
   mov al,'A'       ; set symbol
   mov ah,1         ;
   mov dx,0         ; port-transmitter number
   int 14h
   test al,80h	    ; 10000000b mean signal is detected
   jnz NoWRite	    ; no signal!
   ret
IsWrite_COM1 endp

NoWRite proc
   mov ah,9
   mov dx,offset Error_Write
   add dx,2
   int 21h
   ret
NoWRite endp

IsRead_COM2 proc
   mov dx,1         ; port-recivier number
   int 14h
   test al,80h      ; 10000000b mean signal is detected
   jnz NoRead
   ret
IsRead_COM2 endp

NoRead proc
   mov ah,09h
   mov dx,offset Error_Read
   add dx,2
   int 21h
   ret
NoRead endp

Output proc
   mov ah,02h
   mov dl,al        ; transmitted byte in AL
   int 21h
   ret
Output endp

Exit proc
   mov ax,4C00h
   int 21h
   ret
Exit endp

start:
   call Init_COM1
   call IsWrite_COM1
   mov al,'O'
   call IsRead_COM2
   call Output

   call Exit

end start