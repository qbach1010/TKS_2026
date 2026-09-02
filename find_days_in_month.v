module find_days_in_month (
    input [7:0] year_BCD,
    input [3:0] year_value_last_4,
    input [3:0] month_value,
    input [4:0] day_value,
    input [1:0] set,
    output reg[1:0] days_in_month
);

    reg leap, full, notFeb;
    reg [3:0] month_value_check;

    always @ (*) begin
		leap = (~(|year_value_last_4[1:0])) & ((|year_BCD) | ~(|year_value_last_4[3:2]));
        // only check for the previous month when count day to 1 and set = 01 (count down)
        month_value_check = ((set == 2'b01) && (day_value == 5'b00001)) ? ((month_value==1) ? 4'b1100 : month_value - 1) : month_value;
        case (month_value_check)
            4'b0001: full = 1;
            4'b0010: full = 0;
            4'b0011: full = 1;
            4'b0100: full = 0;
            4'b0101: full = 1;
            4'b0110: full = 0;
            4'b0111: full = 1;
            4'b1000: full = 1;
            4'b1001: full = 0;
            4'b1010: full = 1;
            4'b1011: full = 0;
            4'b1100: full = 1;
            default: full = 0;
        endcase
        notFeb = |month_value_check[3:2] | ~month_value_check[1] | month_value_check[0];
		days_in_month = {notFeb, (notFeb ? full : leap)};
    end

endmodule
