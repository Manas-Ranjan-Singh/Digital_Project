`timescale 1ns/1ps
module tb_scan_chain;
    reg clk = 0, rst_n = 0, en = 0, scan_en = 0, scan_in = 0;
    wire [3:0] count;
    wire scan_out;
    integer errors = 0, i;
    reg [3:0] captured;
 
    scan_counter4 dut (clk, rst_n, en, scan_en, scan_in, count, scan_out);
    always #5 clk = ~clk;
 
    // shift a 4-bit pattern in (MSB first so bit0 ends in flop0... see note)
    task scan_load(input [3:0] pat);
        integer k;
        begin
            scan_en = 1;
            for (k = 3; k >= 0; k = k - 1) begin
                scan_in = pat[k];
                @(posedge clk); #1;
            end
            scan_en = 0;
        end
    endtask
 
    // shift out current state while shifting zeros in
    task scan_unload(output [3:0] data);
        integer k;
        begin
            scan_en = 1; scan_in = 0;
            for (k = 0; k < 4; k = k + 1) begin
                data[3-k] = scan_out;     // first bit out is flop3 (MSB)
                @(posedge clk); #1;
            end
            scan_en = 0;
        end
    endtask
 
    task check(input [3:0] got, input [3:0] exp, input [255:0] name);
        begin
            if (got !== exp) begin
                $display("FAIL  %0s: got %b expected %b", name, got, exp);
                errors = errors + 1;
            end else
                $display("PASS  %0s: %b", name, got);
        end
    endtask
 
    initial begin
        $dumpfile("scan_chain.vcd"); $dumpvars(0, tb_scan_chain);
        #12 rst_n = 1;
 
        // 1) Functional mode: count 3 cycles
        en = 1;
        repeat (3) @(posedge clk);
        #1; check(count, 4'd3, "functional count");
        en = 0;
 
        // 2) Scan shift mode: load pattern, state must equal pattern
        scan_load(4'b1010);
        check(count, 4'b1010, "scan load 1010");
 
        // 3) Capture: one functional clock with en=1 -> 1010 + 1 = 1011
        en = 1; @(posedge clk); #1; en = 0;
        check(count, 4'b1011, "capture cycle");
 
        // 4) Shift out captured response
        scan_unload(captured);
        check(captured, 4'b1011, "scan unload response");
 
        // 5) Second pattern
        scan_load(4'b0111);
        en = 1; @(posedge clk); #1; en = 0;
        scan_unload(captured);
        check(captured, 4'b1000, "pattern 0111 -> 1000");
 
        $display("\nTotal errors = %0d  --> %s", errors, errors ? "FAILED" : "ALL TESTS PASSED");
        $finish;
    end
endmodule
