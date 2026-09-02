
`timescale 1ns/1ps

module tb_tag_detector();

    reg clk;
    reg rst_n;
    reg clean_press;
    wire tag;

    // Instantiate the DUT (Device Under Test)
    tag_detector dut (
        .clean_press(clean_press),
        .clk(clk),
        .rst_n(rst_n),
        .tag(tag)
    );

    // -----------------------------------------------------------
    // OVERRIDE PARAMETERS FOR SIMULATION
    // We override the deep internal parameters to small numbers 
    // so we don't have to simulate 50 million clock cycles.
    // MAX_HOLD = 10 cycles, MAX_REPEAT = 4 cycles
    // -----------------------------------------------------------
    defparam dut.h_detect.MAX_HOLD = 10;
    defparam dut.h_detect.MAX_REPEAT = 4;

    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

// Test Sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_tag_detector);

        // 1. Initialize
        rst_n = 0;
        clean_press = 0;
        
        // 2. Wait 2 clock cycles, then release reset on the falling edge
        @(negedge clk);
        @(negedge clk);
        rst_n = 1;

        // -------------------------------------------------------
        // TEST 1: Short Press (Posedge Only)
        // -------------------------------------------------------
        $display("--- Testing Short Press (Expect Posedge only) ---");
        @(negedge clk);      // Wait for a falling edge
        clean_press = 1;     // Press button
        
        // Wait 2 full clock cycles
        @(negedge clk);
        @(negedge clk);
        clean_press = 0;     // Release button
        
        // Wait 4 clock cycles to ensure no hold triggers
        repeat(4) @(negedge clk);

        // -------------------------------------------------------
        // TEST 2: Long Press (Posedge + Hold pulses)
        // -------------------------------------------------------
        $display("--- Testing Long Press (Expect Posedge, then Hold pulses) ---");
        @(negedge clk);
        clean_press = 1;     // Press button
        
        // Wait 20 clock cycles (enough to trigger MAX_HOLD and MAX_REPEAT)
        repeat(20) @(negedge clk); 

        clean_press = 0;     // Release the button
        
        // Wait a few cycles before ending
        repeat(4) @(negedge clk);

        $display("--- Simulation Complete ---");
        $finish;
    end

    initial begin
        $monitor("Time=%0t | rst_n=%b | clean_press=%b | pedge=%b | hold=%b | OVERALL TAG=%b", 
                 $time, rst_n, clean_press, dut.pedge, dut.hold, tag);
    end

endmodule