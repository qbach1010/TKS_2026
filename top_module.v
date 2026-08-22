module top_module(
	input clk,
	input in,
	output [5:0] out
);
	wire w1,w2,w3;
	debouncer db1(
    .clk(clk),           // System clock
    .rst_n(1'b1),         // Active low reset
    .button_in(in),     // Raw button input (noisy, active low)
    .button_out1(w1)     // Debounced button output (active low)
    );
	hold_detector hd1(
	.clk(clk),
	.rst(1'b1),
	.in(w1),
	.out(w2)
	);
	posedge_detector pd1(
	.clk(clk),
	.in(w1),
	.out(w3)
	);
	counter ct1 (
	.clk(clk),
	.rst(1'b1),
	.en(w2|w3), 
	.mode(1'b1),
	.out_value(out), 
	.max()
);



endmodule