# Tests

## Test matrix

| Requirement | `random_loop_test` | `cy_clr_nop_test` | `cy_clr_any_test` | `jz_zero_test` | `jz_nz_test` | `jmp_test` | `st_test` | `and_test` | `or_test` | `xor_test` | `not_test` | `add_set_clr_cy_test` | `sub_set_clr_cy_test` | Comment |
| - | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | - |
| **1.** registered `acc` & `cy` | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | - | ✔ | ✔ | Ensured by the testbench construction |
| **2.** combinational jump outputs | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | `dut_wrapper` captures those in registers |
| **3.** 1., but specifically posedge | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | - | ✔ | ✔ | Ensured by the testbench construction |
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
- ❓ — see footnote

[^rand]: After first load everything is completely random and nothing is guaranteed.
[^any_cy]: After `LD` and `SUB` there is a random (valid) instruction other than `ADD` and `SUB`

## Remarks

1. _Latched_ in requirements is understood as _registered_ — requirement 3. makes it obvious that this was the author's intention
2. Requirements 5. and 6. are understood as:
   > 1. `ADD` and `SUB` set `cy` appropriately as carry/borrow (unsigned over/underflow) — `1` if it was generated/occurred, `0` if not
   > 2. All other instructions set `cy` to `0`

## Test plan

### Requirements 1. and 3.

**Requirement**: `acc` and `cy` outputs are registered and updated on posedge. (see [remarks](#remarks))

**Verification steps**:

1. Provide inputs which should set accumulator and carry signals to a known value.
2. Wait for rising clock edge.
3. Provide different input, which should change the accumulator and/or carry output.
4. Read `acc` and `cy` before next clock edge

**Pass criteria**: Read `acc` and `cy` remained unchanged from expected values after setting new inputs.

### Requirement 2

**Requirement**: Jump enable and jump address outputs are combinational.

**Verification steps**:

1. Provide inputs which should generate known `jmp_ce_temp` and `jmp_addr_temp` outputs.
2. At rising clock edge capture those outputs in registers.
3. Check if the captured data is up to date or output from earlier instruction.

**Pass criteria**: Data captured on posedge is not outdated (doubly registered).

### Requirement 4

**Requirement**: Instructions behave as described in `OpCodes.v` (`acc` and jump outputs are described there).

**Verification steps**:

1. Provide inputs which should set known `acc` value.
2. Wait for rising clock edge.
3. Provide inputs for the desired instruction.
4. Wait for rising clock edge.
5. Check if `acc` value and jump signals.

**Pass criteria**: All of the following are met:

1. `acc` value changed according to description,
2. `jmp_ce_temp` is `1` if the instruction is `JMP` or `acc` was 0 and instruction is `JZ`,
3. if `jmp_ce_temp` is `1`, `jmp_addr_temp` is `argument`.

### Requirement 5

**Requirement**: `ADD` and `SUB` set `cy` as unsigned over/underflow (aka. carry/borrow).

**Verification steps**:

1. `ADD`:
   1. Provide inputs which should set known `acc` value - greater than 0.
   2. Wait for rising clock edge.
   3. Provide inputs for `ADD` with `register` > 255 - `acc`.
   4. Wait for rising clock edge.
   5. Check `cy` value.
   6. Provide inputs for `ADD` with `register` < 255 - `acc` (current).
   7. Wait for rising clock edge.
   8. Check `cy` value.
2. `SUB`:
   1. Provide inputs which should set known `acc` value - smaller than 255.
   2. Wait for rising clock edge.
   3. Provide inputs for `SUB` with `register` > `acc`.
   4. Wait for rising clock edge.
   5. Check `cy` value.
   6. Provide inputs for `SUB` with `register` < `acc` (current).
   7. Wait for rising clock edge.
   8. Check `cy` value.

**Pass criteria**: `cy` is `1` on first check and `0` during second.

### Requirement 6

**Requirement**: Instructions other than `ADD` and `SUB` should always set `cy` to `0`

**Verification steps**:

1. Provide inputs which should set known `acc` value - greater than 0.
2. Wait for rising clock edge.
3. Provide inputs for `ADD` with `register` > 255 - `acc`.
4. Wait for rising clock edge.
5. Provide any instruction other than `ADD` and `SUB`, e.g. `NOP`.
6. Wait for rising clock edge.
7. Check `cy` value.

**Pass criteria**: Last `cy` value is `0`.
