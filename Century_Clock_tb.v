`timescale 1ns / 1ps

module Century_Clock_tb();

    reg clk;
    reg rst_n;
    reg press;
    reg [1:0] set;
    reg [2:0] set_field;
    reg date_time;
    wire [55:0] LED;

    Century_Clock dut (
        .clk(clk),
        .rst_n(rst_n),
        .press(press),
        .set(set),
        .set_field(set_field),
        .date_time(date_time),
        .LED(LED)
    );
    
    // set param to lower value for fast check
    defparam dut.debounce_inst.DEBOUNCE_TIME_MS = 0;    // no debounce, press is already clean
    defparam dut.tag_inst.h_detect.MAX_HOLD = 10;   // hold for 10 clock
    defparam dut.tag_inst.h_detect.MAX_REPEAT = 2;  // repeat 2 clock

    // 50MHz Clock Generation
    initial clk = 0;
    always #10 clk = ~clk;

    // ==========================================================
    // Set Time via Negative Edge Synchronization
    // ==========================================================
    task set_time;
        input [13:0] year;
        input [3:0]  month;
        input [4:0]  day;
        input [4:0]  hour;
        input [5:0]  minute;
        input [5:0]  second;
        begin
            // 1. Wait for the falling edge of the clock
            @(negedge clk); 
            
            // 2. Safely force the internal registers
            force dut.year_counter.count_val = year;
            force dut.month_counter.count_val = month;
            force dut.day_counter.count_val = day;
            force dut.hour_counter.count_val = hour;
            force dut.minute_counter.count_val = minute;
            force dut.second_counter.count_val = second;
            
            // 3. Wait exactly one full clock cycle to let combinational logic settle
            @(negedge clk);
            
            // 4. Safely release before the next positive edge
            release dut.year_counter.count_val;
            release dut.month_counter.count_val;
            release dut.day_counter.count_val;
            release dut.hour_counter.count_val;
            release dut.minute_counter.count_val;
            release dut.second_counter.count_val;
        end
    endtask

    // Print the time whenever it changes
    always @(dut.second_val, dut.minute_val, dut.hour_val, dut.day_val, dut.month_val, dut.year_val) begin
        $display("[%0t] Time: %04d-%02d-%02d %02d:%02d:%02d", 
                 $time, dut.year_val, dut.month_val, dut.day_val, 
                 dut.hour_val, dut.minute_val, dut.second_val);
    end

    initial begin
        // Initialize Inputs
        rst_n = 0; 
        press = 1;
        set = 2'b00;
        set_field = 3'b000;
        date_time = 1;

        // Force micro-counter critical flag to 1
        // This guarantees the seconds increment every single clock cycle
        // 1 clk cycle = 1 sec in tb time
        force dut.critical_val[0] = 1;

        // =======================================================
        // 1. COUNTING UP TESTS
        // =======================================================

        #100;
        rst_n = 1; 
        $display("\n=== COUNTING UP ===");

        // 1. Minute Rollover
        $display("\n--- Minute Rollover ---");
        set_time(2026, 8, 26, 0, 0, 58);
        #100;

        // 2. Hour Rollover
        $display("\n--- Hour Rollover ---");
        set_time(2026, 8, 26, 0, 59, 58);
        #100;
        
        // 3. Day Rollover
        $display("\n--- Day Rollover ---");
        set_time(2026, 8, 26, 23, 59, 58);
        #100;

        // 4.1. Month Rollover (Mar 30 -> Mar 31)
        $display("\n--- Month Rollover ---");
        set_time(2024, 3, 30, 23, 59, 58);
        #100;
        
        // 4.2. Month Rollover (Mar 31 -> Apr 1)
        $display("\n--- Month Rollover ---");
        set_time(2024, 3, 31, 23, 59, 58);
        #100;
        
        // 4.3. Month Rollover (Apr 29 -> Apr 30)
        $display("\n--- Month Rollover ---");
        set_time(2024, 4, 29, 23, 59, 58);
        #100;

        // 4.4. Month Rollover (Apr 30 -> May 1)
        $display("\n--- Month Rollover ---");
        set_time(2024, 4, 30, 23, 59, 58);
        #100;

        // 5.1. Leap Year Check (Feb 28 -> Feb 29)
        $display("\n--- Leap Year Check (2024) ---");
        set_time(2024, 2, 28, 23, 59, 58);
        #100;

        // 5.2. Leap Year Rollover (Feb 29 -> Mar 1)
        $display("\n--- Leap Year Rollover (2024) ---");
        set_time(2024, 2, 29, 23, 59, 58);
        #100;

        // 5.3. Leap Year Check (Feb 28 -> Feb 29)
        $display("\n--- Leap Year Check (2000) ---");
        set_time(2000, 2, 28, 23, 59, 58);
        #100;

        // 5.4. Leap Year Rollover (Feb 29 -> Mar 1)
        $display("\n--- Leap Year Rollover (2000) ---");
        set_time(2000, 2, 29, 23, 59, 58);
        #100;

        // 5.5. Non-Leap Year Check (Feb 28 -> Mar 1)
        $display("\n--- Non-Leap Year Check (2026) ---");
        set_time(2026, 2, 28, 23, 59, 58);
        #100;

        // 5.6. Non-Leap Year Check (Feb 28 -> Mar 1)
        $display("\n--- Non-Leap Year Check (2100) ---");
        set_time(2100, 2, 28, 23, 59, 58);
        #100;

        // 6. Year Rollover
        $display("\n--- Year Rollover ---");
        set_time(2026, 12, 31, 23, 59, 58);
        #100;

        // =======================================================
        // 2. COUNTING DOWN TESTS
        // =======================================================

        set = 2'b01;
        $display("\n=== COUNTING DOWN ===");

        // 1. Minute Rollover 
        $display("\n--- Minute Rollover ---");
        set_time(2026, 8, 26, 0, 10, 01);
        #100;

        // 2. Hour Rollover
        $display("\n--- Hour Rollover ---");
        set_time(2026, 8, 26, 6, 00, 01);
        #100;
        
        // 3. Day Rollover
        $display("\n--- Day Rollover ---");
        set_time(2026, 8, 26, 00, 00, 02);
        #100;

        // 4.1. Month Rollover (Apr 2 -> Apr 1)
        $display("\n--- Month Rollover ---");
        set_time(2024, 4, 2, 00, 00, 02);
        #100;
                
        // 4.2. Month Rollover (Apr 1 -> Mar 31)
        $display("\n--- Month Rollover ---");
        set_time(2024, 4, 1, 00, 00, 02);
        #100;
        
        // 4.3. Month Rollover (May 2 -> May 1)
        $display("\n--- Month Rollover ---");
        set_time(2024, 5, 2, 00, 00, 02);
        #100;

        // 4.4. Month Rollover (May 1 -> Apr 30)
        $display("\n--- Month Rollover ---");
        set_time(2024, 5, 1, 00, 00, 02);
        #100;

        // 5.1. Leap Year Check (Mar 1 -> Feb 29)
        $display("\n--- Leap Year Check (2024) ---");
        set_time(2024, 3, 01, 00, 00, 02);
        #100;

        // 5.2. Leap Year Check (Mar 1 -> Feb 29)
        $display("\n--- Leap Year Check (2000) ---");
        set_time(2000, 3, 01, 00, 00, 02);
        #100;

        // 5.3. Non-Leap Year Check (Mar 1 -> Feb 28)
        $display("\n--- Non-Leap Year Check (2026) ---");
        set_time(2026, 3, 01, 00, 00, 02);
        #100;

        // 5.4. Non-Leap Year Check (Mar 1 -> Feb 28)
        $display("\n--- Non-Leap Year Check (2100) ---");
        set_time(2100, 3, 01, 00, 00, 02);
        #100;

        // 6. Year Rollover
        $display("\n--- Year Rollover ---");
        set_time(2026, 1, 01, 00, 00, 02);
        #100;

        // =======================================================
        // 3. MANUAL SETTING
        // =======================================================

        $display("\n=== MANUAL SETTING ===");
        
        // release to stop counting each second, switch to manual setting
        release dut.critical_val[0];

        // hold press = 0 in #300 = 15 cycle = 10 (1 time hold) + 5 (2 times repeat)
        // this will display 3 next value after set time

        $display("\n--- Set Up: Minute (59 -> 00) ---");
        set_time(2026, 9, 2, 12, 58, 0); 
        set = 2'b10;
        set_field = 3'd1;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Down: Minute (00 -> 59) ---");
        set_time(2026, 9, 2, 11, 1, 0);
        set = 2'b11;
        set_field = 3'd1;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Up: Hour (23 -> 00) ---");
        set_time(2026, 9, 2, 22, 59, 0); 
        set = 2'b10;
        set_field = 3'd2;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Down: Hour (00 -> 23) ---");
        set_time(2026, 9, 2, 1, 0, 0); 
        set = 2'b11;
        set_field = 3'd2;
        #100 press = 0; #300 press = 1;
        #200;
        
        $display("\n--- Set Up: Day (31 -> 01) ---");
        set_time(2026, 8, 30, 10, 0, 0); 
        set = 2'b10;
        set_field = 3'd3;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Up: Day (30 -> 01) ---");
        set_time(2026, 9, 29, 10, 0, 0); 
        set = 2'b10;
        set_field = 3'd3;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Up: Day (29 -> 01) ---");
        set_time(2024, 2, 28, 10, 0, 0); 
        set = 2'b10;
        set_field = 3'd3;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Up: Day (28 -> 01) ---");
        set_time(2026, 2, 27, 10, 0, 0); 
        set = 2'b10;
        set_field = 3'd3;
        #100 press = 0; #300 press = 1;
        #200;
        
        $display("\n--- Set Down: Day (01 -> 31) ---");
        set_time(2026, 5, 2, 10, 0, 0);  
        set = 2'b11;
        set_field = 3'd3;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Down: Day (01 -> 30) ---");
        set_time(2026, 4, 2, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd3;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Down: Day (01 -> 29) ---");
        set_time(2024, 2, 2, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd3;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Down: Day (01 -> 28) ---");
        set_time(2100, 2, 2, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd3;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Up: Month (12 -> 01) ---");
        set_time(2026, 11, 15, 10, 0, 0); 
        set = 2'b10;
        set_field = 3'd4;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Down: Month (01 -> 12) ---");
        set_time(2026, 2, 15, 12, 0, 0); 
        set = 2'b11;
        set_field = 3'd4;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Up: Year (9999 -> 0000) ---");
        set_time(9998, 5, 15, 10, 0, 0); 
        set = 2'b10;
        set_field = 3'd5;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- Set Down: Year (0000 -> 9999) ---");
        set_time(0001, 5, 15, 12, 0, 0); 
        set = 2'b11;
        set_field = 3'd5;
        #100 press = 0; #300 press = 1;
        #200;

        // =======================================================
        // 4. HARDWARE CLAMP TESTS (SET MONTH -> MAX_DAY change)
        // =======================================================

        $display("\n=== CLAMP TEST ===");

        // hold press = 0 in #300 = 15 cycle = 10 (1 time hold) + 5 (2 times repeat)
        // this will display 3 next value after set time

        $display("\n--- 31/03 -> 28/02 -> 28/01 -> 28/12 ---");
        set_time(2026, 3, 31, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd4;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- 31/03 -> 29/02 -> 29/01 -> 29/12 ---");
        set_time(2024, 3, 31, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd4;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- 31/05 -> 30/04 -> 30/03 -> 29/02 ---");
        set_time(2024, 5, 31, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd4;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- 31/05 -> 30/06 -> 30/07 -> 30/08 ---");
        set_time(2026, 5, 31, 10, 0, 0);
        set = 2'b10;
        set_field = 3'd4;
        #100 press = 0; #300 press = 1;
        #200;

        $display("\n--- 29/02/2024 -> 28/02/2025---");
        set_time(2024, 2, 29, 10, 0, 0);
        set = 2'b10;
        set_field = 3'd5;
        #100 press = 0; #300 press = 1;
        #200;

        #300;

        $display("\n=== ALL TESTS COMPLETED ===");
        $stop;
    end

endmodule
