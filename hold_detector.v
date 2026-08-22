module hold_detector #(parameter MAX_HOLD = 50000000, MAX_REPEAT = 25000000) (
	input clk,
	input rst,
	input in,
	output out
);
	reg [$clog2(MAX_HOLD)-1 : 0] next_value;
	reg [$clog2(MAX_HOLD)-1 : 0] out_value;
	
	assign out = (out_value == MAX_HOLD - 1); 
	
	always @(posedge clk) begin
		if(!rst) begin
			out_value <= 0;
		end
		else begin		
			out_value <= next_value;
		end
	end
	
	always @(out_value, in, out) begin
		case({in, out})
			2'b10: next_value = out_value + 1'b1; 
			2'b11: next_value = out_value - MAX_REPEAT;
			default: next_value = 0;
		endcase
	end
endmodule
