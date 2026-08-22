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
	
	always @(posedge clk) begin
		if(!rst) begin
			out_value <= 0;
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
		case({mode, max})
			2'b00: next_value = out_value + 1'b1; 
			2'b10: next_value = out_value - 1'b1;
			default: next_value = 0;
		endcase
	end
	
endmodule
