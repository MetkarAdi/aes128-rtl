`timescale 1ns/1ps
module tb_aes_round;
    reg  [127:0] st, rk;
    reg          last;
    wire [127:0] sb_out, rnd_out;
    integer errors = 0;

    aes_subbytes u_sb  (.state_in(st), .state_out(sb_out));
    aes_round    u_rnd (.state_in(st), .round_key(rk), .last(last), .state_out(rnd_out));

    task check_sub(input [127:0] s, input [127:0] exp);
        begin
            st = s; rk = 0; last = 0; #1;
            if (sb_out !== exp) begin
                errors = errors + 1;
                $display("SubBytes MISMATCH: got %h expected %h", sb_out, exp);
            end
        end
    endtask

    task check_round(input [127:0] s, input [127:0] k, input l, input [127:0] exp);
        begin
            st = s; rk = k; last = l; #1;
            if (rnd_out !== exp) begin
                errors = errors + 1;
                $display("Round MISMATCH: in %h got %h expected %h", s, rnd_out, exp);
            end
        end
    endtask

    initial begin
        check_sub(128'h193de3bea0f4e22b9ac68d2ae9f84808,
                  128'hd42711aee0bf98f1b8b45de51e415230);

        // Round 1
        check_round(128'h193de3bea0f4e22b9ac68d2ae9f84808,
                    128'ha0fafe1788542cb123a339392a6c7605, 1'b0,
                    128'ha49c7ff2689f352b6b5bea43026a5049);
        // Round 2
        check_round(128'ha49c7ff2689f352b6b5bea43026a5049,
                    128'hf2c295f27a96b9435935807a7359f67f, 1'b0,
                    128'haa8f5f0361dde3ef82d24ad26832469a);
        // Round 3
        check_round(128'haa8f5f0361dde3ef82d24ad26832469a,
                    128'h3d80477d4716fe3e1e237e446d7a883b, 1'b0,
                    128'h486c4eee671d9d0d4de3b138d65f58e7);
        // Final round (round 10): no MixColumns, produces the ciphertext
        check_round(128'heb40f21e592e38848ba113e71bc342d2,
                    128'hd014f9a8c9ee2589e13f0cc8b6630ca6, 1'b1,
                    128'h3925841d02dc09fbdc118597196a0b32);

        $display("SubBytes + rounds: %0d errors", errors);
        if (errors == 0) $display("RESULT: PASS");
        else             $display("RESULT: FAIL");
        $finish;
    end
endmodule
