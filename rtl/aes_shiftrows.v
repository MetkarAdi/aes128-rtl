module aes_shiftrows (
    input  [127:0] state_in,
    output [127:0] state_out
);
    genvar r, c;
    generate
        for (c = 0; c < 4; c = c + 1) begin : g_col
            for (r = 0; r < 4; r = r + 1) begin : g_row
                assign state_out[127 - 8*(r + 4*c) -: 8] =
                       state_in [127 - 8*(r + 4*((c + r) % 4)) -: 8];
            end
        end
    endgenerate
endmodule
