start:    LD R7        ; load a
          ST R5        ; save a in R5
          LD R7        ; load b
          ST R6        ; save b in R6

loop_gcd: OR #0        ; clear carry flag
          SUB R5       ; compare a (R5) and b (ACC)
          JZ end       ; a == b => end
          JL gcd_bla   ; b < a
          LD R6        ; a < b => b = b % a
          ST R1
          LD R5
          ST R2
          CALL mod
          ST R6        ; no need to load b
          JMP loop_gcd
gcd_bla:  LD R5        ; b < a => a = a % b
          ST R1
          LD R6
          ST R2
          CALL mod
          ST R5
          LD R6        ; load b to acc
          JMP loop_gcd

end:      JMP end      ; final infinite loop

; function u8 mod(u8 a @ R1, u8 b @ R2)
mod:                   ; ACC = R1 % R2
          LD R1
mod_loop: OR #0        ; clear carry flag
          SUB R2
          JZ mod_end   ; a ≡ 0 (mod b)
          JL mod_pend  ; a ≡ acc + b (mod b) - acc is negative, add R2 to get result
          JMP mod_loop
mod_pend: OR #0        ; clear carry flag
          ADD R2
mod_end:  RET
