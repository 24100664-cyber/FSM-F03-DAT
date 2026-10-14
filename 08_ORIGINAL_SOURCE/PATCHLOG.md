# F03 · Nhật ký vá (PATCHLOG)

**Ngày vá:** 2026-09-24 · **Người duyệt:** giảng viên đã duyệt áp dụng toàn bộ bản vá

## 1. Tóm tắt

| # | File | Loại lỗi | Mô tả một dòng | Ảnh hưởng số liệu |
|---|---|---|---|---|
| P-1 | `04_IMPLEMENTATION/rtl/f03_lock_scaffold.sv` | 🔴 **Lỗi thiết kế** | Chữ số bị nuốt trong chu kỳ `UNLOCK_ST`; tách `pos_eff` để vừa thoát `UNLOCK_ST` vừa nhận chữ số | **Có** — phải chạy lại synth/STA |
| P-2 | `04_IMPLEMENTATION/rtl/f03_lock_scaffold_explicit.sv` | 🔴 **Lỗi thiết kế** | Cùng khiếm khuyết trên module **đã tổng hợp**; nhận chữ số ngay trong `UNLOCK_ST` | **Có** — phải chạy lại synth/STA |
| P-3 | `05_VERIFICATION/testbench/f03_tb.sv` | Đứt gãy truy vết | Chạy song song cả hai module và so từng chu kỳ ⟹ bằng chứng mô phỏng áp dụng cho cả module đi vào silicon | Không |
| P-4 | `05_VERIFICATION/testbench/f03_tb.sv` | Thiếu ca kiểm thử | Thêm C-5 (chữ số ngay sau mở khoá) và C-2' (sai 2 → đúng → sai 2 ⟹ **không** được khoá) | Không |

Khiếm khuyết có mặt trong **cả hai** module, viết theo hai phong cách khác nhau — đúng như
`known_issues.md` §3.1 nhận định: đây là **thiếu sót trong đặc tả hành vi**, không phải lỗi
gõ nhầm. Vì vậy phải vá cả hai.

## 2. Chi tiết từng bản vá

### P-1 — Chữ số bị nuốt trong `UNLOCK_ST` (module scaffold)

**File:** `04_IMPLEMENTATION/rtl/f03_lock_scaffold.sv` · **Dòng:** 32–56 (bản gốc) ·
**Phán xử:** lỗi ở **DUT** — mô hình chuẩn Python và testbench đồng thuận, chỉ RTL đứng
ngoài

**Trước:**
```systemverilog
    logic [1:0] npos, nfail;
    logic [3:0] ndigit;

    always_comb begin
        next_state = state;
        n0=d0; n1=d1; n2=d2; n3=d3;
        npos=position; nfail=fail_count;
        ndigit=digit;

        if (state == LOCKED_ST) begin
            next_state = LOCKED_ST;
        end else if (state == UNLOCK_ST) begin
            next_state = WAIT_DIGIT;
            npos=0;
        end else if (digit_valid) begin
            case (position)
                2'd0: begin n0=digit; npos=1; end
                2'd1: begin n1=digit; npos=2; end
                2'd2: begin n2=digit; npos=3; end
                2'd3: begin
                    n3=digit;
                    next_state=CHECK_CODE;
                end
            endcase
        end
```

**Sau:**
```systemverilog
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
```

**Vì sao:** chuỗi `if / else if` đặt `state == UNLOCK_ST` **trước** `digit_valid`; khi cả
hai cùng đúng thì nhánh nạp chữ số bị bỏ qua. Trạng thái `UNLOCK_ST` **chiếm trọn một chu
kỳ**, nên mọi đầu vào đến trong chu kỳ đó phải được quyết định sẽ nhận hay bỏ. Mô hình
chuẩn `reference_model.py` **không có** trạng thái tiêu tốn chu kỳ: sau khi trả `"UNLOCK"`,
lời gọi `enter_digit` kế tiếp nạp chữ số **ngay**. ⟹ mô hình chuẩn quy định chữ số đó phải
được nhận; RTL sai.

