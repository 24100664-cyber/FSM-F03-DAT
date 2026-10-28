`timescale 1ns/1ps

module f03_v2_p2_gate_tb;

    reg clk = 0;
    reg rst_n = 0;
    reg digit_valid = 0;
    reg [3:0] digit = 0;

    wire unlock;
    wire locked;

    supply1 VPWR;
    supply0 VGND;

    f03_lock_scaffold_explicit dut (
        .clk(clk),
        .rst_n(rst_n),
        .digit_valid(digit_valid),
        .digit(digit),
        .unlock(unlock),
        .locked(locked),
        .VPWR(VPWR),
        .VGND(VGND)
    );

    always #5 clk = ~clk;

    task send_digit;
        input [3:0] value;
        begin
            @(negedge clk);
            digit = value;
            digit_valid = 1;
            @(negedge clk);
            digit_valid = 0;
        end
    endtask

    integer timeout_count;

    initial begin
        $dumpfile(
          "05_VERIFICATION/waveforms/v2_p2_check_20261028/f03_v2_p2_gate.vcd"
        );
        $dumpvars(0, f03_v2_p2_gate_tb);

        repeat (3) @(negedge clk);
        rst_n = 1;

        // Nhap ma dung 1234.
        send_digit(1);
        send_digit(2);
        send_digit(3);
        send_digit(4);

        // Cho FSM xac nhan ma va vao UNLOCK_ST.
        timeout_count = 0;
        while (unlock !== 1'b1 && timeout_count < 10) begin
            @(negedge clk);
            timeout_count = timeout_count + 1;
        end

        if (unlock !== 1'b1) begin
            $fatal(1, "FAIL: Khong vao trang thai unlock.");
        end

        $display("PASS: Da vao unlock tai %0t ns", $time);

        // Vong while da thoat tai negedge khi unlock = 1.
        // Dua chu so 9 vao ngay tai negedge nay.
        digit = 4'd9;
        digit_valid = 1'b1;

        // Canh posedge tiep theo la canh FSM xu ly UNLOCK_ST.
        @(posedge clk);
        #1;

        if ({dut.\d0[3] , dut.\d0[2] , dut.\d0[1] , dut.\d0[0] } !== 4'd9) begin
            $fatal(1,
              "FAIL P-2: d0 khong luu chu so 9. d0=%b",
              {dut.\d0[3] , dut.\d0[2] , dut.\d0[1] , dut.\d0[0] });
        end

        $display("PASS P-2: d0 da nhan chu so 9 tai %0t ns", $time);

        @(negedge clk);
        digit_valid = 0;

        repeat (2) @(negedge clk);
        $display("P-2 gate-level check completed.");
        $finish;
    end

endmodule
