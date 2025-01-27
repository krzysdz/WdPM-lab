LD R7
ST [R7]
LD [R7]
JZ t2
t1: LD  #200
    SUB #220
    JL  t2   ; should jump
    NOP
t2:	LD  #200
    SUB #180
    JL  t3   ; should not jump
    NOP
t3: LD  #-10
    SUB #-5
    JL  t4   ; ?? - jumps, but what should it do?
    NOP
t4: LD  #-10
    SUB #-15
    JL  t5   ; opposite to t3
    NOP
t5: LD  #-100
    SUB #-40
    JL  t6   ; should be same as t3
    NOP
t6: LD  #-100
    SUB #40
    JL  t7   ; opposite to t5/t3
    NOP
t7: LD  #100
    ADD #40
    LD  #-100
    ADD #-40
e:  JMP e