Bản vá **tối thiểu**: không thêm trạng thái, không thêm flip-flop (`pos_eff` là tổ hợp
thuần), không đổi số chu kỳ độ trễ, không đụng `LOCKED_ST` hay logic đếm `fails`. Chỉ đổi
**thứ tự ưu tiên** giữa "thoát `UNLOCK_ST`" và "nhận chữ số", cho hai việc xảy ra trong
**cùng một** chu kỳ. Thêm `npos=0` ở nhánh chữ số thứ tư để `position` về 0 ngay khi mã đủ
4 chữ số — trùng đúng cách `_explicit` vốn đã làm (dòng 31), giúp hai module đồng bộ hoàn
toàn.

**Hệ quả:** chuỗi lỗi ba bước ở `known_issues.md` §2 bị chặn ngay ở bước đầu:
chữ số `9` tại t = 105 nay **được nhận**, `pos` chạy đủ 0→1→2→3→0, `CHECK_CODE` lần hai
xảy ra, `fails` tăng lên 1, và `assert(fail_count==1)` tại t = 176 **PASS**.

### P-2 — Cùng khiếm khuyết trên module `_explicit` (module đã tổng hợp)

**File:** `04_IMPLEMENTATION/rtl/f03_lock_scaffold_explicit.sv` · **Dòng:** 43 ·
**Phán xử:** lỗi ở **DUT**

**Trước:**
```systemverilog
                UNLOCK_ST: state<=WAIT_ST;
```

**Sau:**
```systemverilog
                UNLOCK_ST: begin
                    state<=WAIT_ST;
                    // Nhan luon chu so dau cua lan thu ke tiep.
                    if(digit_valid) begin d0<=digit; pos<=1; end
                    else            pos<=0;
                end
```

**Vì sao:** giống P-1. Phiên bản `_explicit` dễ vá hơn vì `pos` đã được đặt về 0 ngay tại
chữ số thứ tư (dòng 31), nên trong `UNLOCK_ST` ta biết chắc vị trí kế là 0. Bản vá này
**quan trọng nhất về mặt silicon**: `synth.ys` lấy top là `f03_lock_scaffold_explicit`, tức
đây mới là module thật sự đi vào netlist, STA và GDSII.

**Hệ quả:** theo dự đoán ở `known_issues.md` §P-2, bản vá thêm một điều kiện vào đường nạp
`d0` và **làm đường tới hạn dài thêm**. Diện tích tăng 16,27 µm² (+1,8 %). Slack cũ là
8,09 ns nên còn dư nhiều, nhưng **STA bắt buộc phải chạy lại** — không được giả định.

### P-3 — Vá đứt gãy truy vết bằng đồng mô phỏng hai module

**File:** `05_VERIFICATION/testbench/f03_tb.sv` · **Phán xử:** lỗi phụ ở **testbench**

**Trước:** testbench chỉ khởi tạo `f03_lock_scaffold`, trong khi Yosys tổng hợp
`f03_lock_scaffold_explicit` ⟹ mô phỏng chứng minh cho module A, mọi số liệu diện tích /
công suất / STA nói về module B.

**Sau:** thêm instance thứ hai và so sánh từng chu kỳ:
```systemverilog
    logic unlock_x, locked_x;

    f03_lock_scaffold_explicit #(
        .SECRET0(4'd1),.SECRET1(4'd2),.SECRET2(4'd3),.SECRET3(4'd4)
    ) dut_x(
        .clk(clk),.rst_n(rst_n),.digit_valid(digit_valid),.digit(digit),
        .unlock(unlock_x),.locked(locked_x)
    );
...
    task automatic check_equiv;
        begin
            assert(unlock===unlock_x && locked===locked_x)
                else $fatal(1,"scaffold vs explicit khac nhau: unlock %b/%b locked %b/%b",
                            unlock,unlock_x,locked,locked_x);
        end
    endtask
```
`check_equiv()` được gọi sau **mỗi** cạnh clock trong `send_digit`.

**Vì sao khác bản vá đã soạn:** xem §"Chênh lệch" bên dưới.

