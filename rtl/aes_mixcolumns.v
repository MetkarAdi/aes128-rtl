module aes_mixcolumns (
    input  [127:0] state_in,
    output [127:0] state_out
);
    function [7:0] xtime(input [7:0] a);
        xtime = {a[6:0], 1'b0} ^ (a[7] ? 8'h1b : 8'h00);
    endfunction

    function [7:0] x3(input [7:0] a);
        x3 = xtime(a) ^ a;
    endfunction

    genvar c;
    generate
        for (c = 0; c < 4; c = c + 1) begin : g_col
            wire [7:0] s0 = state_in[127 - 32*c -: 8];
            wire [7:0] s1 = state_in[119 - 32*c -: 8];
            wire [7:0] s2 = state_in[111 - 32*c -: 8];
            wire [7:0] s3 = state_in[103 - 32*c -: 8];

            assign state_out[127 - 32*c -: 8] = xtime(s0) ^ x3(s1)    ^ s2        ^ s3;
            assign state_out[119 - 32*c -: 8] = s0        ^ xtime(s1) ^ x3(s2)    ^ s3;
            assign state_out[111 - 32*c -: 8] = s0        ^ s1        ^ xtime(s2) ^ x3(s3);
            assign state_out[103 - 32*c -: 8] = x3(s0)    ^ s1        ^ s2        ^ xtime(s3);
        end
    endgenerate
endmodule
