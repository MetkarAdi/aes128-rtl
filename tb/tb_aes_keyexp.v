`timescale 1ns/1ps
module tb_aes_keyexp;
    reg  [127:0] key_in;
    reg  [7:0]   rcon;
    wire [127:0] key_out;
    reg  [127:0] exp1 [0:10];
    reg  [7:0]   rcon_tab [0:9];
    reg  [127:0] k;
    integer      i, errors;

    aes_key_step dut (.key_in(key_in), .rcon(rcon), .key_out(key_out));

    task chk(input [127:0] got, input [127:0] exp, input integer tag);
        begin
            if (got !== exp) begin
                errors = errors + 1;
                $display("MISMATCH %0d: got %h expected %h", tag, got, exp);
            end
        end
    endtask

    initial begin
        errors = 0;
        rcon_tab[0] = 8'h01; rcon_tab[1] = 8'h02; rcon_tab[2] = 8'h04;
        rcon_tab[3] = 8'h08; rcon_tab[4] = 8'h10; rcon_tab[5] = 8'h20;
        rcon_tab[6] = 8'h40; rcon_tab[7] = 8'h80; rcon_tab[8] = 8'h1b;
        rcon_tab[9] = 8'h36;

        // Key 1: FIPS-197 Appendix A (all 11 round keys)
        exp1[0]  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        exp1[1]  = 128'ha0fafe1788542cb123a339392a6c7605;
        exp1[2]  = 128'hf2c295f27a96b9435935807a7359f67f;
        exp1[3]  = 128'h3d80477d4716fe3e1e237e446d7a883b;
        exp1[4]  = 128'hef44a541a8525b7fb671253bdb0bad00;
        exp1[5]  = 128'hd4d1c6f87c839d87caf2b8bc11f915bc;
        exp1[6]  = 128'h6d88a37a110b3efddbf98641ca0093fd;
        exp1[7]  = 128'h4e54f70e5f5fc9f384a64fb24ea6dc4f;
        exp1[8]  = 128'head27321b58dbad2312bf5607f8d292f;
        exp1[9]  = 128'hac7766f319fadc2128d12941575c006e;
        exp1[10] = 128'hd014f9a8c9ee2589e13f0cc8b6630ca6;

        k = exp1[0];
        for (i = 0; i < 10; i = i + 1) begin
            key_in = k; rcon = rcon_tab[i]; #1;
            k = key_out;
            chk(k, exp1[i+1], i+1);
        end

        // Key 2: FIPS-197 Appendix C.1 (round keys 1, 2, 9, 10)
        k = 128'h000102030405060708090a0b0c0d0e0f;
        for (i = 0; i < 10; i = i + 1) begin
            key_in = k; rcon = rcon_tab[i]; #1;
            k = key_out;
            case (i + 1)
                1:  chk(k, 128'hd6aa74fdd2af72fadaa678f1d6ab76fe, 101);
                2:  chk(k, 128'hb692cf0b643dbdf1be9bc5006830b3fe, 102);
                9:  chk(k, 128'h549932d1f08557681093ed9cbe2c974e, 109);
                10: chk(k, 128'h13111d7fe3944a17f307a78b4d2b30c5, 110);
                default: ;
            endcase
        end

        $display("Key expansion: %0d errors", errors);
        if (errors == 0) $display("RESULT: PASS");
        else             $display("RESULT: FAIL");
        $finish;
    end
endmodule
