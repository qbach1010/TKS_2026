module posedge_detector(
	input clk,
	input in,
	output out
);
	reg temp;
	
	assign out = ~temp & in; 
	
	always @(posedge clk) begin
		temp <= in;
	end
	
	
endmodule