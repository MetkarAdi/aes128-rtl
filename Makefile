RTL = rtl/aes_sbox.v

sbox: scripts/gen_sbox.py
	python3 scripts/gen_sbox.py

sim_sbox: sbox tb/tb_aes_sbox.v
	iverilog -g2012 -o sbox.vvp rtl/aes_sbox.v tb/tb_aes_sbox.v
	vvp sbox.vvp

lint:
	verilator --lint-only -Wall --top-module aes_sbox rtl/aes_sbox.v

clean:
	rm -f *.vvp *.vcd sbox.hex