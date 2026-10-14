module f03_tb;
    logic clk,rst_n,digit_valid;
    logic [3:0] digit;
    logic unlock,locked;
    logic [1:0] position,fail_count;
    logic unlock_x, locked_x;

    f03_lock_scaffold #(
        .SECRET0(4'd1),.SECRET1(4'd2),.SECRET2(4'd3),.SECRET3(4'd4)
    ) dut(
        .clk(clk),.rst_n(rst_n),.digit_valid(digit_valid),.digit(digit),
        .unlock(unlock),.locked(locked),.position(position),.fail_count(fail_count)
    );

    // Module thuc su di vao netlist/STA/GDSII: chay song song de bang chung
    // mo phong ap dung cho CA HAI module.
    f03_lock_scaffold_explicit #(
        .SECRET0(4'd1),.SECRET1(4'd2),.SECRET2(4'd3),.SECRET3(4'd4)
    ) dut_x(
        .clk(clk),.rst_n(rst_n),.digit_valid(digit_valid),.digit(digit),
        .unlock(unlock_x),.locked(locked_x)
    );

    always #5 clk=~clk;

    task automatic check_equiv;
        begin
            assert(unlock===unlock_x && locked===locked_x)
                else $fatal(1,"scaffold vs explicit khac nhau: unlock %b/%b locked %b/%b",
                            unlock,unlock_x,locked,locked_x);
        end
    endtask

    task automatic send_digit(input logic [3:0] d);
        begin
            digit=d; digit_valid=1;
            @(posedge clk); #1;
            check_equiv();
            digit_valid=0;
            @(posedge clk); #1;
            check_equiv();
        end
    endtask

    task automatic send_code(
        input logic [3:0] a,b,c,d
    );
        begin send_digit(a); send_digit(b); send_digit(c); send_digit(d); end
    endtask

    initial begin
        clk=0; rst_n=0; digit_valid=0; digit=0;
        repeat(2) @(posedge clk);
        rst_n=1;

        send_code(1,2,3,4);
        assert(!locked) else $fatal(1,"correct code locked");
        assert(fail_count==0) else $fatal(1,"correct code did not clear failures");

        send_code(9,9,9,9);
        assert(fail_count==1) else $fatal(1,"failure count 1 missing");

        send_code(1,2,3,4);
        assert(fail_count==0) else $fatal(1,"success did not reset consecutive failures");

        send_code(9,9,9,9);
        send_code(9,9,9,9);
        send_code(9,9,9,9);
        assert(locked) else $fatal(1,"three consecutive failures did not lock");

        send_digit(1);
        assert(locked) else $fatal(1,"input escaped lockout");

        rst_n=0;
        @(posedge clk); #1;
        rst_n=1;
        assert(!locked) else $fatal(1,"reset did not clear lockout");

        // C-5: chu so phat ra DUNG trong chu ky unlock=1 phai duoc nhan.
        send_code(1,2,3,4);              // mo khoa
        assert(unlock) else $fatal(1,"unlock pulse missing");
        send_code(1,2,3,4);              // lan thu ke, bat dau ngay
        assert(!locked && fail_count==0) else $fatal(1,"digit swallowed after unlock");

        // C-2': sai 2 -> dung -> sai 2 => tong 4 lan sai ma KHONG duoc khoa.
        send_code(9,9,9,9); send_code(9,9,9,9);
        send_code(1,2,3,4);
        send_code(9,9,9,9); send_code(9,9,9,9);
        assert(!locked) else $fatal(1,"counted TOTAL failures, not CONSECUTIVE");

        $display("F03 TB PASS");
        $finish;
    end
endmodule
