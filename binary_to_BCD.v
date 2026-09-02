module binary_to_BCD4 (
   input  [13:0] year_value,
	output [15:0] year_BCD
);
    
   reg [29:0] temp;
   integer i;
    
	always @ (year_value) begin
        temp = {13'b0, year_value, 3'b0};

		for (i = 4; i < 15; i = i + 1) begin

            if (temp[17:14] >= 5) temp[17:14] = temp[17:14] + 3; // ones
            if (temp[21:18] >= 5) temp[21:18] = temp[21:18] + 3; // tens
            if (temp[25:22] >= 5) temp[25:22] = temp[25:22] + 3; // hundreds
            if (temp[29:26] >= 5) temp[29:26] = temp[29:26] + 3; // thousands
            
            temp = temp << 1;
		end
	end
 
	assign year_BCD = temp[29:14];

endmodule

module binary_to_BCD2 # (parameter N = 6) (
   input  [N-1:0] in,
	output [7:0] BCD
);
    
   reg [N+7:0] temp;
   integer i;
    
	always @ (in) begin
        temp = {5'b0, in, 3'b0};
        
		for (i = 4; i < N+1; i = i + 1) begin

            if (temp[N+3:N] >= 5) temp[N+3:N] = temp[N+3:N] + 3; // ones
            if (temp[N+7:N+4] >= 5) temp[N+7:N+4] = temp[N+7:N+4] + 3; // tens
            
            temp = temp << 1;
		end
	end
 
	assign BCD = temp[N+7:N];

endmodule

module binary_to_BCD (
    input [13:0] year_val,
    input [3:0] month_val,
    input [4:0] day_val,
    input [4:0] hour_val,
    input [5:0] minute_val,
    input [5:0] second_val,
	 input mode,
    output [15:0] year_BCD,
    output [7:0] month_BCD, day_BCD, hour_BCD, minute_BCD, second_BCD,
	 output[1:0] days_in_month
);

    binary_to_BCD4 year_convert (.year_value(year_val), .year_BCD(year_BCD));
    binary_to_BCD2 #(4) month_convert (.in(month_val), .BCD(month_BCD));
    binary_to_BCD2 #(5) day_convert (.in(day_val), .BCD(day_BCD));
    binary_to_BCD2 #(5) hour_convert (.in(hour_val), .BCD(hour_BCD));
    binary_to_BCD2 #(6) minute_convert (.in(minute_val), .BCD(minute_BCD));
    binary_to_BCD2 #(6) second_convert (.in(second_val), .BCD(second_BCD));
	 
	 find_days_in_month find (
      .year_BCD(year_BCD), .year_value_last_4(year_val[3:0]),
      .month_value(month_val), .mode(mode), .days_in_month(days_in_month));
endmodule