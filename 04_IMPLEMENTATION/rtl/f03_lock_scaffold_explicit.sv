// Alternative explicit scaffold for architecture experiments.
// Not an official F03 interface.

module f03_lock_scaffold_explicit #(
    parameter logic [3:0] SECRET0=4'd1,
    parameter logic [3:0] SECRET1=4'd2,
    parameter logic [3:0] SECRET2=4'd3,
    parameter logic [3:0] SECRET3=4'd4
)(
    input logic clk, input logic rst_n,
    input logic digit_valid, input logic [3:0] digit,
    output logic unlock, output logic locked
);
    typedef enum logic [2:0] {WAIT_ST=3'd0,CHECK_ST=3'd1,
                              UNLOCK_ST=3'd2,LOCKED_ST=3'd3} state_t;
    state_t state;
    logic [1:0] pos, fails;
    logic [3:0] d0,d1,d2,d3;

    always_ff @(posedge clk) begin
        if(!rst_n) begin
            state<=WAIT_ST; pos<=0; fails<=0;
            d0<=0; d1<=0; d2<=0; d3<=0;
        end else begin
            case(state)
                WAIT_ST: if(digit_valid) begin
                    case(pos)
                        0: begin d0<=digit; pos<=1; end
                        1: begin d1<=digit; pos<=2; end
                        2: begin d2<=digit; pos<=3; end
                        3: begin d3<=digit; pos<=0; state<=CHECK_ST; end
                    endcase
                end
                CHECK_ST: begin
                    if(d0==SECRET0 && d1==SECRET1 && d2==SECRET2 && d3==SECRET3) begin
                        fails<=0; state<=UNLOCK_ST;
                    end else if(fails==2) begin
                        fails<=3; state<=LOCKED_ST;
                    end else begin
                        fails<=fails+1'b1; state<=WAIT_ST;
                    end
                end
                UNLOCK_ST: begin
                    state<=WAIT_ST;
                    // Nhan luon chu so dau cua lan thu ke tiep.
                    if(digit_valid) begin d0<=digit; pos<=1; end
                    else            pos<=0;
                end
                LOCKED_ST: state<=LOCKED_ST;
                default: state<=WAIT_ST;
            endcase
        end
    end

    assign unlock=(state==UNLOCK_ST);
    assign locked=(state==LOCKED_ST);
endmodule
