// F03 mentor scaffold.
// IMPORTANT: not an official F03 interface. Replace ports/encoding/timing
// after freezing the official F03 HTML.

module f03_lock_scaffold #(
    parameter logic [3:0] SECRET0 = 4'd1,
    parameter logic [3:0] SECRET1 = 4'd2,
    parameter logic [3:0] SECRET2 = 4'd3,
    parameter logic [3:0] SECRET3 = 4'd4,
    parameter int LOCK_THRESHOLD = 3
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       digit_valid,
    input  logic [3:0] digit,
    output logic       unlock,
    output logic       locked,
    output logic [1:0] position,
    output logic [1:0] fail_count
);

    typedef enum logic [2:0] {
        WAIT_DIGIT = 3'd0,
        CHECK_CODE = 3'd1,
        UNLOCK_ST  = 3'd2,
        LOCKED_ST  = 3'd3
    } state_t;

    state_t state, next_state;
    logic [3:0] d0,d1,d2,d3;
    logic [3:0] n0,n1,n2,n3;
    logic [1:0] npos, nfail;
    logic [3:0] ndigit;
    logic [1:0] pos_eff;   // vi tri hieu dung: 0 khi vua mo khoa xong

    always_comb begin
        // Vua mo khoa => lan thu ke bat dau tu vi tri 0 NGAY trong chu ky nay.
        pos_eff = (state == UNLOCK_ST) ? 2'd0 : position;

        next_state = state;
        n0=d0; n1=d1; n2=d2; n3=d3;
        npos=pos_eff;  nfail=fail_count;
        ndigit=digit;

        if (state == LOCKED_ST) begin
            next_state = LOCKED_ST;
        end else if (state == UNLOCK_ST || state == WAIT_DIGIT) begin
            if (state == UNLOCK_ST) next_state = WAIT_DIGIT;
            if (digit_valid) begin
              case (pos_eff)
                2'd0: begin n0=digit; npos=1; end
                2'd1: begin n1=digit; npos=2; end
                2'd2: begin n2=digit; npos=3; end
                2'd3: begin
                    n3=digit;
                    npos=0;
                    next_state=CHECK_CODE;
                end
              endcase
            end
        end

        if (state == CHECK_CODE) begin
            if ((d0==SECRET0)&&(d1==SECRET1)&&(d2==SECRET2)&&(d3==SECRET3)) begin
                nfail=0;
                next_state=UNLOCK_ST;
            end else if (fail_count == LOCK_THRESHOLD-1) begin
                nfail=LOCK_THRESHOLD[1:0];
                next_state=LOCKED_ST;
            end else begin
                nfail=fail_count+1'b1;
                npos=0;
                next_state=WAIT_DIGIT;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= WAIT_DIGIT;
            d0<=0; d1<=0; d2<=0; d3<=0;
            position<=0;
            fail_count<=0;
        end else begin
            state <= next_state;
            d0<=n0; d1<=n1; d2<=n2; d3<=n3;
            position<=npos;
            fail_count<=nfail;
        end
    end

    always_comb begin
        unlock = (state == UNLOCK_ST);
        locked = (state == LOCKED_ST);
    end
endmodule
