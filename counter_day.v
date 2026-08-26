module counter_day (
    input en, mode, clk, rst_n,
    input[1:0] days_in_month,
    output reg [4:0] count_val = 5'b1,
    output critical
);
	 reg [4:0] max_day;
    reg [4:0] count_next;

    always @ (days_in_month)
        case (days_in_month)
            2'b00: max_day = 28;
            2'b01: max_day = 29;
            2'b10: max_day = 30;
            2'b11: max_day = 31;
            default: max_day = 30;
        endcase

    assign critical = mode ? (count_val == 1) : (count_val == max_day);
    
    always @ (mode, critical)
        case ({mode, critical})
            2'b00: count_next = count_val + 1;
            2'b01: count_next = 1;
            2'b10: count_next = count_val - 1;
            2'b11: count_next = max_day;
            default: count_next = 0;
        endcase
    
    always @ (posedge clk)
        if (!rst_n) count_val <= 1;
        else count_val <= en ? count_next : count_val;

endmodule