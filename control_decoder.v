module control_decoder (
    input tag,
    input[1:0] set,
    input[2:0] set_field,
    input[5:0] critical_val,    // {month_critical, day, hour, minute, second, micro-second}
    output mode,
    output[5:0] en_val  // {en_year, en_month, en_day, en_hour, en_minute, en_second}
);
    reg[5:0] en_val_0, en_val_1;
     
    // en_val_0 truyen gia tri enable trong luc dem
    // en_val_1 truyen gia tri enable trong luc edit

    always @(*) begin
        // Edit mode enable values
        case (set_field)
            3'b000: en_val_1 = {5'b0, tag};       // sec edit
            3'b001: en_val_1 = {4'b0, tag, 1'b0}; // min edit
            3'b010: en_val_1 = {3'b0, tag, 2'b0}; // hour edit
            3'b011: en_val_1 = {2'b0, tag, 3'b0}; // day edit
            3'b100: en_val_1 = {1'b0, tag, 4'b0}; // month edit
            3'b101: en_val_1 = {tag, 5'b0};       // year edit
            default: en_val_1 = 6'b0;
        endcase

        // Counting mode enable values (Parallel logic, no ripple)
        en_val_0[0] = critical_val[0];
        en_val_0[1] = critical_val[1] & critical_val[0];
        en_val_0[2] = critical_val[2] & critical_val[1] & critical_val[0];
        en_val_0[3] = critical_val[3] & critical_val[2] & critical_val[1] & critical_val[0];
        en_val_0[4] = critical_val[4] & critical_val[3] & critical_val[2] & critical_val[1] & critical_val[0];
        en_val_0[5] = critical_val[5] & critical_val[4] & critical_val[3] & critical_val[2] & critical_val[1] & critical_val[0];
    end
    
    assign en_val = set[1] ? en_val_1 : en_val_0;
    assign mode = set[0];

endmodule