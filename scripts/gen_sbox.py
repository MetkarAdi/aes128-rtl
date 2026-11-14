def gmul(a, b):
    """Multiply two bytes in GF(2^8) with the AES polynomial x^8+x^4+x^3+x+1."""
    p = 0
    for _ in range(8):
        if b & 1:
            p ^= a
        hi = a & 0x80
        a = (a << 1) & 0xFF
        if hi:
            a ^= 0x1B
        b >>= 1
    return p

def rotl8(x, n):
    return ((x << n) | (x >> (8 - n))) & 0xFF

def sbox_entry(x):
    inv = 0
    if x:
        inv = next(y for y in range(1, 256) if gmul(x, y) == 1)
    return inv ^ rotl8(inv, 1) ^ rotl8(inv, 2) ^ rotl8(inv, 3) ^ rotl8(inv, 4) ^ 0x63

SBOX = [sbox_entry(x) for x in range(256)]

# Independent checks against the FIPS-197 S-box table
KNOWN = {0x00: 0x63, 0x01: 0x7C, 0x10: 0xCA, 0x53: 0xED, 0xC9: 0xDD, 0xFF: 0x16}
for k, v in KNOWN.items():
    assert SBOX[k] == v, f"S[{k:02x}] = {SBOX[k]:02x}, expected {v:02x}"
assert len(set(SBOX)) == 256, "S-box must be a permutation"

with open("rtl/aes_sbox.v", "w") as f:
    f.write("module aes_sbox (\n    input      [7:0] a,\n    output reg [7:0] y\n);\n")
    f.write("    always @(*) begin\n        case (a)\n")
    for i, v in enumerate(SBOX):
        f.write(f"            8'h{i:02x}: y = 8'h{v:02x};\n")
    f.write("            default: y = 8'h00;\n        endcase\n    end\nendmodule\n")

with open("sbox.hex", "w") as f:
    for v in SBOX:
        f.write(f"{v:02x}\n")

print("S-box generated and verified.")