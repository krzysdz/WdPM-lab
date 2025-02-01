# Tests

## Test matrix

| Requirement | `random_loop_test` | `cy_clr_nop_test` | `cy_clr_any_test` | `jz_zero_test` | `jz_nz_test` | `jmp_test` | `st_test` | `and_test` | `or_test` | `xor_test` | `not_test` | `add_set_clr_cy_test` | `sub_set_clr_cy_test` | Comment |
| - | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | - |
| **1.** registered `acc` & `cy` | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | Mostly ensured by the testbench construction |
| **2.** combinational jump outputs | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | `dut_wrapper` captures those in registers |
| **3.** 1., but specifically posedge | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ | Mostly ensured by the testbench construction |
| **4.0.** `ADD` | ❓[^rand] | ✔ | -          | - | - | - | - | - | - | - | - | ✔ | - |  |
| **4.1.** `SUB` | ❓[^rand] | - | ✔          | - | - | - | - | - | - | - | - | - | ✔ |  |
| **4.2.** `LD`  | ✔        | ✔ | ✔          | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | - | ✔ | ✔ |  |
| **4.3.** `ST`  | ❓[^rand] | - | ❓[^any_cy] | - | - | - | ✔ | - | - | - | - | - | - |  |
| **4.4.** `AND` | ❓[^rand] | - | ❓[^any_cy] | - | - | - | - | ✔ | - | - | - | - | - |  |
| **4.5.** `OR`  | ❓[^rand] | - | ❓[^any_cy] | - | - | - | - | - | ✔ | - | - | - | - |  |
| **4.6.** `XOR` | ❓[^rand] | - | ❓[^any_cy] | - | - | - | - | - | - | ✔ | - | - | - |  |
| **4.7.** `NOP` | ❓[^rand] | ✔ | ❓[^any_cy] | - | - | - | - | - | - | - | - | - | - |  |
| **4.8.** `NOT` | ❓[^rand] | - | ❓[^any_cy] | - | - | - | - | - | - | - | ✔ | - | - |  |
| **4.9.** `JMP` | ❓[^rand] | - | ❓[^any_cy] | - | - | ✔ | - | - | - | - | - | - | - |  |
| **4.10.** `JZ` | ❓[^rand] | - | ❓[^any_cy] | ✔ | ✔ | - | - | - | - | - | - | - | - |  |
| **5.** `cy` set by `ADD` and `SUB` | ❓[^rand] | ✔ | ✔ | - | - | - | - | - | - | - | - | ✔ | ✔ |  |
| **6.** `cy` cleared by other instructions | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | All tests contains min. 1 instruction other than `ADD` or `SUB` |

Legend:

- \- —  not covered
- ✔ — covered
- ❓ — see comment

[^rand]: After first load everything is completely random and nothing is guaranteed.
[^any_cy]: After `LD` and `SUB` there is a random (valid) instruction other than `ADD` and `SUB`

## Remarks

1. _Latched_ in requirements is understood as _registered_ — requirement 3. makes it obvious that this was the author's intention
2. Requirements 5. and 6. are understood as:
   > 1. `ADD` and `SUB` set `cy` appropriately as carry/borrow (unsigned over/underflow) — `1` if it was generated/occurred, `0` if not
   > 2. All other instructions set `cy` to `0`
