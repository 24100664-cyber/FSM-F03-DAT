# F03 · Máy trạng thái hữu hạn (FSM)

Đọc trực tiếp từ `04_IMPLEMENTATION/rtl/f03_lock_scaffold_explicit.sv` — module Yosys đã
tổng hợp (`06_GDSII/synthesis/synth_stat.txt`: `=== f03_lock_scaffold_explicit ===`).

---

## 1. Sơ đồ trạng thái ASCII đầy đủ

```
                            rst_n = 0  (đồng bộ, mọi trạng thái)
        ┌──────────────────────────────────────────────────────────────────────┐
        │                                                                      │
        ▼                                                                      │
  ╔═══════════════════╗                                                        │
  ║     WAIT_ST       ║◀──────────────────────────────────────┐                │
  ║     3'd000        ║                                       │                │
  ║  unlock=0 locked=0║                                       │                │
  ╚═══════════════════╝                                       │                │
    │   ▲        │  ▲                                         │                │
    │   │        │  │                                         │                │
    │   │        │  └─ (a) digit_valid=1 ∧ pos∈{0,1,2}        │                │
    │   │        │       → d[pos]←digit, pos←pos+1            │                │
    │   │        └──── (b) digit_valid=0 → giữ nguyên         │                │
    │   │                                                     │                │
    │   │ (f) sai ∧ fails<2                                   │ (e) luôn luôn  │
    │   │     fails←fails+1                                   │     (1 chu kỳ) │
    │   │                                                     │                │
    │   └─────────────────────────┐                           │                │
    │                             │                           │                │
    │ (c) digit_valid=1 ∧ pos==3  │                  ╔════════╧═════════╗      │
    │     d3←digit, pos←0         │                  ║    UNLOCK_ST     ║      │
    ▼                             │                  ║     3'd010       ║      │
  ╔═══════════════════╗           │                  ║ unlock=1 locked=0║      │
  ║     CHECK_ST      ║           │                  ╚══════════════════╝      │
  ║     3'd001        ║           │                           ▲                │
  ║  unlock=0 locked=0║───────────┘                           │                │
  ╚═══════════════════╝                                       │ (d) ĐÚNG mã    │
    │                                                         │     fails←0    │
    └─────────────────────────────────────────────────────────┘                │
    │                                                                          │
    │ (g) SAI mã ∧ fails==2                                                    │
    │     fails←3                                                              │
    ▼                                                                          │
  ╔═══════════════════╗                                                        │
  ║    LOCKED_ST      ║──┐                                                     │
  ║     3'd011        ║  │ (h) mọi đầu vào — TRẠNG THÁI HẤP THỤ                │
  ║ unlock=0 locked=1 ║◀─┘   (digit_valid bị bỏ qua hoàn toàn)                 │
  ╚═══════════════════╝                                                        │
            │                                                                  │
            └── lối ra DUY NHẤT: rst_n = 0 ────────────────────────────────────┘

  ┌──────────────────────────────────────────────────────────────────────┐
  │ MÃ BẤT HỢP LỆ: 3'd100, 3'd101, 3'd110, 3'd111                        │
  │   default: state <= WAIT_ST   (RTL dòng 45)                          │
  │   ► pos và fails KHÔNG được xoá trong nhánh này ◀                    │
  └──────────────────────────────────────────────────────────────────────┘

  ⚠️ KHIẾM KHUYẾT ĐANG MỞ trên cung (e): trong chu kỳ UNLOCK_ST, nếu digit_valid=1
     thì chữ số đó bị NUỐT — RTL dòng 43 chỉ có `state<=WAIT_ST`, không có nhánh nạp.
     Đây là nguyên nhân trực tiếp của lỗi mô phỏng. Xem 05_VERIFICATION/known_issues.md
```

## 2. Bảng chuyển trạng thái đầy đủ

Đọc từ `case(state)` — RTL dòng 25–46. Ký hiệu: `V` = `digit_valid`, `M` = `(d0..d3 == SECRET0..3)`.

