cseg segment para public 'CODE'
        overlay proc far
                assume cs:cseg
                sub ax, bx
                retf
        overlay endp
cseg ends
end