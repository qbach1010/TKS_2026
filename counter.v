module counter # (parameter MAX_VAL = 59, MIN_VAL = 0, INIT_VAL = 0)(
    input en, mode, clk, rst_n,
    output reg [$clog2(MAX_VAL - MIN_VAL + 1) - 1 : 0] count_val = INIT_VAL,
    output critical
);

    reg [$clog2(MAX_VAL - MIN_VAL + 1) - 1 : 0] count_next;

    assign critical = mode ? (count_val == MIN_VAL) : (count_val == MAX_VAL);
    
    always @ (mode, critical)
        case ({mode, critical})
            2'b00: count_next = count_val + 1;
            2'b01: count_next = MIN_VAL;
            2'b10: count_next = count_val - 1;
            2'b11: count_next = MAX_VAL;
            default: count_next = 0;
        endcase
    
    always @ (posedge clk)
        if (!rst_n) count_val <= INIT_VAL;
        else count_val <= en ? count_next : count_val;

endmodule