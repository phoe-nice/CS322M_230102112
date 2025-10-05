# ENCODINGS.md

The instructions have been encoded as follows:

## RVX10 Instructions

![RVX10 Instructions](https://github.com/phoe-nice/CS322M_230102112/blob/30dfca0a867d52f629324d55d34d6e17448ede1d/RVX10/images/RVX10Instructions.png)

## Encoding Table

![Encoding Table (Concrete)](https://github.com/phoe-nice/CS322M_230102112/blob/bfa5425d5005f908d769b12bfe09e8257ab9ed32/RVX10/images/EncodingTable.png)

---

## Instruction format (R-type style used by RVX10)

Bit positions (MSB left):

```
 31          25 24   20 19   15 14   12 11   7 6     0
 +-------------+-------+-------+-------+------+------+
 |    func7    |  rs2  |  rs1  | func3 |  rd  |  op  |
 +-------------+-------+-------+-------+------+------+
```

Field widths:

* func7: 7 bits (bits 31..25)
* rs2:   5 bits (bits 24..20)
* rs1:   5 bits (bits 19..15)
* func3: 3 bits (bits 14..12)
* rd:    5 bits (bits 11..7)
* op:    7 bits (bits 6..0)

All RVX10 custom instructions use the 7-bit opcode `0001011(0x0B)`.

---

## Encoding table (concrete)

| Instruction | Opcode | funct7 | funct3 | Sample Regs (rd, rs1, rs2) | 32-bit Binary Encoding                         | Hex Code  | ALUControl | Description               |
|-------------|--------|--------|--------|----------------------------|------------------------------------------------|-----------|------------|---------------------------|
| ANDN        |  0x0B  |0000000 |  000   |    rd=10, rs1=5, rs2=6     | 0000000 00110 00101 000 01010 0001011          | 0x00C28A8B| 01000      | x10 = x5 & ~x6            |
| ORN         |  0x0B  |0000000 |  001   |    rd=10, rs1=5, rs2=6     | 0000000 00110 00101 001 01010 0001011          | 0x00C29A8B| 01001      | x10 = x5 | ~x6            |
| XNOR        |  0x0B  |0000000 |  010   |    rd=10, rs1=5, rs2=6     | 0000000 00110 00101 010 01010 0001011          | 0x00C2AA8B| 01010      | x10 = ~(x5 ^ x6)          |
| MIN         |  0x0B  |0000001 |  000   |    rd=10, rs1=5, rs2=6     | 0000001 00110 00101 000 01010 0001011          | 0x04C28A8B| 01011      | x10 = min(x5, x6)         |
| MAX         |  0x0B  |0000001 |  001   |    rd=10, rs1=5, rs2=6     | 0000001 00110 00101 001 01010 0001011          | 0x04C29A8B| 01100      | x10 = max(x5, x6)         |
| MINU        |  0x0B  |0000001 |  010   |    rd=10, rs1=5, rs2=6     | 0000001 00110 00101 010 01010 0001011          | 0x04C2AA8B| 01101      | x10 = minu(x5, x6)        |
| MAXU        |  0x0B  |0000001 |  011   |    rd=10, rs1=5, rs2=6     | 0000001 00110 00101 011 01010 0001011          | 0x04C2BA8B| 01110      | x10 = maxu(x5, x6)        |
| ROL         |  0x0B  |0000010 |  000   |    rd=10, rs1=5, rs2=6     | 0000010 00110 00101 000 01010 0001011          | 0x08C28A8B| 01111      | x10 = rol(x5, x6[4:0])    |
| ROR         |  0x0B  |0000010 |  001   |    rd=10, rs1=5, rs2=6     | 0000010 00110 00101 001 01010 0001011          | 0x08C29A8B| 10000      | x10 = ror(x5, x6[4:0])    |
| ABS         |  0x0B  |0000011 |  000   |    rd=10, rs1=5, rs2=0     | 0000011 00000 00101 000 01010 0001011          | 0x0C028A8B| 10001      | x10 = abs(x5)             |

---
