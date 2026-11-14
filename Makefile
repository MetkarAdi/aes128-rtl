RTL = rtl/aes_sbox.v

sbox: scripts/gen_sbox.py
	python3 scripts/gen_sbox.py

sim_sbox: sbox tb/tb_aes_sbox.v
	iverilog -g2012 -o sbox.vvp rtl/aes_sbox.v tb/tb_aes_sbox.v
	vvp sbox.vvp

lint:
	verilator --lint-only -Wall --top-module aes_sbox rtl/aes_sbox.v
	verilator --lint-only -Wall --top-module aes_shiftrows rtl/aes_shiftrows.v
	verilator --lint-only -Wall --top-module aes_mixcolumns rtl/aes_mixcolumns.v
		verilator --lint-only -Wall --top-module aes_round rtl/aes_sbox.v rtl/aes_subbytes.v rtl/aes_shiftrows.v rtl/aes_mixcolumns.v rtl/aes_round.v

clean:
	rm -f *.vvp *.vcd sbox.hex

sim_round: rtl/aes_shiftrows.v rtl/aes_mixcolumns.v tb/tb_aes_round_parts.v
	iverilog -g2012 -o round.vvp rtl/aes_shiftrows.v rtl/aes_mixcolumns.v tb/tb_aes_round_parts.v
	vvp round.vvp

sim_aesround: sbox tb/tb_aes_round.v
	iverilog -g2012 -o aesround.vvp rtl/aes_sbox.v rtl/aes_subbytes.v rtl/aes_shiftrows.v rtl/aes_mixcolumns.v rtl/aes_round.v tb/tb_aes_round.v
	vvp aesround.vvp