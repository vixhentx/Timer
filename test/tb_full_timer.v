`timescale 1ns/1ps

module tb_full_timer;
    reg clk = 1'b0;
    reg cin = 1'b0;
    reg down = 1'b0;
    reg rst = 1'b0;
    reg put = 1'b0;
    reg [2:0] preset_sel = 3'd0;
    reg [3:0] preset = 4'd0;

    wire [3:0] sec_l, sec_h, min_l, min_h, hour_l, hour_h;

    full_timer dut(
        .sec_l(sec_l), .sec_h(sec_h),
        .min_l(min_l), .min_h(min_h),
        .hour_l(hour_l), .hour_h(hour_h),
        .clk(clk), .cin(cin), .down(down), .rst(rst),
        .put(put), .preset_sel(preset_sel), .preset(preset)
    );

    always #5 clk = ~clk;

    task automatic tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task automatic set_digit(input reg [2:0] digit, input reg [3:0] value);
        begin
            @(negedge clk);
            cin = 1'b0;
            preset_sel = digit;
            preset = value;
            put = 1'b1;
            tick;
            @(negedge clk);
            put = 1'b0;
        end
    endtask

    task automatic check_time(
        input reg [3:0] expected_sl, input reg [3:0] expected_sh,
        input reg [3:0] expected_ml, input reg [3:0] expected_mh,
        input reg [3:0] expected_hl, input reg [3:0] expected_hh
    );
        begin
            if ({hour_h, hour_l, min_h, min_l, sec_h, sec_l} !==
                {expected_hh, expected_hl, expected_mh, expected_ml,
                 expected_sh, expected_sl}) begin
                $display("FAIL at %0t: got %0d%0d:%0d%0d:%0d%0d",
                         $time, hour_h, hour_l, min_h, min_l, sec_h, sec_l);
                $fatal(1);
            end
        end
    endtask

    initial begin
        rst = 1'b1;
        tick;
        rst = 1'b0;
        check_time(0, 0, 0, 0, 0, 0);

        // Carry through seconds into minutes.
        set_digit(0, 8);
        set_digit(1, 5);
        cin = 1'b1;
        tick;
        check_time(9, 5, 0, 0, 0, 0);
        tick;
        check_time(0, 0, 1, 0, 0, 0);

        // Carry through 59 minutes into hours.
        set_digit(0, 9);
        set_digit(1, 5);
        set_digit(2, 9);
        set_digit(3, 5);
        cin = 1'b1;
        tick;
        check_time(0, 0, 0, 0, 1, 0);

        // Full six-digit upward wrap.
        set_digit(0, 9);
        set_digit(1, 5);
        set_digit(2, 9);
        set_digit(3, 5);
        set_digit(4, 9);
        set_digit(5, 9);
        cin = 1'b1;
        tick;
        check_time(0, 0, 0, 0, 0, 0);

        // Borrow across seconds and minutes: 00:00:00 -> 99:59:59.
        down = 1'b1;
        set_digit(0, 0);
        set_digit(1, 0);
        set_digit(2, 0);
        set_digit(3, 0);
        set_digit(4, 0);
        set_digit(5, 0);
        cin = 1'b1;
        tick;
        check_time(9, 5, 9, 5, 9, 9);

        // Borrow across seconds into minutes: 00:00:10 -> 00:00:09.
        set_digit(0, 0);
        set_digit(1, 1);
        set_digit(2, 0);
        set_digit(3, 0);
        set_digit(4, 0);
        set_digit(5, 0);
        cin = 1'b1;
        tick;
        check_time(9, 0, 0, 0, 0, 0);

        // Invalid preset must not load a value outside this digit's modulus.
        set_digit(1, 0);
        preset_sel = 1;
        preset = 4'd9;
        put = 1'b1;
        tick;
        put = 1'b0;
        check_time(9, 0, 0, 0, 0, 0);

        $display("PASS: full_timer directional counting tests passed");
        $finish;
    end
endmodule
