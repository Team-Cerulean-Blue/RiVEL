# RISC-V I-type immediate instruction test
# Uses only: addi, xori, ori, andi, slli, srli, srai
# All results left in registers for inspection.
#
# Expected final register values (see comments per instruction):

.section .text
.globl _start
_start:

# ── addi ──────────────────────────────────────────────────────────────────────
# Load a base value into x1, then build more values from it.
    addi  x1,  x0,  42        # x1  = 0  + 42        = 0x0000002A (42)
    addi  x2,  x1,  100       # x2  = 42 + 100       = 0x0000008E (142)
    addi  x3,  x0, -1         # x3  = 0  + (-1)      = 0xFFFFFFFF (-1, all ones)

# ── xori ──────────────────────────────────────────────────────────────────────
    xori  x4,  x1,  0xFF      # x4  = 0x2A ^ 0xFF    = 0x000000D5 (213)
    xori  x5,  x3, -1         # x5  = 0xFFFFFFFF ^ 0xFFFFFFFF = 0x00000000 (0)
    xori  x6,  x2,  0x0F      # x6  = 0x8E ^ 0x0F    = 0x00000081 (129)

# ── ori ───────────────────────────────────────────────────────────────────────
    ori   x7,  x1,  0xF0      # x7  = 0x2A | 0xF0    = 0x000000FA (250)
    ori   x8,  x5,  0x55      # x8  = 0x00 | 0x55    = 0x00000055 (85)

# ── andi ──────────────────────────────────────────────────────────────────────
    andi  x9,  x3,  0x0F      # x9  = 0xFFFFFFFF & 0x0F = 0x0000000F (15)
    andi  x10, x2,  0x7F      # x10 = 0x8E & 0x7F    = 0x0000000E (14)

# ── slli ──────────────────────────────────────────────────────────────────────
    slli  x11, x1,  3         # x11 = 42 << 3        = 0x00000150 (336)
    slli  x12, x8,  4         # x12 = 85 << 4        = 0x00000550 (1360)

# ── srli ──────────────────────────────────────────────────────────────────────
# srli is logical (zero-fills from MSB)
    srli  x13, x3,  4         # x13 = 0xFFFFFFFF >> 4 (logical) = 0x0FFFFFFF
    srli  x14, x11, 2         # x14 = 336 >> 2       = 0x00000054 (84)

# ── srai ──────────────────────────────────────────────────────────────────────
# srai is arithmetic (sign-fills from MSB)
    srai  x15, x3,  4         # x15 = -1 >> 4 (arith) = 0xFFFFFFFF (-1)
    srai  x16, x11, 1         # x16 = 336 >> 1 (arith) = 0x000000A8 (168)

# ── combined chain (uses all ops in sequence) ─────────────────────────────────
# Build 0xABCD from zero using only these instructions, as a bonus stress test.
    addi  x17, x0,  0xAB      # x17 = 0xAB  (171)
    slli  x17, x17, 8         # x17 = 0xAB00
    ori   x17, x17, 0xCD      # x17 = 0xABCD (43981)
    andi  x18, x17, 0xFF      # x18 = 0x00CD (205)   — low byte
    srli  x19, x17, 8         # x19 = 0x00AB (171)   — high byte
    xori  x20, x17, -1        # x20 = ~0xABCD        = 0xFFFF5432
    srai  x20, x20, 2         # x20 = 0xFFFF5432 >> 2 (arith) = 0xFFFFD50C
