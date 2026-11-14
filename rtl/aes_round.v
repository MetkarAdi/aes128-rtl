module aes_round (
    input  [127:0] state_in,
    input  [127:0] round_key,
    input          last,         // 1 = final round (no MixColumns)
    output [127:0] state_out
);
    wire [127:0] after_sub, after_shift, after_mix;

    aes_subbytes   u_sub   (.state_in(state_in),    .state_out(after_sub));
    aes_shiftrows  u_shift (.state_in(after_sub),   .state_out(after_shift));
    aes_mixcolumns u_mix   (.state_in(after_shift), .state_out(after_mix));

    // AddRoundKey is the XOR at the end
    assign state_out = (last ? after_shift : after_mix) ^ round_key;
endmodule
