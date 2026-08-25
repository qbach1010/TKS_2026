module control_decoder (
    input tag,
    input[1:0] set,
    input[2:0] set_field,
    input[5:0] max_val,    // {month_max, day, hour, minute, second, micro-second}
    output mode,
    output [5:0] en_val  // {en_year, en_month, en_day, en_hour, en_minute, en_second}
);
    reg[5:0] en_val_0, en_val_1;

    always @ (tag, set, set_field, max_val) begin
        case (set_field)
            3'b000: en_val_1 = {5'b0, tag};
            3'b001: en_val_1 = {4'b0, tag, 1'b0};
            3'b010: en_val_1 = {3'b0, tag, 2'b0};
            3'b011: en_val_1 = {2'b0, tag, 3'b0};
            3'b100: en_val_1 = {1'b0, tag, 4'b0};
            3'b101: en_val_1 = {tag, 5'b0};
            default: en_val_1 = 6'b0;
        endcase

        en_val_0[0] = max_val[0];

        for (i=1; i<6; i = i+1)
            en_val_0[i] = en_val_0[i-1] & critical_val[i];
    end
    
    assign en_val = set[1] ? en_val_1 : en_val_0;
    assign mode = &set;

endmodule
