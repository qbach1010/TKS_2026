module day_counter (
	input clk,
	input rst,
	input en, 
	input mode,
	input [1:0] days_in_month,
	output reg [4:0] out_value, 
	output max
);
	reg [4:0] next_value;
	assign max = (out_value[4:2] == 3'b111 & out_value[1:0] == days_in_month);
	assign min = (out_value == 5'd1);
	assign crit = (mode == 1'b0) ? max : min;
	
	always @(posedge clk) begin
		if(!rst) begin
			out_value <= 5'd1;
		end
		else begin
			if(en) begin				
				out_value <= next_value;
			end
			else begin
				out_value <= out_value;
			end
		end
	end
	
	always @(out_value, mode, max) begin
		if (mode == 1'b0) begin 
			if (crit) 
				next_value = 5'd1;
         	else 
				next_value = out_value + 1'b1;
      	end else begin          
			if (crit) 
				next_value = {3'b111, days_in_month};
         	else 
            	next_value = out_value - 1'b1;
      	end
	end
	
endmodule
