# F03 · Sơ đồ khối bên trong (Block Diagram)

Vẽ theo **đúng** `04_IMPLEMENTATION/rtl/f03_lock_scaffold_explicit.sv` (52 dòng) — module
mà Yosys đã tổng hợp. Tên net trong ngoặc là tên thật trong `06_GDSII/synthesis/netlist.v`.

---

## 1. Sơ đồ bên trong

```
 digit[3:0] ──────────────┬────────────────────────────────────────────┐
                          │                                            │
 digit_valid ──┬──────────┼───────────────────────┐                    │
               │          │                       │                    │
               ▼          ▼                       ▼                    ▼
   ┌───────────────────────────────┐   ┌────────────────┐   ┌────────────────────────┐
   │  GIẢI MÃ VỊ TRÍ (load enable) │   │ BỘ ĐẾM VỊ TRÍ  │   │  BỘ ĐỆM MÃ NHẬP        │
   │  en_i = digit_valid           │   │   pos[1:0]     │   │  d0 d1 d2 d3 (4×4 bit) │
   │       & (state==WAIT_ST)      │──▶│  2 FF          │   │  16 FF                 │
   │       & (pos==i)              │   │ _147_,_148_    │   │  _131_ … _146_         │
   │  → _076_ nand2, _083_ nor3    │   │ pos+1 mod 4    │   │  nạp qua 16× mux2i_1   │
   │    _077_ and3, _075_ and2     │   └────────────────┘   │  (_084_,_086_,_088_,…) │
   └───────────────┬───────────────┘            │           └───────────┬────────────┘
                   │ en_d0..en_d3               │                       │ d0..d3
                   │                            │                       ▼
                   │                            │        ┌──────────────────────────────┐
                   │                            │        │ SO SÁNH VỚI MÃ HẰNG SỐ       │
                   │                            │        │ (SECRET0..3 = 1,2,3,4)       │
                   │                            │        │  _068_ nor4b : d0 == 4'b0001 │
                   │                            │        │  _069_ nor4b : d1 == 4'b0010 │
                   │                            │        │  _066_ nor4bb: d2 == 4'b0011 │
                   │                            │        │  _067_ nor4b : d3 == 4'b0100 │
                   │                            │        │  _070_ and4  : match         │
                   │                            │        │  _071_ nand4 : ~match        │
                   │                            │        │  ► 0 flip-flop ◄             │
                   │                            │        └───────────┬──────────────────┘
                   │                            │                    │ match / ~match
                   ▼                            ▼                    ▼
   ┌──────────────────────────────────────────────────────────────────────────────────┐
   │                    LÕI ĐIỀU KHIỂN — FSM Moore 4 trạng thái                        │
   │   state[2:0]  (3 FF: _128_, _129_, _130_)                                         │
   │   WAIT_ST=0 · CHECK_ST=1 · UNLOCK_ST=2 · LOCKED_ST=3 · default → WAIT_ST          │
   │   logic trạng thái kế: _072_ nor3b, _074_ nor3, _079_ nor3, _082_ o2111a, …       │
   └────────┬───────────────────────────────────────┬─────────────────────┬───────────┘
            │                                       │                     │
            ▼                                       ▼                     ▼
   ┌────────────────────┐                  ┌──────────────┐      ┌──────────────┐
   │ BỘ ĐẾM SAI LIÊN TIẾP│                 │ unlock       │      │ locked       │
   │  fails[1:0] 2 FF    │                 │ = (state==2) │      │ = (state==3) │
   │  _149_, _150_       │                 └──────────────┘      └──────────────┘
   │  +1 / về 0 / chốt 3 │                        ▲                     ▲
   │  _123_ o211a,       │                        └── Moore: chỉ phụ thuộc state
   │  _124_ nand2,       │
   │  _125_ nand4        │
   └─────────┬───────────┘
             │ fails==2 ?  →  quyết định vào LOCKED_ST
             └──────────────────▶ (quay lại lõi FSM)

 rst_n ──▶ (_034_ = ~rst_n) ──▶ chèn vào TRƯỚC chân D của cả 23 FF
           ► reset ĐỒNG BỘ — `dfxtp_1` không có chân reset ◄
```

## 2. Bảng ánh xạ cấu trúc RTL → phần cứng sinh ra

| Cấu trúc RTL | Dòng | Phần cứng thật | Bằng chứng netlist |
|---|---|---|---|
| `state_t state;` (`enum logic[2:0]`) | 14–16 | **3 `dfxtp_1`** | `_128_.Q=state[0]`, `_129_.Q=state[1]`, `_130_.Q=state[2]` |
| `logic [1:0] pos;` | 17 | **2 `dfxtp_1`** + logic +1 | `_147_.Q=pos[0]`, `_148_.Q=pos[1]`, `_118_ xnor2` |
| `logic [1:0] fails;` | 17 | **2 `dfxtp_1`** + logic tăng/xoá/chốt | `_149_.Q=fails[0]`, `_150_.Q=fails[1]` |
| `logic [3:0] d0,d1,d2,d3;` | 18 | **16 `dfxtp_1`** + **16 `mux2i_1`** làm đường nạp | `_131_…_146_`, `_084_/_086_/_088_/_090_/…` |
| `case(pos) 0:… 3:…` bên trong `if(digit_valid)` | 27–32 | **giải mã vị trí → 4 tín hiệu load-enable**, hiện thực bằng `and2/and3/nor3` | `_075_ and2(digit_valid,_043_)`, `_083_ nor3(pos[1],pos[0],_045_)` |
| `d0==SECRET0 && … && d3==SECRET3` | 35 | **4 cổng 4-đầu-vào + 1 AND4**, **0 FF** | `_066_…_070_` — xem §3 |
| `fails<=fails+1'b1` | 40 | bộ tăng 2 bit rất nhỏ | `_123_ o211a`, `_124_ nand2`, `_125_ nand4` |
| `LOCKED_ST: state<=LOCKED_ST;` | 44 | vòng tự-giữ trên `state`, không có cổng nào phá được | `_072_ nor3b` có `state[2]` ở đầu vào |
| `default: state<=WAIT_ST;` | 45 | **không sinh cổng riêng** — tool dùng nó làm *don't-care* để tối giản 4 mã thừa | xem `fsm.md` §6 |
| `assign unlock/locked` | 50–51 | logic thuần tổ hợp từ 3 bit `state` | `unlock`, `locked` là net được lái trực tiếp |
| `if(!rst_n)` trong `always_ff` | 21 | **reset đồng bộ**: `~rst_n` (`_034_`) đi vào cổng trước chân `D` | `_085_ nor2(.A(_034_), .B(_050_), .Y(_002_))` → `_131_/D` |

