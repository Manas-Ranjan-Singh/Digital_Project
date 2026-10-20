`timescale 1ns/1ps
module tb_stuck_at;
    reg a, b, c, d;
    reg [2:0] fnode;
    reg fval;
    wire y_good, y_bad;
    integer node, v, p, detected_faults = 0, total_faults = 0;
    reg found;
    reg [3:0] first_pat;
    reg [8*3-1:0] nname;
 
    ckt_faulty golden (a,b,c,d, 1'b0, 3'd0, 1'b0, y_good);
    ckt_faulty faulty (a,b,c,d, 1'b1, fnode, fval, y_bad);
 
    function [8*3-1:0] name_of(input [2:0] n);
        case (n)
            0: name_of="a"; 1: name_of="b"; 2: name_of="c"; 3: name_of="d";
            4: name_of="n1"; 5: name_of="n2"; default: name_of="y";
        endcase
    endfunction
 
    initial begin
        $display("Fault      | Detected | First detecting pattern (abcd)");
        $display("-----------+----------+-------------------------------");
        for (node = 0; node < 7; node = node + 1)
            for (v = 0; v < 2; v = v + 1) begin
                fnode = node; fval = v; found = 0; first_pat = 0;
                total_faults = total_faults + 1;
                for (p = 0; p < 16; p = p + 1) begin
                    {a,b,c,d} = p; #1;
                    if (!found && (y_good !== y_bad)) begin
                        found = 1; first_pat = p[3:0];
                    end
                end
                if (found) detected_faults = detected_faults + 1;
                if (found) $display("%0s SA%0d      | YES      | %b", name_of(node), v, first_pat);
                else       $display("%0s SA%0d      | NO       | (undetectable)", name_of(node), v);
            end
        $display("-----------+----------+-------------------------------");
        $display("Fault coverage = %0d / %0d = %0d%%", detected_faults, total_faults,
                 (detected_faults*100)/total_faults);
        $finish;
    end
endmodule
