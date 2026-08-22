module Days_In_Month (
	input [7:0] year_BCD,
	input [3:0] year_value,
	input [3:0] month_value,
	output [1:0] days_in_month
);
	reg full, not_feb;
	
	wire leap = ((|year_BCD) | (~|year_value[3:2])) & (~|year_value[1:0]);
	
	assign days_in_month[0] = not_feb ? full : leap;
	assign days_in_month[1] = not_feb;
	
	always @(month_value) begin
		full = 0;
		not_feb = 1;
		case(month_value) 
			4'd1: full = 1;
			4'd2: not_feb = 0;
			4'd3: full = 1;
			4'd4: full = 0;
			4'd5: full = 1;
			4'd6: full = 0;
			4'd7: full = 1;
			4'd8: full = 1;
			4'd9: full = 0;
			4'd10: full = 1;
			4'd11: full = 0;
			4'd12: full = 1;
		endcase
	end

endmodule
