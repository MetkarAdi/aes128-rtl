`timescale 1ns/1ps
module tb_aes128_iter;
    parameter NUM_VEC = 504;      // 4 fixed + 500 random, see gen_aes_vectors.py

    reg          clk = 0, rst_n = 0;
    reg          in_valid = 0;
    reg  [127:0] key = 0, plaintext = 0;
    wire         in_ready, out_valid;
    wire [127:0] ciphertext;

    aes128_iter dut (.clk(clk), .rst_n(rst_n), .in_valid(in_valid), .in_ready(in_ready),
                     .key(key), .plaintext(plaintext),
                     .out_valid(out_valid), .ciphertext(ciphertext));

    always #5 clk = ~clk;

    reg [127:0] vec [0:3*NUM_VEC-1];
    integer cyc = 0;
    always @(posedge clk) cyc <= cyc + 1;

    integer i, errors, latency, bad_latency;
    integer first_accept, last_accept;
    reg [127:0] got;

    // Encrypt one block. Measures clock edges from the accept edge to out_valid.
    // junk = 1 drives in_valid with garbage while busy, which must be ignored.
    task encrypt(input [127:0] k, input [127:0] p, input junk);
        reg seen;
        begin
            @(negedge clk);
            key = k; plaintext = p; in_valid = 1;
            @(posedge clk);                 // accept edge
            if (i == 0)          first_accept = cyc;
            if (i == NUM_VEC-1)  last_accept  = cyc;
            #1 in_valid = 0;
            latency = 0; seen = 0;
            while (!seen) begin
                @(posedge clk);
                latency = latency + 1;
                #1;
                if (out_valid) seen = 1;
                else if (junk) begin
                    in_valid = 1;
                    key = {$urandom, $urandom, $urandom, $urandom};
                    plaintext = {$urandom, $urandom, $urandom, $urandom};
                end
            end
            in_valid = 0;
            got = ciphertext;
        end
    endtask

    initial begin
        $readmemh("aes_vectors.hex", vec);
        errors = 0; bad_latency = 0;
        #22 rst_n = 1;

        for (i = 0; i < NUM_VEC; i = i + 1) begin
            encrypt(vec[3*i], vec[3*i+1], i % 2);
            if (got !== vec[3*i+2]) begin
                errors = errors + 1;
                $display("MISMATCH vec %0d: got %h expected %h", i, got, vec[3*i+2]);
            end
            if (latency != 10) bad_latency = bad_latency + 1;
        end

        $display("blocks checked          : %0d", NUM_VEC);
        $display("errors                  : %0d", errors);
        $display("latency (accept->valid) : %0d cycles (blocks with other latency: %0d)",
                 latency, bad_latency);
        $display("back-to-back throughput : %0d cycles per block",
                 (last_accept - first_accept) / (NUM_VEC - 1));
        if (errors == 0 && bad_latency == 0) $display("RESULT: PASS");
        else                                 $display("RESULT: FAIL");
        $finish;
    end

    initial begin
        #100000000;
        $display("RESULT: TIMEOUT");
        $finish;
    end
endmodule
