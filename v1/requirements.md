# Requirements

1. Reset signal `rst` is asynchronous and active in high state.
2. Reset clears accumulator output and flags.
3. Reset has priority over other operations.
4. Accumulator output `acc_v` and flags, except for zero (`flag_z`), are registered and updated on positive clock (`clk`) edge.
5. Carry flag `flag_cy` is updated on positive clock edge only if `ce_cy` signal is high.
6. Accumulator and remaining flags are updated on positive clock edge only if `ce_a` is high.
7. If carry flag is to be updated, depending on operation its value should be:
   - `ADD`: generated carry,
   - `SUB`: generated borrow,
   - `NOT`, `AND`, `OR`, `XOR`: constant `0`.
8. If overflow flag `flag_o` is to be updated, its value should be:
   - `1` if the operation is `ADD` or `SUB` and an overflow occurred (the sign of result is different from the real full-width one),
   - `0` in all other cases.
9. Zero flag is high if `acc_v` is `0`.
10. Sign flag `flag_s` is the highest bit of accumulator.
11. `data_src` selects a value from `immediate`, `reg_out`, `mem_out` to output as `alu_in` according to the following table:

    | `data_src`           | expected `alu_in` |
    | -------------------- | ----------------- |
    | 00 - `SRC_MEM_ADDR`  | `mem_out`         |
    | 01 - `SRC_IMMEDIATE` | `immediate`       |
    | 10 - `SRC_INDIRECT`  | `mem_out`         |
    | 11 - `SRC_REG`       | `reg_out`         |

12. `ADD` and `SUB` operations always use carry flag as carry and borrow respectively.
13. If accumulator is to be updated, depending on `op` its value should be[^alu_args]:
    1. `001` (`LD`): B
    2. `010` (`ADD`): sum of A, B and carry
    3. `011` (`SUB`): A minus B and borrow
    4. `100` (`NOT`): bitwise negation of A
    5. `101` (`AND`): bitwise AND of A and B
    6. `110` (`OR`): bitwise OR of A and B
    7. `111` (`XOR`): bitwise XOR of A and B

[^alu_args]: A is `acc_v`, B is `alu_in`
