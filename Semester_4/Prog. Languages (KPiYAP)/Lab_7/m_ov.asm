cseg segment para public 'CODE'
        overlay proc far
                assume cs:cseg
                mul bx
                retf
        overlay endp
cseg ends
end