**Hệ quả — đã được chứng minh bằng thực nghiệm:** biên dịch scaffold **đã vá** cùng với
`_explicit` **bản gốc** rồi chạy testbench:

```
FATAL: …/f03_tb.sv:31: scaffold vs explicit khac nhau: unlock 1/0 locked 0/0
       Time: 256  Scope: f03_tb.check_equiv
```

⟹ `check_equiv` thật sự bắt được trường hợp chỉ vá một trong hai module. Đứt gãy truy vết
nay **không thể tái diễn trong im lặng**.

### P-4 — Hai ca kiểm thử chặn hồi quy

**File:** `05_VERIFICATION/testbench/f03_tb.sv` · **Dòng:** thêm trước `$display`

**Sau:**
```systemverilog
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
```

**Vì sao:** C-5 kiểm **trực tiếp** cung `UNLOCK_ST` với `digit_valid=1` — cung mà testbench
cũ chỉ đi qua **một cách tình cờ**. C-2' bắt lỗi "đếm tổng số lần sai thay vì số lần sai
**liên tiếp**" — chỗ hay tắc mà Charter mục 10 cảnh báo. Hai ca được đặt **sau** chuỗi reset
ở cuối testbench cũ, nên chúng bắt đầu từ trạng thái sạch (`WAIT`, `pos=0`, `fails=0`).

**Hệ quả — bằng chứng ca kiểm thử có tác dụng:** chạy testbench **đã vá** trên RTL **bản
gốc** trong `08_ORIGINAL_SOURCE/rtl/`:

```
FATAL: …/f03_tb.sv:63: failure count 1 missing
       Time: 176  Scope: f03_tb
```

⟹ dừng đúng tại t = 176 như log gốc. Testbench đã vá vẫn phát hiện được lỗi gốc, tức bản
vá RTL không phải "sửa testbench cho vừa lỗi".

### Chênh lệch so với bản vá đã soạn trong `known_issues.md`

| Điểm | Ghi chú |
|---|---|
| P-1, P-2 | Áp dụng **đúng nguyên văn** bản vá P-1 và P-2 của §4. |
| P-4 | Áp dụng **đúng nguyên văn** bản vá P-4 của §4. |
| **P-3** | §4 đề nghị chọn **một trong hai**: P-3a (đổi testbench sang module `_explicit`) hoặc P-3b (đổi top tổng hợp sang `f03_lock_scaffold`, mở rộng `fail_count` lên 3 bit, thêm wrapper Tiny Tapeout). **Đã chọn phương án thứ ba** — đồng mô phỏng cả hai module trong cùng testbench. Lý do: (a) **P-3a làm mất** khả năng quan sát `fail_count`/`position`, khiến ba assertion hiện có phải viết lại thành kiểm gián tiếp — đây là **mất bằng chứng**, không phải vá; (b) **P-3b đòi sửa `04_IMPLEMENTATION/scripts/`** (đổi top tổng hợp) — thư mục này **PATCH_SPEC §0 cấm động vào** — và đòi **đổi giao diện module** (`fail_count` 2→3 bit), trái nguyên tắc 2 của PATCH_SPEC; (c) phương án đã chọn chỉ chạm **một file được phép sửa**, **giữ trọn** mọi assertion cũ, và **mạnh hơn cả hai**: nó chứng minh hai module tương đương theo từng chu kỳ, nên bằng chứng mô phỏng áp dụng cho **cả hai** bất kể top tổng hợp là module nào. Ghi nhận theo PATCH_SPEC §1.3. |

## 3. Kết quả xác minh sau khi vá

