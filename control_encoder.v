module control_encoder (
    input tag,
    input [1:0] set,
    input [2:0] set_field,
    input [5:0] max_val,    // {month_max, day, hour, minute, second, micro-second}
    output mode,
    output [5:0] en_val  // {en_year, en_month, en_day, en_hour, en_minute, en_second}
);
    genvar i;
    reg [5:0] en_val_0, en_val_1;
    
    assign en_val = set[1] ? en_val_1 : en_val_0;
    assign mode = &set;
    assign en_val_0[0] = max_val[0]

    generate
        for (i = 1; i < 6; i = i + 1) begin
            en_val_0[i] = &max_val[i:0]
        end
    endgenerate

    always @(tag, set_field) begin
        en_val_1 = 6'b0;
        case (set_field)
            3'b000: en_val_1[0] = tag;
            3'b001: en_val_1[1] = tag;
            3'b010: en_val_1[2] = tag;
            3'b011: en_val_1[3] = tag;
            3'b100: en_val_1[4] = tag;
            3'b101: en_val_1[5] = tag;
        endcase
    end

endmodule
