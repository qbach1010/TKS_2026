module debouncer #(
    parameter CLK_FREQ = 50_000_000,    // Clock frequency in Hz
    parameter DEBOUNCE_TIME_MS = 20     // Debounce time in milliseconds
)(
    input wire clk,           // System clock
    input wire rst_n,         // Active low reset
    input wire button_in,     // Raw button input (noisy, active low)
    output button_out1     // Debounced button output (active low)
);
	
    localparam COUNTER_MAX = (CLK_FREQ / 1000) * DEBOUNCE_TIME_MS;
    localparam COUNTER_WIDTH = $clog2(COUNTER_MAX + 1);
	 reg button_out;
    reg [COUNTER_WIDTH-1:0] counter;
    reg button_sync_0, button_sync_1;
	 assign button_out1 = ~button_out;

    always @(posedge clk) begin
        if (!rst_n) begin                   // FIX: Evaluate reset as active low
            button_sync_0 <= 1'b1;          // FIX: Active low buttons idle at 1
            button_sync_1 <= 1'b1;
        end else begin
            button_sync_0 <= button_in;
            button_sync_1 <= button_sync_0;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin                   // FIX: Evaluate reset as active low
            counter <= 0;
            button_out <= 1'b1;             // FIX: Debounced output idles at 1
        end else begin
            if (button_sync_1 != button_out) begin
                // Input differs from output, start/continue counting
                counter <= counter + 1;
                if (counter >= COUNTER_MAX) begin
                    button_out <= button_sync_1;
                    counter <= 0;
                end
            end else begin
                // Input matches output, reset counter
                counter <= 0;
            end
        end
    end

endmodule