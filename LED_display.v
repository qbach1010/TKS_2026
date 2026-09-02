module LED_display (
    input date_time,
    input [15:0] year_BCD,
    input [7:0] month_BCD,
    input [7:0] day_BCD,
    input [7:0] hour_BCD,
    input [7:0] minute_BCD,
    input [7:0] second_BCD,
    output [55:0] LED
);
    wire [55:0] LED0, LED1;

    // LED0: display date: DD/MM/YYYY

    decode_BCD_7seg display_day_tens (.BCD(day_BCD[7:4]), .led(LED0[55:49]));
    decode_BCD_7seg display_day_ones (.BCD(day_BCD[3:0]), .led(LED0[48:42]));

    decode_BCD_7seg display_month_tens (.BCD(month_BCD[7:4]), .led(LED0[41:35]));
    decode_BCD_7seg display_month_ones (.BCD(month_BCD[3:0]), .led(LED0[34:28]));

    decode_BCD_7seg display_year_thousand (.BCD(year_BCD[15:12]), .led(LED0[27:21]));
    decode_BCD_7seg display_year_hundred (.BCD(year_BCD[11:8]), .led(LED0[20:14]));
    decode_BCD_7seg display_year_tens (.BCD(year_BCD[7:4]), .led(LED0[13:7]));
    decode_BCD_7seg display_year_ones (.BCD(year_BCD[3:0]), .led(LED0[6:0]));

    // LED1: display time: HH/MM/--SS

    decode_BCD_7seg display_hour_tens (.BCD(hour_BCD[7:4]), .led(LED1[55:49]));
    decode_BCD_7seg display_hour_ones (.BCD(hour_BCD[3:0]), .led(LED1[48:42]));

    decode_BCD_7seg display_minute_tens (.BCD(minute_BCD[7:4]), .led(LED1[41:35]));
    decode_BCD_7seg display_minute_ones (.BCD(minute_BCD[3:0]), .led(LED1[34:28]));
		
	 // Two empty LEDs
	 assign LED1[27:14] = {7'b1111111, 7'b1111111};
	 
    decode_BCD_7seg display_second_tens (.BCD(second_BCD[7:4]), .led(LED1[13:7]));
    decode_BCD_7seg display_second_ones (.BCD(second_BCD[3:0]), .led(LED1[6:0]));

    // MUX
    assign LED = date_time ? LED1 : LED0;

endmodule