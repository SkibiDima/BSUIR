.model small
.stack 100h

.data

Error_Write db "Write error!",0Dh,0Ah,'$'
Error_Read db "Read error!",0Dh,0Ah,'$'
Information db "Byte sent: $"
Data_Byte db '3'
Data_Byte2 db ?
           
.code

Init_COM1 proc
; set 7=1 to 3FB -- 3F8, 3F9 able to control speed
    mov al,80h  ; 7bit = 1
    mov dx,3FBh ; LCR number
    out dx,al	; set setting

; set frequency 9600 baud
    mov dx,3F8h ; COM1 number
    mov al,00h  ;
    out dx,al	; set
    mov al,0Ch	; 
    mov dx,3F9h	; setting data
    out dx,al	; transfer frequency



; set in Modem Control Register required bytes
; 0 - DTR, 1 - RTS, 3 - OUT2
    mov dx,3FCh ; MCR number
    mov al,00001011b
    out dx,al

    mov dx,3F9h ; 3FB 7b=1, 3F9 calls interrupts
    mov al,00h  ; 0b & 1b = 0, no interrupts
    out dx,al   ; set
    ret
Init_COM1 endp

IsWrite_COM1 proc
    xor al,al
    mov dx,3FDh ; portout function
    in al,dx
    test al,10h ; check 5 = 1 setted
    jnz NoWRite ; bit = 0, some error in port
    ret
IsWrite_COM1 endp

NoWRite proc
   mov ah,09h
   mov dx,offset Error_Write
   int 21h
   ret
NoWRite endp

IsRead_COM2 proc
    xor al,al
    mov dx,3FDh
    in al,dx
    test al,10b ; check bit setted
    jnz NoRead 	; bit = 0, some error in port
    ret
IsRead_COM2 endp

NoRead proc
   mov ah,09h
   mov dx,offset Error_Read
   int 21h
   ret
NoRead endp

Send_Byte proc
    mov dx,3F8h
    mov al,Data_Byte
    out dx,al	; load data in COM1-port
    ret
Send_Byte endp

Read_Byte proc
    mov dx,3F8h
    in al,dx
    mov Data_Byte2,al ; load byte from COM1-port
    ret
Read_Byte endp

Exit proc
    mov ax,4C00h
    int 21h
    ret
Exit endp

start:
    mov ax,@data
    mov ds,ax
    call Init_COM1
    call IsWrite_COM1
    call Send_Byte
    mov al,02h
    call IsRead_COM2
    call Read_Byte
    mov dx,offset Information
    mov ah,09h
    int 21h
    mov ah,02h
    mov dl,Data_Byte2
    int 21h 
    call Exit
   
end start