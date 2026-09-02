module Century_Clock (
    input clk,               // System's clock (50MHz)
    input rst_n,             // Reset active low
    input press,             // Press button to set value (active low)
    input [1:0] set,         // set[1]: settable, set[0]: mode (1 = rise, 0 = fall)
    input [2:0] set_field,   // 000: second -> 101: year
    input date_time,         // Switch to display: 1 = time, 0 = date
    output [55:0] LED        // 8 x 7-segment LEDs
);

    wire clean_press, tag, mode;
    wire [5:0] en_val;
    wire [5:0] critical_val;
    wire [1:0] days_in_month;
    
    wire [5:0] second_val, minute_val;
    wire [4:0] hour_val, day_val;
    wire [3:0] month_val;
    wire [13:0] year_val;

    wire [7:0] second_BCD, minute_BCD, hour_BCD, day_BCD, month_BCD;
    wire [15:0] year_BCD;

    debouncer debounce_inst (
        .clk(clk), 
        .rst_n(rst_n), 
        .button_in(press), 
        .button_out(clean_press)
    );
    
    tag_detector tag_inst (
        .clean_press(clean_press), 
        .clk(clk), 
        .rst_n(rst_n), 
        .tag(tag)
    );

    control_encoder ctrl_inst (
        .tag(tag),
        .set(set),
        .set_field(set_field),
        .critical_val(critical_val),
        .mode(mode),
        .en_val(en_val)
    );

    // Micro-second counter: generate 1Hz-frequency signal to enable counters, from system's clock 50MHz
    counter #( .MAX_VAL(49999999), .MIN_VAL(0), .INIT_VAL(0) ) micro_counter (
        .en(1'b1), .mode(1'b0), .clk(clk), .rst_n(rst_n), 
        .count_val(),
        .critical(critical_val[0])
    );

    // Second counter (Index 0 of set_field and en_val)
    counter #( .MAX_VAL(59), .MIN_VAL(0), .INIT_VAL(0) ) second_counter (
        .en(en_val[0]), .mode(mode), .clk(clk), .rst_n(rst_n), 
        .count_val(second_val), .critical(critical_val[1])
    );

    // Minute counter (Index 1)
    counter #( .MAX_VAL(59), .MIN_VAL(0), .INIT_VAL(0) ) minute_counter (
        .en(en_val[1]), .mode(mode), .clk(clk), .rst_n(rst_n), 
        .count_val(minute_val), .critical(critical_val[2])
    );

    // Hour counter (Index 2)
    counter #( .MAX_VAL(23), .MIN_VAL(0), .INIT_VAL(0) ) hour_counter (
        .en(en_val[2]), .mode(mode), .clk(clk), .rst_n(rst_n), 
        .count_val(hour_val), .critical(critical_val[3])
    );

    // Day counter (Index 3)
    counter_day day_counter (
        .en(en_val[3]), .mode(mode), .clk(clk), .rst_n(rst_n), 
        .days_in_month(days_in_month), 
        .count_val(day_val), .critical(critical_val[4])
    );

    // Month counter (Index 4)
    counter #( .MAX_VAL(12), .MIN_VAL(1), .INIT_VAL(1) ) month_counter (
        .en(en_val[4]), .mode(mode), .clk(clk), .rst_n(rst_n), 
        .count_val(month_val), .critical(critical_val[5])
    );

    // Year counter (Index 5)
    counter #( .MAX_VAL(9999), .MIN_VAL(0), .INIT_VAL(2026) ) year_counter (
        .en(en_val[5]), .mode(mode), .clk(clk), .rst_n(rst_n), 
        .count_val(year_val), .critical()
    );

    binary_to_BCD bcd_inst (
        .year_val(year_val), 
        .month_val(month_val), 
        .day_val(day_val), 
        .hour_val(hour_val), 
        .minute_val(minute_val), 
        .second_val(second_val),
        .set(set),
        
        .year_BCD(year_BCD), 
        .month_BCD(month_BCD), 
        .day_BCD(day_BCD), 
        .hour_BCD(hour_BCD), 
        .minute_BCD(minute_BCD), 
        .second_BCD(second_BCD),
        .days_in_month(days_in_month)
    );

    LED_display display_inst (
        .date_time(date_time), 
        .year_BCD(year_BCD), 
        .month_BCD(month_BCD), 
        .day_BCD(day_BCD), 
        .hour_BCD(hour_BCD), 
        .minute_BCD(minute_BCD), 
        .second_BCD(second_BCD), 
        .LED(LED)
    );

endmodule
