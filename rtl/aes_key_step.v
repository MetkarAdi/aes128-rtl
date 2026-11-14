module aes_key_step (
    input  [127:0] key_in,     // round key i  = {w0, w1, w2, w3}
    input  [7:0]   rcon,       // round constant for this step
    output [127:0] key_out     // round key i+1
);
    wire [31:0] w0 = key_in[127:96];
    wire [31:0] w1 = key_in[95:64];
    wire [31:0] w2 = key_in[63:32];
    wire [31:0] w3 = key_in[31:0];

    wire [31:0] rot = {w3[23:0], w3[31:24]};     // RotWord
    wire [31:0] sub;                             // SubWord

    aes_sbox u_s0 (.a(rot[31:24]), .y(sub[31:24]));
    aes_sbox u_s1 (.a(rot[23:16]), .y(sub[23:16]));
    aes_sbox u_s2 (.a(rot[15:8]),  .y(sub[15:8]));
    aes_sbox u_s3 (.a(rot[7:0]),   .y(sub[7:0]));

    wire [31:0] t  = sub ^ {rcon, 24'h000000};
    wire [31:0] n0 = w0 ^ t;
    wire [31:0] n1 = w1 ^ n0;
    wire [31:0] n2 = w2 ^ n1;
    wire [31:0] n3 = w3 ^ n2;

    assign key_out = {n0, n1, n2, n3};
endmodule
