module f03_tb;
    logic clk,rst_n,digit_valid;
    logic [3:0] digit;
    logic unlock,locked;
    logic [1:0] position,fail_count;

    f03_lock_scaffold #(
        .SECRET0(4'd1),.SECRET1(4'd2),.SECRET2(4'd3),.SECRET3(4'd4)
    ) dut(
        .clk(clk),.rst_n(rst_n),.digit_valid(digit_valid),.digit(digit),
        .unlock(unlock),.locked(locked),.position(position),.fail_count(fail_count)
    );

    always #5 clk=~clk;

    task automatic send_digit(input logic [3:0] d);
        begin
            digit=d; digit_valid=1;
            @(posedge clk); #1;
            digit_valid=0;
            @(posedge clk); #1;
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

        $display("F03 TB PASS");
        $finish;
    end
endmodule
