from typing import Optional
from sys import argv

def r2i(reg: str) -> int:
    assert reg[0] == "R"
    r = int(reg[1:])
    assert r <= 3
    return r

def parse_line(line: str) -> Optional[str]:
    parts = [p.strip() for p in line.split(";", maxsplit=1)]

    inst, comm = parts if len(parts) == 2 else (parts[0], None)

    match [p.strip() for p in inst.upper().split()]:
        case ["ADD", reg]:
            result = 0b0000 << 2 | r2i(reg)
        case ["SUB", reg]:
            result = 0b0001 << 2 | r2i(reg)
        case ["AND", reg]:
            result = 0b0010 << 2 | r2i(reg)
        case ["OR", reg]:
            result = 0b0011 << 2 | r2i(reg)
        case ["XOR", reg]:
            result = 0b0100 << 2 | r2i(reg)
        case ["NOT"]:
            result = 0b0101 << 2
        case ["LD", reg]:
            result = 0b0110 << 2 | r2i(reg)
        case ["ST", reg]:
            result = 0b0111 << 2 | r2i(reg)
        case ["NOP", reg]:
            result = 0b1111 << 2
        case _:
            return f"//; {comm}" if comm else None

    op_str = f"{result:0>2X} // {inst}"
    return op_str if comm is None else f"{op_str} ; {comm}"

def process_file(filename: str, out_f: str = "aaa.hex"):
    with open(filename) as sf:
        source = sf.read()

    source_lines = [l.strip() for l in source.splitlines()]
    ass_l = [parse_line(l) for l in source_lines]
    ass_l = [l for l in ass_l if l is not None]

    n_inst = sum(1 if l.startswith("//") else 0 for l in ass_l)
    assert n_inst <= 32
    ass_l.extend(["3F"] * (32 - n_inst))

    with open(out_f, "wt") as of:
        of.write("\n".join(ass_l))

if __name__ == "__main__":
    if (len(argv) != 2):
        print(f"Usage: python {argv[0]} ASSEMBLY_FILE")
        exit(1)

    process_file(argv[1])