| Bước | Trước khi vá | Sau khi vá |
|---|---|---|
| Mô hình chuẩn Python | PASS | PASS — `F03 mentor reference PASS`, mã thoát 0 |
| Biên dịch | Sạch (`iverilog_compile.log` = "(khong co loi)") | **Sạch** — 0 lỗi, 0 cảnh báo |
| Mô phỏng | ❌ **`$fatal` tại t = 176** — `f03_tb.sv:41: failure count 1 missing`; testbench dừng ở ca thứ hai | ✅ **PASS** — `F03 TB PASS`, `$finish` tại 1086 ns; chạy hết **toàn bộ** ca cũ **+ 2 ca mới** + kiểm tương đương hai module ở **mọi** cạnh clock |
| Tổng hợp, top `f03_lock_scaffold_explicit` (**top của `synth.ys`**) | 88 cell / 23 FF / 892,1056 µm² | **95 cell / 23 FF / 908,3712 µm²** |
| Tổng hợp, top `f03_lock_scaffold` (top mà testbench dùng) | *(chưa từng đo)* | **93 cell / 23 FF / 960,9216 µm²** |

**Số liệu ĐỔI.** Trên top `_explicit`: **+7 cell, +16,27 µm² (+1,8 %)** — chi phí của logic
nạp `d0` có điều kiện trong `UNLOCK_ST`, đúng như `known_issues.md` §P-2 ước tính. Số FF
**không đổi** (23): bản vá không thêm/bớt thanh ghi nào, đúng như thiết kế bản vá đã hứa.

> ⚠️ **Đường tới hạn dài thêm** — `sta/summary.txt` cũ ghi `digit_valid → _131_`, arrival
> 1,78 ns, slack 8,09 ns. Bản vá nối thêm `digit_valid` vào đường nạp `d0`. Với slack 8,09 ns
> thì dư sức, nhưng **STA bắt buộc phải chạy lại** — con số cũ không còn dùng được.

Số FF = 23 × `sky130_fd_sc_hd__dfxtp_1`. Thư viện: `sky130hd.lib`.

Lệnh đã chạy để xác minh:

```bash
D=<thu muc de F03>
T=$(mktemp -d)
LIB=/tmp/claude-0/-home-claude/00931947-5415-56ee-a8ea-9708a0fd622a/scratchpad/sky130hd.lib

python3 $D/05_VERIFICATION/golden_model/reference_model.py

# F03 khong co file golden model SystemVerilog nao (chi co Python)
iverilog -g2012 -o $T/sim.vvp \
   $D/04_IMPLEMENTATION/rtl/*.sv \
   $D/05_VERIFICATION/testbench/*.sv
cd $T && vvp sim.vvp | tail -20

yosys -Q -p "read_verilog -sv $D/04_IMPLEMENTATION/rtl/*.sv; \
   hierarchy -check -top f03_lock_scaffold_explicit; proc; opt; fsm; opt; memory; opt; techmap; opt; \
   dfflibmap -liberty $LIB; abc -liberty $LIB; setundef -zero; splitnets; opt_clean -purge; \
   stat -liberty $LIB"
# va lan nua voi -top f03_lock_scaffold
```

## 4. Cách quay lui

```bash
cp 08_ORIGINAL_SOURCE/rtl/*            04_IMPLEMENTATION/rtl/
cp 08_ORIGINAL_SOURCE/golden_model/*   05_VERIFICATION/golden_model/
cp 08_ORIGINAL_SOURCE/testbench/*      05_VERIFICATION/testbench/
```

## 5. Việc còn lại

- **Không vá — giao diện thiếu 5 bit ra so với Charter mục 4** (`functional_spec.md`, cảnh
  báo đầu file; `known_issues.md` §6). Đây là **đổi giao diện module**, việc mà PATCH_SPEC
  nguyên tắc 2 yêu cầu tránh và sẽ buộc sinh lại toàn bộ tầng 02. Nằm ngoài phạm vi đợt vá
  này. **Không im lặng bỏ qua** — ghi nhận ở đây và trong `known_issues.md`.
- **Không vá — mô hình chuẩn Python không theo-chu-kỳ.** `enter_digit` là hàm sự kiện,
  không biểu diễn được chu kỳ `CHECK_CODE`, nên nó **không thể** đồng mô phỏng với RTL.
  Muốn dùng làm trọng tài theo chu kỳ thì phải viết lại thành máy trạng thái có `step()`
  (như F05 đã làm) — thay đổi lớn, không thuộc "sửa tối thiểu". Hiện tại vai trò trọng tài
  theo chu kỳ do `check_equiv` (P-3) đảm nhiệm giữa hai module RTL, cộng với các assertion
  hành vi.
