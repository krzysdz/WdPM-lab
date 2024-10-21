LD R3	; load user input (a)
ST R0	; save it to R0
LD R3	; load user input (b)
ST R1	; save it to R1
ADD R0	; acc = a + b
; This will give wrong result if the carry flag is set
SUB R1	; acc = a
XOR R0	; clear acc
