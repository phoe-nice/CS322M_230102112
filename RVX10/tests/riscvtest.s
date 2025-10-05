main:
    # Load x5 = 0x12345678
    lui   x5, 0x12345          # x5 = 0x12345000
    addi  x5, x5, 0x678        # x5 = 0x12345678

    # Setup rotate amount = 0 in x6
    addi  x6, x0, 0            # x6 = 0

    # Validation 1: Rotate by 0 returns rs1
    rol   x7, x5, x6           # x7 = rol(x5, 0) = x5
    ror   x8, x5, x6           # x8 = ror(x5, 0) = x5

    # Branch test: if x7 == x5 jump to label1 (should take)
    beq   x7, x5, label1

    # This instruction should not execute
    addi  x9, x0, 99

label1:
    # Interleaved instruction
    andn  x9, x5, x6           # x9 = x5 & ~x6

    # Setup x10 = INT_MIN (0x80000000)
    lui   x10, 0x80000         # x10 = 0x80000000 upper
    addi  x10, x10, 0          # x10 unchanged

    # Validation 2: ABS(INT_MIN)
    abs   x11, x10             # x11 = abs(INT_MIN) = 0x80000000

    # Branch test: if abs(INT_MIN) == 0x80000000 jump to label2
    beq   x11, x10, label2

    # This instruction should not execute
    addi  x12, x0, 123

label2:
    # Setup x13 = 0x54321FED (split with lui + addi)
    lui   x13, 0x54321
    addi  x13, x13, -0x103     # 0xFED signed immediate

    # Setup x14 = -1 (0xFFFFFFFF)
    addi  x14, x0, -1

    # Interleaved instructions
    orn   x15, x13, x14
    xnor  x16, x13, x14

    # Validation 3: x0 write ignored (attempt to write to x0)
    andn  x0, x13, x14         # Should have no effect

    # Branch test: skip next addi if x0 == 0 (always true)
    beq   x0, x0, label3

    # This instruction should not execute
    addi  x17, x0, 77

label3:
    # More instructions
    min   x17, x13, x14
    max   x18, x13, x14

    # Setup final store values
    addi  x18, x0, 25          # x18 = 25 (final value)
    addi  x19, x0, 100         # x19 = 100 (store address)

    # Validation 4: Final store writes 25 to address 100
    sw    x18, 0(x19)          # MEM[100] = 25

done:
    beq   x2, x2, done         # Infinite loop to end test
