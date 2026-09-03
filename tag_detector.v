module posedge_detector (
    input in, clk, output out
);
    reg Q;

    always @ (posedge clk)
        Q <= in;

    assign out = in & (~Q);

endmodule

module hold_detector # (parameter MAX_HOLD = 50_000_000, MAX_REPEAT = 10_000_000) (
    input in, clk, rst_n, output out
);
    reg [$clog2(MAX_HOLD)-1 : 0] count;
    reg [$clog2(MAX_HOLD)-1 : 0] count_next;

    assign out = (count == MAX_HOLD);

    always @ (count, in, out) begin
        case ({in, out})
            2'b10: count_next = count + 1;
            2'b11: count_next = count - MAX_REPEAT;
            default: count_next = 0;
        endcase
    end

    always @ (posedge clk)
        count <= rst_n ? count_next : 0;
    
endmodule

module tag_detector (input clean_press, clk, rst_n, output tag);
    
    wire pedge, hold;

    posedge_detector p_detect (.in(clean_press), .clk(clk), .out(pedge));
    hold_detector h_detect (.in(clean_press), .clk(clk), .rst_n(rst_n), .out(hold));

    assign tag = pedge | hold;

endmodule
