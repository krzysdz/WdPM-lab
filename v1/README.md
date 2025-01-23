# Custom CISC processor

## Features

- 8-bit architecture
- 7 general-purpose registers (R0-R6)
- 1 special input register (R7)
- 1 kB RAM
- 256 instructions long program memory (16-bit instructions)
- 16 entry hardware return stack

## Instruction encoding

### Addressing

The processor supports 4 addressing modes, which are valid for all instructions, unless specified otherwise in [Instructions](#instructions).

```plain
           15 14 13     10  9   7         2   0
          +-----+---------+---------------------+
Direct    | 0 0 | O O O O | A A A A A A A A A A |
          +-----+---------+---------------------+
Immediate | 0 1 | O O O O | - - I I I I I I I I |
          +-----+---------+---------------------+
Indirect  | 1 0 | O O O O | - - - - - - - R R R |
          +-----+---------+---------------------+
Register  | 1 1 | O O O O | - - - - - - - R R R |
          +-----+---------+---------------------+
```

where:

- `O`s encode the instruction/operation code
- `A`s form a 10-bit memory address
- `I`s form an 8-bit immediate
- `R`s form a 3-bit register index (R7 is a special input register)
- `-` can be anything and will be ignored

When using indirect addressing, the top 2 memory address bits come from a special write-only "bank register" (see [CHB](#chb)).

### Instructions

The processor supports the following 16 instructions

|   | `xx00` | `xx01` | `xx10` | `xx11` |
| - | ---- | ---- | ---- | ---- |
| **`00xx`** | [NOP](#nop) | [LD](#ld) | [ADD](#add) | [SUB](#sub) |
| **`01xx`** | [NOT](#not) | [AND](#and) | [OR](#or) | [XOR](#xor) |
| **`10xx`** | [JMP](#jmp) | [JZ](#jz) | [JNZ](#jnz) | [JL](#jl) |
| **`11xx`** | [ST](#st) | [CHB](#chb) | [CALL](#call) | [RET](#ret) |

#### NOP

Code: `0000`\
Assembly: `NOP`

Does nothing, except for incrementing the program counter. Operand and addressing bits can be anything and will be ignored.

#### LD

Code: `0001`\
Assembly: `LD x`

Loads a value (from register/memory or an immediate) to accumulator.

#### ADD

Code: `0010`\
Assembly: `ADD x`

Adds operand and carry to accumulator.

**Sets carry flag.**

#### SUB

Code: `0011`\
Assembly: `SUB x`

Subtracts operand and carry from accumulator. Carry is used as borrow.

**Sets carry flag.**

#### NOT

Code: `0100`\
Assembly: `NOT`

Inverts bits in accumulator.

**Clears carry flag.**

#### AND

Code: `0101`\
Assembly: `AND x`

Performs a bitwise AND.

**Clears carry flag.**

#### OR

Code: `0110`\
Assembly: `OR x`

Performs a bitwise OR.

**Clears carry flag.**

#### XOR

Code: `0111`\
Assembly: `XOR x`

Performs a bitwise XOR.

**Clears carry flag.**

#### JMP

Code: `1000`\
Assembly: `JMP x`

Jump to code address. A typical jump will use immediate encoding (`01`) like `JMP #0` or `JMP label`, but jumps to address stored in register or memory are also supported.

#### JZ

Code: `1001`\
Assembly: `JZ x`

Jump if accumulator is 0.

#### JNZ

Code: `1010`\
Assembly: `JNZ x`

Jump if accumulator is not 0.

#### JL

Code: `1011`\
Assembly: `JL x`

Jump if the sign flag is set.

#### ST

Code: `1100`\
Assembly: `ST x`

Write value from accumulator to register or memory.

**Immediate addressing is not supported (doesn't make sense) and the instruction will behave like NOP if it is used.**

#### CHB

Code: `1101`\
Assembly: `CHB x`

Change bank register value. Set top 2 memory address bits that are used in indirect addressing mode.

**Only 2 lowest bits of immediate/register/memory value are used.**

#### CALL

Code: `1110`\
Assembly: `CALL x`

Function call. Jump to code address (like [JMP](#jmp)) and save the return address to the return stack. Return stack has only 16 entries and will overflow, so please avoid deep recursion.

#### RET

Code: `1111`\
Assembly: `RET`

Return from function. Jump to address from return stack and pop it. Popping from stack clears entries and too many returns will cause a jump to the beginning of the program. Does not accept an operand - addressing mode and operand bits can be anything and will be ignored.

## Internals

### ALU operations

ALU input A is accumulator and input B is register, memory or immediate value.

Operation code is 3-bit long. The following operations are available (directly mapped from top half of [instructions table](#instructions))
- `000` and `001` - pass value from input B
- `010` - add with carry (`A+B+Ci`), produces `Co`
- `011` - subtract with borrow (`A-B-Ci`), produces `Co` as borrow
- `100` - negate A (`~A`), constant 0 as `Co`
- `101` - bitwise AND (`A&B`), constant 0 as `Co`
- `110` - bitwise OR (`A|B`), constant 0 as `Co`
- `111` - bitwise XOR (`A^B`), constant 0 as `Co`
