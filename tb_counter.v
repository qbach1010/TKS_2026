`timescale 1ns/1ps

module tb_counter();

    // Testbench Parameters
    parameter MAX_VAL = 5;
    parameter MIN_VAL = 0;
    parameter INIT_VAL = 0;

    reg clk;
    reg rst_n;
    reg en;
    reg mode;
    wire [$clog2(MAX_VAL - MIN_VAL + 1) - 1 : 0] count_val;
    wire critical;
    //expected_  contain original logic at counter.v
    reg [$clog2(MAX_VAL - MIN_VAL + 1) - 1 : 0] expected_count;
    reg [$clog2(MAX_VAL - MIN_VAL + 1) - 1 : 0] expected_next; 
    wire expected_critical;

    assign expected_critical = mode ? (expected_count == MIN_VAL) : (expected_count == MAX_VAL);

    // Instantiate the Device Under Test (DUT)
    counter #(
        .MAX_VAL(MAX_VAL),
        .MIN_VAL(MIN_VAL),
        .INIT_VAL(INIT_VAL)
    ) dut (
        .en(en),
        .mode(mode),
        .clk(clk),
        .rst_n(rst_n),
        .count_val(count_val),
        .critical(critical)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk; //10ns clk
    end

    
    initial begin
        // Setup waveform dumping for EDA tools (optional)
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_counter);

        // 1. Initialize Inputs
        rst_n = 0;
        en = 0;
        mode = 0;

        // 2. Release reset after a few clock cycles
        #15;
        rst_n = 1;

        // 3. Test Counting UP (mode = 0)
        $display("--- Starting Count UP Test ---");
        en = 1;
        mode = 0;
        // Wait long enough for it to reach MAX_VAL and wrap to MIN_VAL
        #140; 

        // 4. Test Enable/Pause (en = 0)
        $display("--- Testing Enable = 0 (Pause) ---");
        en = 0;
        #100; // Should hold its current value

        // 5. Test Counting DOWN (mode = 1)
        $display("--- Starting Count DOWN Test ---");
        en = 1;
        mode = 1;
        // Wait long enough for it to reach MIN_VAL and wrap to MAX_VAL
        #140;

        // 6. Test Synchronous Reset during active counting
        $display("--- Testing Synchronous Reset ---");
        rst_n = 0;
        #20;
        rst_n = 1;
        #40;

        // End Simulation
        $display("--- Simulation Complete ---");
        $finish;
    end
    // logic from counter.v
    always @ (*) begin
        case ({mode, expected_critical})
            2'b00: expected_next = expected_count + 1;
            2'b01: expected_next = MIN_VAL;
            2'b10: expected_next = expected_count - 1;
            2'b11: expected_next = MAX_VAL;
            default: expected_next = 0;
        endcase
    end

    always @ (posedge clk) begin
        if (!rst_n) expected_count <= INIT_VAL;
        else expected_count <= en ? expected_next : expected_count;
    end

    initial begin
        $monitor("Time=%0t | rst_n=%b | en=%b | mode=%b | count=%0d (Expected:%0d) | crit=%b (Expected:%b)", 
                 $time, rst_n, en, mode, count_val, expected_count, critical, expected_critical);
    end

endmodule