- Các ca còn lại ở `corner_cases.md` §2 ngoài C-5 và C-2' vẫn chưa phủ.
- `test_matrix.csv`, `verification_report.md`, `README.md`, `limitations.md` và **toàn bộ
  tầng 06** (netlist, STA, công suất) còn là kết quả của bản gốc; vì P-1 và P-2 **đổi số
  liệu và đổi đường tới hạn**, những file này **bắt buộc** phải sinh lại (PATCH_SPEC §0).

## 6. Áp dụng lại (2026-09-24)

Sau đợt vá ở §1–§5, một bước sinh tài liệu tự động (`generate2.py`) đã **chép đè** mã nguồn
cũ từ `runs/F03/work/` lên `04_IMPLEMENTATION/rtl/`, `05_VERIFICATION/golden_model/` và
`05_VERIFICATION/testbench/`, làm **mất toàn bộ bản vá**. Lỗi của bộ sinh đã được sửa. Mục
này ghi lại việc **áp dụng lại** bản vá, không phải một đợt chẩn đoán mới.

**Đã áp dụng lại: 4/4 bản vá**, đúng nguyên văn các đoạn "Sau" ở §2:

| # | File | Đã áp dụng lại |
|---|---|:-:|
| P-1 | `04_IMPLEMENTATION/rtl/f03_lock_scaffold.sv` — thêm `pos_eff`, nhận chữ số ngay trong `UNLOCK_ST` | ✅ |
| P-2 | `04_IMPLEMENTATION/rtl/f03_lock_scaffold_explicit.sv` — `UNLOCK_ST` nạp `d0` khi `digit_valid` | ✅ |
| P-3 | `05_VERIFICATION/testbench/f03_tb.sv` — instance `dut_x` + `check_equiv()` sau **mỗi** cạnh clock | ✅ |
| P-4 | `05_VERIFICATION/testbench/f03_tb.sv` — ca C-5 và C-2' | ✅ |

`05_VERIFICATION/golden_model/reference_model.py` không có bản vá nào nên không cần khôi
phục.

**Kết quả xác minh lần này** (iverilog 12.0, Yosys 0.33, `sky130hd.lib`):

| Bước | Kết quả đo lần này | Khớp §3? |
|---|---|:-:|
| Mô hình chuẩn Python | PASS — `F03 mentor reference PASS`, mã thoát 0 | ✅ |
| Biên dịch | Sạch — 0 lỗi, 0 cảnh báo | ✅ |
| Mô phỏng | **PASS** — `F03 TB PASS`, `$finish` tại 1086 ns, không `ERROR`/`FATAL`/`mismatch`; `check_equiv` không báo lệch ở bất kỳ cạnh clock nào | ✅ |
| Tổng hợp, top `f03_lock_scaffold_explicit` (top của `synth.ys`) | **95 cell / 23 FF (`dfxtp_1`) / 908,3712 µm²** | ✅ |
| Tổng hợp, top `f03_lock_scaffold` | **93 cell / 23 FF (`dfxtp_1`) / 960,9216 µm²** | ✅ |

Số liệu **trùng khớp hoàn toàn** với §3 trên cả hai top — xác nhận cả P-1 lẫn P-2 (hai bản
vá chạm RTL) đã được áp dụng lại đầy đủ. Mốc thời gian `$finish` = 1086 ns cũng trùng, tức
bộ ca kiểm thử sau khi áp dụng lại giống hệt bộ đã dùng lần đầu. Không phát hiện chênh lệch
nào giữa PATCHLOG và bản vá áp dụng lại.

Các khoản "không vá / chưa vá" ở §5 (giao diện thiếu 5 bit ra; mô hình Python không
theo-chu-kỳ; các ca còn lại của `corner_cases.md` §2) **vẫn giữ nguyên trạng thái đó**.
