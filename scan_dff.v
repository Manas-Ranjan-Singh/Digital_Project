Mux-D scan flip-flop: SE=0 -> functional D, SE=1 -> scan input SI
module scan_dff (
    input  clk, rst_n,
    input  d,      // functional data
    input  si,     // scan data in
    input  se,     // scan enable
    output reg q
);
    wire din = se ? si : d;
    always @(posedge clk or negedge rst_n)
        if (!rst_n) q <= 1'b0;
        else        q <= din;
endmodule
 
// Circuit under test: 4-bit up-counter with enable, all flops are scan flops
// chained scan_in -> q[0] -> q[1] -> q[2] -> q[3] -> scan_out
module scan_counter4 (
    input        clk, rst_n,
    input        en,
    input        scan_en,
    input        scan_in,
    output [3:0] count,
    output       scan_out
);
    wire [3:0] next = en ? (count + 4'd1) : count;
 
    scan_dff f0 (clk, rst_n, next[0], scan_in,  scan_en, count[0]);
    scan_dff f1 (clk, rst_n, next[1], count[0], scan_en, count[1]);
    scan_dff f2 (clk, rst_n, next[2], count[1], scan_en, count[2]);
    scan_dff f3 (clk, rst_n, next[3], count[2], scan_en, count[3]);
 
    assign scan_out = count[3];
endmodule
 
