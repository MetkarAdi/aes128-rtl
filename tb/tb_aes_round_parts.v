`timescale 1ns/1ps
module tb_aes_round_parts;
    reg  [127:0] sr_in, mc_in;
    wire [127:0] sr_out, mc_out;
    integer errors = 0;

    aes_shiftrows   u_sr (.state_in(sr_in), .state_out(sr_out));
    aes_mixcolumns  u_mc (.state_in(mc_in), .state_out(mc_out));

    task check_sr(input [127:0] i, input [127:0] exp);
        begin
            sr_in = i; #1;
            if (sr_out !== exp) begin
                errors = errors + 1;
                $display("ShiftRows MISMATCH: in %h got %h expected %h", i, sr_out, exp);
            end
        end
    endtask

    task check_mc(input [127:0] i, input [127:0] exp);
        begin
            mc_in = i; #1;
            if (mc_out !== exp) begin
                errors = errors + 1;
                $display("MixColumns MISMATCH: in %h got %h expected %h", i, mc_out, exp);
            end
        end
    endtask

    initial begin
        // FIPS-197 Appendix B, round 1
        check_sr(128'hd42711aee0bf98f1b8b45de51e415230,    // after SubBytes
                 128'hd4bf5d30e0b452aeb84111f11e2798e5);   // after ShiftRows
        check_mc(128'hd4bf5d30e0b452aeb84111f11e2798e5,    // after ShiftRows
                 128'h046681e5e0cb199a48f8d37a2806264c);   // after MixColumns

        // Published single-column MixColumns examples (column repeated 4 times)
        check_mc({4{32'hdb135345}}, {4{32'h8e4da1bc}});
        check_mc({4{32'hf20a225c}}, {4{32'h9fdc589d}});
        check_mc({4{32'h01010101}}, {4{32'h01010101}});
        check_mc({4{32'hc6c6c6c6}}, {4{32'hc6c6c6c6}});
        check_mc({4{32'hd4d4d4d5}}, {4{32'hd5d5d7d6}});
        check_mc({4{32'h2d26314c}}, {4{32'h4d7ebdf8}});

        $display("ShiftRows/MixColumns: %0d errors", errors);
        if (errors == 0) $display("RESULT: PASS");
        else             $display("RESULT: FAIL");
        $finish;
    end
endmodule
