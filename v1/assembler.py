from typing import Optional
from sys import argv
from enum import Enum

REG_COUNT = 8
DATA_WIDTH = 8
ADDR_WIDTH = 10
MAX_INSTRUCTIONS = 2**8
NOP_PAD = "0000"


class Addressing(Enum):
    DIRECT = 0
    IMMEDIATE = 1
    REGISTER = 2
    INDIRECT = 3


def r2i(reg: str) -> int:
    assert reg[0] == "R"
    r = int(reg[1:])
    assert r < REG_COUNT and r > 0
    return r


def val_checked_as_unsigned(val: str, max_width: int) -> int:
    r = int(val, base=0)
    if r < 0:
        r = -r
        assert r.bit_length() < max_width - 1
        r = 2**max_width - r
    assert r.bit_length() < max_width
    return r


def extract_operand(operand_str: Optional[str]) -> tuple[Addressing, int]:
    if operand_str is None:
        return Addressing.DIRECT, 0
    match operand_str[0]:
        case "R":
            return Addressing.REGISTER, r2i(operand_str)
        case "[":
            assert operand_str[-1] == "]"
            return Addressing.INDIRECT, r2i(operand_str[1:-1])
        case "#":
            return Addressing.IMMEDIATE, val_checked_as_unsigned(
                operand_str[1:], DATA_WIDTH
            )
        case "@":
            return Addressing.DIRECT, val_checked_as_unsigned(
                operand_str[1:], ADDR_WIDTH
            )
        case _:
            raise RuntimeError(f"Incorrect addressing mode for operand {operand_str}")


def parse_line(line: str) -> Optional[str]:
    ic_parts = [p.strip() for p in line.split(";", maxsplit=1)]
    inst, comm = ic_parts if len(ic_parts) == 2 else (ic_parts[0], None)
    inst_parts = [p.strip() for p in inst.upper().split()]
    assert len(inst_parts) <= 2
    operand_type, operand_value = extract_operand(
        inst_parts[1] if len(inst_parts) == 2 else None
    )

    match inst_parts:
        case ["NOP"]:
            opc = 0b0000
        case ["LD", _]:
            opc = 0b0001
        case ["ADD", _]:
            opc = 0b0010
        case ["SUB", _]:
            opc = 0b0011
        case ["NOT"]:
            opc = 0b0100
        case ["AND", _]:
            opc = 0b0101
        case ["OR", _]:
            opc = 0b0110
        case ["XOR", _]:
            opc = 0b0111
        case ["JMP", _]:
            opc = 0b1000
        case ["JZ", _]:
            opc = 0b1001
        case ["JNZ", _]:
            opc = 0b1010
        case ["JL", _]:
            opc = 0b1011
        case ["ST", _]:
            opc = 0b1100
        case ["CHB", _]:
            opc = 0b1101
            if operand_type == Addressing.IMMEDIATE and operand_value >= 2 ** (
                ADDR_WIDTH - DATA_WIDTH
            ):
                print(
                    "WARNING: Immediate specified for CHB is too big and will be truncated by the CPU"
                )
        case ["CALL", _]:
            opc = 0b1110
        case ["RET"]:
            opc = 0b1111
        case _:
            return f"//; {comm}" if comm else None

    result = operand_type.value << 14 | opc << 10 | operand_value
    op_str = f"{result:0>4X} // {inst}"
    return op_str if comm is None else f"{op_str} ; {comm}"


def process_file(filename: str, out_f: str = "asm.hex"):
    with open(filename) as sf:
        source = sf.read()

    source_lines = [l.strip() for l in source.splitlines()]
    ass_l = [parse_line(l) for l in source_lines]
    ass_l = [l for l in ass_l if l is not None]

    n_inst = sum(1 if not l.startswith("//") else 0 for l in ass_l)
    assert n_inst <= MAX_INSTRUCTIONS
    ass_l.extend([NOP_PAD] * (MAX_INSTRUCTIONS - n_inst))

    with open(out_f, "wt") as of:
        of.write("\n".join(ass_l))


if __name__ == "__main__":
    if len(argv) != 2:
        print(f"Usage: python {argv[0]} ASSEMBLY_FILE")
        exit(1)

    process_file(argv[1])
