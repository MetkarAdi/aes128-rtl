module aes_subbytes (
    input  [127:0] state_in,
    output [127:0] state_out
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_sb
            aes_sbox u_sbox (
                .a(state_in [127 - 8*i -: 8]),
                .y(state_out[127 - 8*i -: 8])
            );
        end
    endgenerate
endmodule
