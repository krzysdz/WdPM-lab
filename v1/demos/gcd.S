start:    LD R7        ; load a
          ST R5        ; save a in R5
          ; TEST - do random things to memory to prevent some optimizations
          ST @0xAB     ; save a somewhere in memory (constant address)
          ST [R5]      ; save somewhere random
          CHB [R7]     ; randomly change bank
          LD [R7]      ; perform random memory load
          ; END TEST
          LD R7        ; load b
          ST R6        ; save b in R6

loop_gcd: JZ pre_end   ; b == 0 => end
          ST R4        ; use R4 as temp, t = b
          ST R2        ; arg2 = b
          LD R5
          ST R1        ; arg1 = a
          CALL mod     ; acc = mod(a, b)
          ST R6        ; b = mod(a, b)
          LD R4
          ST R5        ; a = t
          LD R6        ; load b to acc
          JMP loop_gcd

pre_end:  LD R5        ; load result to acc
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
