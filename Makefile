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
	verilator --lint-only -Wall --top-module aes_key_step rtl/aes_sbox.v rtl/aes_key_step.v
	verilator --lint-only -Wall --top-module aes128_iter rtl/aes_sbox.v rtl/aes_subbytes.v rtl/aes_shiftrows.v rtl/aes_mixcolumns.v rtl/aes_round.v rtl/aes_key_step.v rtl/aes128_iter.v	

clean:
	rm -f *.vvp *.vcd sbox.hex

sim_round: rtl/aes_shiftrows.v rtl/aes_mixcolumns.v tb/tb_aes_round_parts.v
	iverilog -g2012 -o round.vvp rtl/aes_shiftrows.v rtl/aes_mixcolumns.v tb/tb_aes_round_parts.v
	vvp round.vvp

sim_aesround: sbox tb/tb_aes_round.v
	iverilog -g2012 -o aesround.vvp rtl/aes_sbox.v rtl/aes_subbytes.v rtl/aes_shiftrows.v rtl/aes_mixcolumns.v rtl/aes_round.v tb/tb_aes_round.v
	vvp aesround.vvp

sim_keyexp: sbox tb/tb_aes_keyexp.v
	iverilog -g2012 -o keyexp.vvp rtl/aes_sbox.v rtl/aes_key_step.v tb/tb_aes_keyexp.v
	vvp keyexp.vvp

aes_vectors.hex: scripts/gen_aes_vectors.py
	python3 scripts/gen_aes_vectors.py

sim_top: sbox aes_vectors.hex tb/tb_aes128_iter.v
	iverilog -g2012 -o top.vvp rtl/aes_sbox.v rtl/aes_subbytes.v rtl/aes_shiftrows.v rtl/aes_mixcolumns.v rtl/aes_round.v rtl/aes_key_step.v rtl/aes128_iter.v tb/tb_aes128_iter.v
	vvp top.vvp

synth:
	yosys -p "read_verilog rtl/aes_sbox.v rtl/aes_subbytes.v rtl/aes_shiftrows.v rtl/aes_mixcolumns.v rtl/aes_round.v rtl/aes_key_step.v rtl/aes128_iter.v; synth -top aes128_iter -flatten; stat"
