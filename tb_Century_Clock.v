`timescale 1ns / 1ps

module tb_Century_Clock();

    reg clk;
    reg rst_n;
    reg press;
    reg [1:0] set;
    reg [2:0] set_field;
    reg date_time;
    wire [55:0] LED;

    // Instantiate UUT
    Century_Clock uut (
        .clk(clk),
        .rst_n(rst_n),
        .press(press),
        .set(set),
        .set_field(set_field),
        .date_time(date_time),
        .LED(LED)
    );

    // 50MHz Clock Generation
    initial clk = 0;
    always #10 clk = ~clk;

    // =======================================================
    // FOOLPROOF TASK: Set Time via Negative Edge Synchronization
    // =======================================================
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
            force uut.year_counter.count_val = year;
            force uut.month_counter.count_val = month;
            force uut.day_counter.count_val = day;
            force uut.hour_counter.count_val = hour;
            force uut.minute_counter.count_val = minute;
            force uut.second_counter.count_val = second;
            
            // 3. Wait exactly one full clock cycle to let combinational logic settle
            @(negedge clk); 
            
            // 4. Safely release before the next positive edge
            release uut.year_counter.count_val;
            release uut.month_counter.count_val;
            release uut.day_counter.count_val;
            release uut.hour_counter.count_val;
            release uut.minute_counter.count_val;
            release uut.second_counter.count_val;
        end
    endtask

    // Print the time whenever seconds change
    always @(uut.second_val) begin
        $display("[%0t] Time: %04d-%02d-%02d %02d:%02d:%02d", 
                 $time, uut.year_val, uut.month_val, uut.day_val, 
                 uut.hour_val, uut.minute_val, uut.second_val);
    end

    initial begin
        // Initialize Inputs
        rst_n = 0; 
        press = 1;
        set = 2'b00;
        set_field = 3'b000;
        date_time = 1;

        // =======================================================
        // Force micro-counter critical flag to 1
        // This guarantees the seconds increment every single clock cycle.
        // =======================================================
        force uut.critical_val[0] = 1;

	//1 clk cycle = 1 sec in tb time

        #100;
        rst_n = 1; 
        $display("=== COUNTING UP ===");

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

        // 4. Leap Year Check (Feb 28 -> Feb 29)
        $display("\n--- Leap Year Check (2024) ---");
        set_time(2024, 2, 28, 23, 59, 58);
        #100;

        // 5. Leap Year Rollover (Feb 29 -> Mar 1)
        $display("\n--- Leap Year Rollover (2024) ---");
        set_time(2024, 2, 29, 23, 59, 58);
        #100;

        // 6. Year Rollover
        $display("\n--- Year Rollover ---");
        set_time(2026, 12, 31, 23, 59, 58);
        #100;

	set = 2'b01;

	$display("=== COUNTING DOWN ===");

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

        // 4.4. Month Rollover (May 1 -> Apr 30)
        $display("\n--- Month Rollover ---");
        set_time(2024, 5, 1, 00, 00, 02);
        #100;


        // 4. Leap Year Check (Feb 28 -> Feb 29)
        $display("\n--- Leap Year Check (2026) ---");
        set_time(2026, 3, 01, 00, 00, 02);
        #100;

        // 5. Leap Year Rollover (Feb 29 -> Mar 1)
        $display("\n--- Leap Year Rollover (2024) ---");
        set_time(2024, 3, 01, 00, 00, 02);
        #100;

        // 6. Year Rollover
        $display("\n--- Year Rollover ---");
        set_time(2026, 1, 01, 00, 00, 02);
        #100;

	$display("\n=== MANUAL SETTING & CLAMP TEST ===");
        
        // release to stop counting each second, switch to manual setting
        release uut.critical_val[0];

        $display("\n--- Set Up: Minute (59 -> 00) ---");
        set_time(2026, 9, 2, 12, 59, 0); 
        set = 2'b10;
        set_field = 3'd1;
        #100 press = 0; #100 press = 1;
        #200;

        $display("\n--- Set Down: Minute (00 -> 59) ---");
        set_time(2026, 9, 2, 12, 0, 0); 
        set = 2'b11;
        set_field = 3'd1;
        #100 press = 0; #100 press = 1;
        #200;

        $display("\n--- Set Up: Hour (23 -> 00) ---");
        set_time(2026, 9, 2, 23, 59, 0); 
        set = 2'b10;
        set_field = 3'd2;
        #100 press = 0; #100 press = 1;
        #200;

        $display("\n--- Set Down: Hour (00 -> 23) ---");
        set_time(2026, 9, 2, 0, 0, 0); 
        set = 2'b11;
        set_field = 3'd2;
        #100 press = 0; #100 press = 1;
        #200;
        
        $display("\n--- Set Up: Day (31 -> 01) ---");
        set_time(2026, 8, 31, 10, 0, 0); 
        set = 2'b10;
        set_field = 3'd3;
        #100 press = 0; #100 press = 1;
        #200;
        
        $display("\n--- Set Down: Day (01 -> 31) ---");
        set_time(2026, 5, 1, 10, 0, 0);  
        set = 2'b11;
        set_field = 3'd3;
        #100 press = 0; #100 press = 1;
        #200;

        $display("\n--- Set Down: Day (01 -> 30) ---");
        set_time(2026, 4, 1, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd3;
        #100 press = 0; #100 press = 1;
        #200;

        $display("\n--- Set Down: Day (01 -> 29) ---");
        set_time(2024, 2, 1, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd3;
        #100 press = 0; #100 press = 1;
        #200;

        $display("\n--- Set Down: Day (01 -> 28) ---");
        set_time(2100, 2, 1, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd3;
        #100 press = 0; #100 press = 1;
        #200;

        $display("\n--- HARDWARE CLAMP: 31/03 -> 28/02 ---");
        set_time(2026, 3, 31, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd4;
        #100 press = 0; #100 press = 1;

        $display("\n--- HARDWARE CLAMP: 31/03 -> 29/02 ---");
        set_time(2024, 3, 31, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd4;
        #100 press = 0; #100 press = 1;

        $display("\n--- HARDWARE CLAMP: 31/04 -> 29/02 ---");
        set_time(2024, 3, 31, 10, 0, 0);
        set = 2'b11;
        set_field = 3'd4;
        #100 press = 0; #100 press = 1;

        $display("\n--- HARDWARE CLAMP: 31/05 -> 30/06 ---");
        set_time(2026, 5, 31, 10, 0, 0);
        set = 2'b10;
        set_field = 3'd4;
        #100 press = 0; #100 press = 1;

        #300;

        $display("\n=== ALL TESTS COMPLETED ===");
        $finish;
    end

endmodule
