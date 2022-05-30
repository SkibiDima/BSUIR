cseg segment para public 'CODE'
        overlay proc far
                assume cs:cseg
                div bx
                retf
        overlay endp
cseg ends
end
