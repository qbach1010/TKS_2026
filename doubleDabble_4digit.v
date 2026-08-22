module doubleDabble_4digit(
   input  [13:0] unsign_in,
	output [3:0] dg_thousand,
	output [3:0] dg_hundred,	
   output [3:0] dg_ten,       
   output [3:0] dg_one        
);
    
   reg [29:0] temp;
   integer i;
    
	always @(*) begin

		temp = {16'b0, unsign_in};

		for (i = 0; i < 15; i = i + 1) begin
		
			if (temp[17:14] >= 5) begin
				temp[17:14] = temp[17:14] + 3;
			end
			
			if (temp[21:18] >= 5) begin
				temp[21:18] = temp[21:18] + 3;
			end
			
			if (temp[25:22] >= 5) begin
				temp[25:22] = temp[25:22] + 3;
			end

			if (temp[29:26] >= 5) begin
				temp[29:26] = temp[29:26] + 3;
			end

			temp = temp << 1;
		end
	end
 
	assign dg_thousand = temp[29:26];
	assign dg_hundred = temp[25:22];	
	assign dg_ten = temp[21:18]; 
	assign dg_one = temp[17:14];  

endmodule