| # | Trạng thái hiện tại | `V` | `pos` | `M` | `fails` | **Trạng thái kế** | Cập nhật thanh ghi | Dòng RTL |
|---:|---|:-:|:-:|:-:|:-:|---|---|---|
| 1 | `WAIT_ST` (000) | 0 | – | – | – | `WAIT_ST` | không đổi | 26 |
| 2 | `WAIT_ST` | 1 | 0 | – | – | `WAIT_ST` | `d0←digit`, `pos←1` | 28 |
| 3 | `WAIT_ST` | 1 | 1 | – | – | `WAIT_ST` | `d1←digit`, `pos←2` | 29 |
| 4 | `WAIT_ST` | 1 | 2 | – | – | `WAIT_ST` | `d2←digit`, `pos←3` | 30 |
| 5 | `WAIT_ST` | 1 | 3 | – | – | **`CHECK_ST`** | `d3←digit`, `pos←0` | 31 |
| 6 | `CHECK_ST` (001) | × | × | 1 | – | **`UNLOCK_ST`** | `fails←0` | 35–36 |
| 7 | `CHECK_ST` | × | × | 0 | 2 | **`LOCKED_ST`** | `fails←3` | 37–38 |
| 8 | `CHECK_ST` | × | × | 0 | 0 | `WAIT_ST` | `fails←1` | 39–40 |
| 9 | `CHECK_ST` | × | × | 0 | 1 | `WAIT_ST` | `fails←2` | 39–40 |
| 10 | `CHECK_ST` | × | × | 0 | 3 | `WAIT_ST` | `fails←0` (tràn 2 bit!) | 39–40 · xem §6 |
| 11 | `UNLOCK_ST` (010) | × | × | × | × | `WAIT_ST` | **không đổi — chữ số bị nuốt** ⚠️ | 43 |
| 12 | `LOCKED_ST` (011) | × | × | × | × | `LOCKED_ST` | không đổi (hấp thụ) | 44 |
| 13 | 100/101/110/111 | × | × | × | × | `WAIT_ST` | `pos`, `fails` **không** được xoá | 45 |
| R | **mọi trạng thái, `rst_n=0`** | × | × | × | × | `WAIT_ST` | `pos←0, fails←0, d0..d3←0` | 21–23 |

`×` = không ảnh hưởng · `–` = không liên quan.

**Hàng 10 đáng chú ý:** `fails==3` chỉ đạt được khi đã vào `LOCKED_ST`, mà `LOCKED_ST` hấp
thụ nên không bao giờ quay lại `CHECK_ST`. Vậy hàng 10 là **không thể xảy ra** trong hoạt
động bình thường — nhưng nó *tồn tại* trong mã và sẽ xảy ra nếu `state` bị nhiễu. Nếu xảy
ra, `fails+1 = 3+1 = 0` (tràn 2 bit) ⇒ bộ đếm bị xoá ngầm. Đây là một bug tiềm ẩn đáng chỉ
cho sinh viên, dù hiện không tiếp cận được.

## 3. Mealy hay Moore — bằng chứng

**F03 là FSM Moore.** Ba bằng chứng độc lập:

**Bằng chứng 1 — mã nguồn.** RTL dòng 50–51:

```systemverilog
    assign unlock=(state==UNLOCK_ST);
    assign locked=(state==LOCKED_ST);
```

Vế phải **chỉ chứa `state`**. Không có `digit`, không có `digit_valid`. Theo định nghĩa,
đầu ra chỉ là hàm của trạng thái hiện tại ⇒ Moore.

**Bằng chứng 2 — netlist.** Trong `06_GDSII/synthesis/netlist.v`, hai net `unlock` và
`locked` được lái bởi logic chỉ lấy `state[2:0]` làm đầu vào; không cổng nào trên đường tới
`unlock`/`locked` có `digit_valid` hay `digit[i]` ở chân vào. (So sánh: ở F04, net
`mealy_detect` được lái bởi `_16_ nor2` có đầu vào bắt nguồn từ `bit_in` — đó mới là Mealy.)

**Bằng chứng 3 — STA.** `sta/timing_report_max.txt` liệt kê **10 đường chậm nhất, tất cả
đều kết thúc ở chân `D` của flip-flop**, không có đường nào kiểu `input → output port`.
Nếu là Mealy thì phải tồn tại đường tổ hợp `digit_valid → unlock` và OpenSTA sẽ in ra như
một đường `in → out`. (Đối chiếu F04: đường chậm nhất của nó đúng là
`bit_in (input) → mealy_detect (output)`.)

**Hệ quả của việc là Moore:** `unlock` chỉ xuất hiện **1 chu kỳ đầy đủ**, luôn căn theo cạnh
clock, không bị nhiễu bởi glitch trên `digit`. Đổi lại phải trả **2 chu kỳ độ trễ** từ chữ
số cuối tới `unlock` (`functional_spec.md` §5) — nếu là Mealy có thể rút còn 1.

## 4. Mã hoá trạng thái