**Tổng kiểm: 3 + 2 + 2 + 16 = 23 flip-flop — khớp chính xác `synth_stat.txt` (`dfxtp_1` = 23).**
Không có flip-flop nào "thừa ra" ⇒ không có thanh ghi nào bị suy ra ngoài ý muốn, và **mã bí
mật không chiếm ô nhớ nào**.

## 3. Phát hiện quan trọng — mã bí mật biến thành **cực tính chân cổng**

Đọc thẳng từ `06_GDSII/synthesis/netlist.v` (dòng 114–148):

```verilog
sky130_fd_sc_hd__nor4b_1  _068_ (.A(\d0[3] ), .B(\d0[2] ), .C(\d0[1] ), .D_N(\d0[0] ), .Y(_037_));
sky130_fd_sc_hd__nor4b_1  _069_ (.A(\d1[3] ), .B(\d1[2] ), .C(\d1[0] ), .D_N(\d1[1] ), .Y(_038_));
sky130_fd_sc_hd__nor4bb_1 _066_ (.A(\d2[3] ), .B(\d2[2] ), .C_N(\d2[1] ), .D_N(\d2[0] ), .Y(_035_));
sky130_fd_sc_hd__nor4b_1  _067_ (.A(\d3[3] ), .B(\d3[1] ), .C(\d3[0] ), .D_N(\d3[2] ), .Y(_036_));
sky130_fd_sc_hd__and4_1   _070_ (.A(_035_), .B(_036_), .C(_037_), .D(_038_), .X(_039_));
```

Giải mã: `nor4b` cho `Y=1` khi các chân thường = 0 **và** chân `_N` = 1.

| Cổng | Bit phải bằng 0 | Bit phải bằng 1 | ⇒ giá trị digit | `SECRET` tương ứng |
|---|---|---|---:|---:|
| `_068_` | d0[3],d0[2],d0[1] | d0[0] | `4'b0001` = **1** | SECRET0 = 1 ✅ |
| `_069_` | d1[3],d1[2],d1[0] | d1[1] | `4'b0010` = **2** | SECRET1 = 2 ✅ |
| `_066_` | d2[3],d2[2] | d2[1],d2[0] | `4'b0011` = **3** | SECRET2 = 3 ✅ |
| `_067_` | d3[3],d3[1],d3[0] | d3[2] | `4'b0100` = **4** | SECRET3 = 4 ✅ |

> **Đây là câu trả lời có bằng chứng cho Charter mục 9.** Mã bí mật để ở `parameter` nên nó
> **không tốn một flip-flop nào** — nhưng cái giá là nó nằm phơi ra trong netlist dưới dạng
> *chân nào bị đảo*. Ai đọc được netlist hoặc soi được layout là đọc được mã.

## 4. Khối con nào nằm trên đường tới hạn

Đường tới hạn thật (`06_GDSII/sta/summary.txt`): `digit_valid` → `_131_/D`, slack **8,09 ns**,
arrival **1,78 ns**, **5 cell**. `_131_.Q = d0[0]` (netlist dòng 490–493).

| # | Cell | Khối con trong sơ đồ §1 | Delay (ns) | Ghi chú |
|---:|---|---|---:|---|
| 1 | `_076_ nand2_1` | GIẢI MÃ VỊ TRÍ | 0,04 | `nand2(digit_valid, _043_)` — `_043_` ≈ "state là WAIT_ST" |
| 2 | `_083_ nor3_1` | GIẢI MÃ VỊ TRÍ | **0,46** | `nor3(pos[1], pos[0], _045_)` → "pos==0 và đang nạp". **Cell đắt nhất đường này** (fanout 4, slew 0,59) |
| 3 | `_084_ mux2i_1` | BỘ ĐỆM MÃ NHẬP (đường nạp d0[0]) | 0,24 | `mux2i(A0=d0[0], A1=digit[0], S=_049_)` — chọn giữ hay nạp |
| 4 | `_085_ nor2_1` | chèn reset | 0,04 | `nor2(~rst_n, _050_)` |
| 5 | `_131_ dfxtp_1` | BỘ ĐỆM MÃ NHẬP | — | đích: `d0[0]` |

**Kết luận về đường tới hạn:** nó **không** đi qua bộ so sánh mã, cũng **không** qua lõi FSM.
Nó nằm trọn trong khối **giải mã vị trí → đường nạp `d0`**. Chi tiết lập luận ở `datapath.md` §4.

Bốn đường có cùng cấu trúc (`_132_`,`_133_`,`_134_` = `d0[1..3]`, slack 8,09) và bốn đường
tới `d3[0..3]` (`_143_`…`_146_`, slack 8,14) chỉ khác vài phần trăm — tức là
**toàn bộ 16 FF bộ đệm mã chia nhau nhóm đường chậm nhất**, đúng như sơ đồ dự đoán.

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
