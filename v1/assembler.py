import re
from dataclasses import dataclass
from enum import Enum
from string import ascii_uppercase, digits
from sys import argv
from typing import Literal, Optional

REG_COUNT = 8
DATA_WIDTH = 8
ADDR_WIDTH = 10
MAX_INSTRUCTIONS = 2**8
NOP_PAD = "0000"
LABEL_ALPHA = ascii_uppercase + digits + "_"

REG_REGEX = re.compile(r"^R\d+$", flags=re.ASCII)


class Addressing(Enum):
    DIRECT = 0
    IMMEDIATE = 1
    INDIRECT = 2
    REGISTER = 3


@dataclass
class ASMLine:
    address: int
    comment: Optional[str] = None
    inst: Optional[str] = None
    op: Optional[int] = None
    ref_label: Optional[str] = None

    def as_hex(self) -> Optional[str]:
        result: str | None = None
        if self.op is not None:
            result = f"{self.op:0>4X}"
        comment_part: str | None = None
        if self.inst is not None:
            comment_part = self.inst
        if self.comment is not None:
            if comment_part:
                comment_part = comment_part + " ; " + self.comment
            else:
                comment_part = "; " + self.comment
        if comment_part is not None:
            if result is not None:
                result = result + " // " + comment_part
            else:
                result = "// " + comment_part
        return result


def r2i(reg: str) -> int:
    assert reg[0] == "R"
    r = int(reg[1:])
    assert r < REG_COUNT and r > 0
    return r


def val_checked_as_unsigned(val: str, max_width: int) -> int:
    r = int(val, base=0)
    if r < 0:
        r = -r
        assert r.bit_length() < max_width
        r = 2**max_width - r
    assert r.bit_length() <= max_width
    return r


def extract_operand(
    operand_str: Optional[str], known_labels: dict[str, int]
) -> tuple[Addressing, int | str] | tuple[Literal[Addressing.IMMEDIATE], str]:
    if operand_str is None:
        return Addressing.DIRECT, 0
    is_reg = REG_REGEX.fullmatch(operand_str) is not None
    possible_label = (
        not is_reg
        and all(c in LABEL_ALPHA for c in operand_str)
        and not operand_str[0].isdigit()
    )
    match operand_str[0]:
        case "R":
            if not possible_label:
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
            if not possible_label:
                raise RuntimeError(
                    f"Incorrect addressing mode for operand {operand_str}"
                )
    assert possible_label
    return Addressing.IMMEDIATE, known_labels.get(operand_str, operand_str)


def parse_line(
    line: str, known_labels: dict[str, int], current_addr: int
) -> tuple[Optional[ASMLine], int]:
    ic_parts = [p.strip() for p in line.split(";", maxsplit=1)]
    inst, comm = ic_parts if len(ic_parts) == 2 else (ic_parts[0], None)

    label_end = inst.find(":")
    if label_end > 0:
        label = inst[:label_end].rstrip().upper()
        inst = inst[label_end + 1 :].lstrip()
        assert label not in known_labels
        known_labels[label] = current_addr

    inst_parts = [p.strip() for p in inst.upper().split()]
    assert len(inst_parts) <= 2
    operand_type, operand_value = extract_operand(
        inst_parts[1] if len(inst_parts) == 2 else None, known_labels
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
            return ASMLine(current_addr, comm) if comm else None, current_addr

    result = operand_type.value << 14 | opc << 10
    if isinstance(operand_value, str):
        return (
            ASMLine(current_addr, comm, inst, result, operand_value),
            current_addr + 1,
        )
    result |= operand_value
    return ASMLine(current_addr, comm, inst, result), current_addr + 1


def process_file(filename: str, out_f: str = "asm.hex"):
    with open(filename) as sf:
        source = sf.read()

    source_lines = [l.strip() for l in source.splitlines()]
    known_labels: dict[str, int] = {}
    current_address = 0
    ass_l: list[ASMLine] = []
    for l in source_lines:
        line, current_address = parse_line(l, known_labels, current_address)
        if line:
            ass_l.append(line)
    # Fixup labels
    for al in ass_l:
        if al.ref_label is not None:
            assert al.ref_label in known_labels
            assert al.op is not None
            al.op |= known_labels[al.ref_label]
            al.ref_label = None

    assert current_address <= MAX_INSTRUCTIONS
    ass_hex = [al.as_hex() for al in ass_l]
    ass_hex = [l for l in ass_hex if l is not None]
    ass_hex.extend([NOP_PAD] * (MAX_INSTRUCTIONS - current_address))

    with open(out_f, "wt") as of:
        of.write("\n".join(ass_hex))


if __name__ == "__main__":
    if len(argv) != 2:
        print(f"Usage: python {argv[0]} ASSEMBLY_FILE")
        exit(1)

    process_file(argv[1])
