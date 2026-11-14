`timescale 1ns/1ps
module tb_aes_sbox;
    reg  [7:0] a;
    wire [7:0] y;
    reg  [7:0] table_mem [0:255];
    integer i, errors;

    aes_sbox dut (.a(a), .y(y));

    task check(input [7:0] in, input [7:0] exp);
        begin
            a = in; #1;
            if (y !== exp) begin
                errors = errors + 1;
                $display("MISMATCH S[%h] = %h expected %h", in, y, exp);
            end
        end
    endtask

    initial begin
        $readmemh("sbox.hex", table_mem);
        errors = 0;

        // Six values from the FIPS-197 S-box table
        check(8'h00, 8'h63);
        check(8'h01, 8'h7c);
        check(8'h10, 8'hca);
        check(8'h53, 8'hed);
        check(8'hc9, 8'hdd);
        check(8'hff, 8'h16);

        // All 256 entries against the generated table
        for (i = 0; i < 256; i = i + 1)
            check(i[7:0], table_mem[i]);

        $display("S-box: %0d errors", errors);
        if (errors == 0) $display("RESULT: PASS");
        else             $display("RESULT: FAIL");
        $finish;
    end
endmodule