| Trạng thái | Mã (3 bit) | Khai báo RTL | FF netlist |
|---|:-:|---|---|
| `WAIT_ST` | `3'b000` | dòng 14 | `state[2]`=`_130_`, `state[1]`=`_129_`, `state[0]`=`_128_` |
| `CHECK_ST` | `3'b001` | dòng 14 | ″ |
| `UNLOCK_ST` | `3'b010` | dòng 15 | ″ |
| `LOCKED_ST` | `3'b011` | dòng 15 | ″ |

**Kiểu mã hoá: binary (mã nhị phân đặc), do người viết chỉ định tường minh** qua
`typedef enum logic [2:0] {WAIT_ST=3'd0, ...}`.

| Câu hỏi | Trả lời có bằng chứng |
|---|---|
| Vì sao 3 bit cho 4 trạng thái, trong khi 2 bit là đủ? | Vì khai báo là `logic [2:0]`. Đây là **lãng phí 1 FF** — Yosys **không** tự thu về 2 bit (netlist có đủ `_128_`,`_129_`,`_130_` với `Q = state[0..2]`). Bit `state[2]` luôn bằng 0 trong 4 trạng thái hợp lệ nhưng vẫn tồn tại vật lý. |
| Yosys có đổi sang one-hot không? | **Không.** `synth_stat.txt` cho `dfxtp_1 = 23` = 3+16+2+2 đúng bằng số bit khai báo. Nếu FSM bị mã hoá lại one-hot thì `state` phải thành 4 FF và tổng phải là 24. |
| Nếu muốn one-hot thì làm sao? | Thêm `(* fsm_encoding = "one-hot" *)` trước khai báo `state`, hoặc gọi `fsm_map` trong script Yosys. **Không được tự làm** — Charter mục 3 liệt "tự tối ưu netlist bằng tay" vào ngoài phạm vi. |
| Binary hay one-hot tốt hơn ở đây? | Với 4 trạng thái, chênh lệch không đáng kể. Bảng số thật: hiện 3 FF; one-hot cần 4 FF nhưng logic giải mã `state==X` co lại còn 1 dây. Chỉ có thể kết luận sau khi chạy thật cả hai — **hồ sơ này chưa chạy phương án one-hot**, không được đoán. |

## 5. So sánh với module thứ hai trong hồ sơ

`04_IMPLEMENTATION/rtl/f03_lock_scaffold.sv` mô tả **cùng một FSM** nhưng theo phong cách
hai khối (`always_comb` cho `next_state` + `always_ff` cho thanh ghi), và có thêm cổng ra
`position[1:0]`, `fail_count[1:0]`.

| Khía cạnh | `..._explicit` (đã tổng hợp) | `..._scaffold` (testbench dùng) |
|---|---|---|
| Phong cách | 1 khối `always_ff` | 2 khối (`always_comb` + `always_ff`) |
| Số cổng ra | 2 | 4 |
| `pos` reset về 0 ở chữ số thứ tư | ✅ dòng 31 `pos<=0` | ❌ giữ nguyên `position=3`, chỉ xoá ở nhánh sai (dòng 67) hoặc ở `UNLOCK_ST` (dòng 45) |
| Nuốt chữ số ở `UNLOCK_ST` | ✅ **có** (dòng 43) | ✅ **có** (dòng 43–46: `else if (digit_valid)` nằm sau nhánh `UNLOCK_ST`) |
| Ngưỡng khoá | hằng `2` viết cứng (dòng 37) | tham số `LOCK_THRESHOLD` (dòng 10, 62) |

> **Khiếm khuyết "nuốt chữ số" có mặt ở CẢ HAI module.** Đó là bằng chứng mạnh rằng đây là
> **lỗi thiết kế**, không phải lỗi testbench hay lỗi gõ nhầm.

## 6. Xử lý trạng thái bất hợp lệ

