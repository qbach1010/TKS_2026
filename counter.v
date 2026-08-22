module counter #(parameter MAX_VALUE = 60) (
	input clk,
	input rst,
	input en, 
	input mode,
	output reg [$clog2(MAX_VALUE)-1 : 0] out_value, 
	output max
);
	reg [$clog2(MAX_VALUE)-1 : 0] next_value;

	assign max = (mode == 1'b0) ? (out_value == MAX_VALUE - 1) : (out_value == 0);
	
	always @(posedge clk) begin
		if(!rst) begin
			//reset
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
		if (mode == 1'b0) begin 
			if (max) 
				next_value = 0;
         else 
				next_value = out_value + 1'b1;
      end else begin          
         if (max) 
            next_value = MAX_VALUE - 1;
         else 
            next_value = out_value - 1'b1;
      end
	end
	
		
		
	
endmodule