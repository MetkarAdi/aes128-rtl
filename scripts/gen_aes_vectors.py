import random
from Crypto.Cipher import AES

random.seed(7)
NUM_RANDOM = 500

def enc(key_hex, pt_hex):
    return AES.new(bytes.fromhex(key_hex), AES.MODE_ECB).encrypt(bytes.fromhex(pt_hex)).hex()

fixed = [
    ("2b7e151628aed2a6abf7158809cf4f3c", "3243f6a8885a308d313198a2e0370734"),  # FIPS-197 App. B
    ("000102030405060708090a0b0c0d0e0f", "00112233445566778899aabbccddeeff"),  # FIPS-197 App. C.1
    ("00" * 16, "00" * 16),
    ("ff" * 16, "ff" * 16),
]

# Sanity-check the reference itself against the published FIPS-197 ciphertexts
assert enc(*fixed[0]) == "3925841d02dc09fbdc118597196a0b32"
assert enc(*fixed[1]) == "69c4e0d86a7b0430d8cdb78070b4c55a"

pairs = fixed + [(random.randbytes(16).hex(), random.randbytes(16).hex())
                 for _ in range(NUM_RANDOM)]

with open("aes_vectors.hex", "w") as f:
    for k, p in pairs:
        f.write(f"{k}\n{p}\n{enc(k, p)}\n")

print(f"wrote {len(pairs)} vectors")