| Câu hỏi | Trả lời |
|---|---|
| Có bao nhiêu mã thừa? | 3 bit ⇒ 8 mã; dùng 4 ⇒ **4 mã thừa**: `3'd4`…`3'd7` |
| RTL xử lý thế nào? | `default: state<=WAIT_ST;` (dòng 45) — quay về trạng thái an toàn |
| Hiện thực trong silicon có thật không? | **Chỉ một phần.** Vì `case` đã liệt kê 4/8 mã và có `default`, Yosys coi 4 mã thừa là *reachable* và phải lái chúng về `WAIT_ST`. Nhưng tool **không** phải sinh logic riêng: nó có thể chọn hàm trạng-thái-kế sao cho tình cờ mọi mã thừa đều về 000, hoặc dùng chúng làm don't-care để tối giản. Muốn biết chắc phải chạy mô phỏng gate-level **ép** `state` vào từng mã thừa — **chưa chạy** (tầng L4, `testplan.md`). |
| `pos`/`fails` có được cứu không? | **Không.** Nhánh `default` chỉ đặt `state`. Sau sự kiện lạ, khối trở lại `WAIT_ST` nhưng `pos` có thể là 2 và `fails` có thể là 1 ⇒ lần nhập kế tiếp lệch pha và ngưỡng khoá bị rút ngắn. |
| Nên sửa thế nào? | `default: begin state<=WAIT_ST; pos<=0; fails<=0; end`. **Chưa áp dụng** — giữ nguyên bản gốc, cần thầy duyệt. |
| Có trạng thái nào không tới được không? | Không, cả 4 trạng thái hợp lệ đều tới được: `WAIT_ST` (reset), `CHECK_ST` (hàng 5), `UNLOCK_ST` (hàng 6), `LOCKED_ST` (hàng 7). |
| Có deadlock không? | Có **một** theo thiết kế: `LOCKED_ST` (hàng 12). Đó là tính năng, không phải lỗi — nhưng phải ghi vào hợp đồng hệ thống rằng lối ra nằm ngoài khối (`system_diagram.md` §1). |

## 7. Ba câu hỏi kỹ thuật của Charter mục 2 — trả lời tại chỗ

**Câu 1 — "Ba thứ phải nhớ cùng lúc tốn tổng bao nhiêu ô nhớ?"**

| Thứ phải nhớ | Tín hiệu | FF | Netlist |
|---|---|---:|---|
| Vị trí đang nhập | `pos[1:0]` | 2 | `_147_`, `_148_` |
| Số lần sai | `fails[1:0]` | 2 | `_149_`, `_150_` |
| Trạng thái khoá | `state[2:0]` | 3 | `_128_`, `_129_`, `_130_` |
| **Cộng ba thứ Charter hỏi** | | **7** | khớp ước lượng Charter mục 10 (6–8) ✅ |
| *Cộng thêm* bộ đệm mã nhập | `d0..d3` | 16 | `_131_`…`_146_` |
| **Tổng thật của thiết kế** | | **23** | `synth_stat.txt`: `dfxtp_1 = 23` |

Ba thứ Charter hỏi tốn **7 ô nhớ**. Thiết kế thật tốn **23** vì còn phải đệm cả mã người
dùng nhập — lý do và phương án thay thế ở `datapath.md` §5.

**Câu 2 — "Vì sao khoá tạm chỉ thoát được bằng reset, và đánh đổi cái gì?"**

Vì `LOCKED_ST` là trạng thái hấp thụ (hàng 12), và `rst_n` là tín hiệu **duy nhất** được xử
lý ngoài `case(state)` (RTL dòng 21, trước `else`). Đánh đổi:

| Được | Mất |
|---|---|
| **0 flip-flop** cho bộ đếm thời gian (một timeout 30 s ở 100 kHz cần ~22 bit ⇒ +22 FF, gần bằng cả thiết kế hiện tại) | Người dùng hợp lệ gõ nhầm 3 lần bị khoá cho tới khi có người mang chìa reset |
| Logic đơn giản, dễ chứng minh đúng (INV-2 chỉ 1 dòng) | Cần thêm hạ tầng vật lý ngoài chip (nút reset có kiểm soát) |
| Nằm trong phạm vi Charter mục 3 ("khoá theo thời gian" là ngoài phạm vi) | Trải nghiệm người dùng kém |

**Câu 3 — "Bằng chứng nào chứng minh 'sai ba lần LIÊN TIẾP' chứ không phải 'sai ba lần tổng cộng'?"**

Bằng chứng nằm ở **hàng 6** của bảng chuyển trạng thái: nhánh mã đúng thực thi
`fails<=0` (RTL dòng 36). Nghĩa là mỗi lần thử đúng **xoá sạch** bộ đếm. Vì thế
`fails` luôn đếm *số lần sai kể từ lần đúng gần nhất* = số lần sai **liên tiếp**.

Để bằng chứng này thành *bằng chứng thực thi* chứ không chỉ là đọc mã, cần ca
**C-2'** (`02_SPECIFICATION/corner_cases.md` §2): sai 2 → đúng → sai 2 ⇒ tổng 4 lần sai mà
**không** được khoá. **Ca này hiện chưa có trong testbench** ⇒ khẳng định này mới chỉ được
chứng minh bằng đọc mã, chưa bằng mô phỏng.

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
