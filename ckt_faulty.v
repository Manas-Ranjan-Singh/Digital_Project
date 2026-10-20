module ckt_faulty (
    input  a, b, c, d,
    input        fault_en,    // 0 = fault-free
    input  [2:0] fault_node,  // which node is faulty
    input        fault_val,   // 0 = stuck-at-0, 1 = stuck-at-1
    output y
);
    // fault injection: force node value when it is the selected faulty node
    wire a_f  = (fault_en && fault_node==0) ? fault_val : a;
    wire b_f  = (fault_en && fault_node==1) ? fault_val : b;
    wire c_f  = (fault_en && fault_node==2) ? fault_val : c;
    wire d_f  = (fault_en && fault_node==3) ? fault_val : d;
    wire n1   = (fault_en && fault_node==4) ? fault_val : (a_f & b_f);
    wire n2   = (fault_en && fault_node==5) ? fault_val : (c_f ^ d_f);
    assign y  = (fault_en && fault_node==6) ? fault_val : (n1 | n2);
endmodule
