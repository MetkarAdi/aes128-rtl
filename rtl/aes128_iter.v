module aes128_iter (
    input          clk,
    input          rst_n,
    // input side: a block is accepted on a clock edge where in_valid && in_ready
    input          in_valid,
    output         in_ready,
    input  [127:0] key,
    input  [127:0] plaintext,
    // output side: out_valid pulses for one cycle when ciphertext is ready;
    // ciphertext then stays stable until the next block is accepted
    output reg     out_valid,
    output [127:0] ciphertext
);
    reg [127:0] state;      // current AES state
    reg [127:0] rkey;       // current round key
    reg [3:0]   round;      // round being computed (1 to 10)
    reg         busy;

    reg [7:0] rcon;
    always @(*) begin
        case (round)
            4'd1:    rcon = 8'h01;
            4'd2:    rcon = 8'h02;
            4'd3:    rcon = 8'h04;
            4'd4:    rcon = 8'h08;
            4'd5:    rcon = 8'h10;
            4'd6:    rcon = 8'h20;
            4'd7:    rcon = 8'h40;
            4'd8:    rcon = 8'h80;
            4'd9:    rcon = 8'h1b;
            4'd10:   rcon = 8'h36;
            default: rcon = 8'h00;
        endcase
    end

    wire [127:0] next_key;
    wire [127:0] round_out;
    wire         last = (round == 4'd10);

    aes_key_step u_key (.key_in(rkey), .rcon(rcon), .key_out(next_key));
    aes_round    u_rnd (.state_in(state), .round_key(next_key),
                        .last(last), .state_out(round_out));

    assign in_ready   = ~busy;
    assign ciphertext = state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= 128'h0;
            rkey      <= 128'h0;
            round     <= 4'd0;
            busy      <= 1'b0;
            out_valid <= 1'b0;
        end else begin
            out_valid <= 1'b0;
            if (!busy) begin
                if (in_valid) begin
                    state <= plaintext ^ key;     // initial AddRoundKey
                    rkey  <= key;
                    round <= 4'd1;
                    busy  <= 1'b1;
                end
            end else begin
                state <= round_out;               // one full round per clock
                rkey  <= next_key;
                if (last) begin
                    busy      <= 1'b0;
                    out_valid <= 1'b1;
                end else begin
                    round <= round + 4'd1;
                end
            end
        end
    end
endmodule
