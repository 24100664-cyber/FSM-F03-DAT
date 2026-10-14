# F03 · Đường dữ liệu (Datapath)

---

## 1. F03 có datapath thật, và nó **lớn hơn** phần điều khiển

Khác hẳn một mạch tổ hợp thuần, F03 chia rõ hai nửa:

```
   ┌──────────── DATAPATH (21/23 FF = 91 %) ─────────────┐   ┌─── CONTROL (2/23 FF… ──┐
   │  pos[1:0]  (2 FF)   ← đếm vị trí                    │   │  state[2:0] (3 FF)      │
   │  d0..d3    (16 FF)  ← bộ đệm mã nhập                │   │  fails[1:0] (2 FF)      │
   │  comparator hằng số (0 FF)                          │   │  → xem control.md       │
   └─────────────────────────────────────────────────────┘   └────────────────────────┘
```

Cách chia trên là chia **theo vai trò**, không phải theo cú pháp: `pos` và `d0..d3` mang dữ
liệu người dùng; `state` và `fails` mang quyết định. (Ghi chú: 16+2 = 18 FF là dữ liệu
thuần, `fails` 2 FF là "dữ liệu điều khiển", `state` 3 FF là điều khiển — tuỳ cách gom mà
tỉ lệ đổi chút ít; con số chắc chắn là **23 FF tổng**, `synth_stat.txt`.)

## 2. Bảng các đường dữ liệu

| Đường | Độ rộng | Từ | Đến | Bản chất |
|---|---:|---|---|---|
| `digit[3:0]` | 4 | cổng vào | 16 `mux2i_1` (chân `A1`) | Dữ liệu người dùng, lấy mẫu tại cạnh clock |
| `digit_valid` | 1 | cổng vào | `_075_ and2`, `_076_ nand2` | **Điều khiển**, nhưng là *startpoint của đường tới hạn* |
| `pos[1:0]` | 2 | `_147_/_148_` | giải mã load-enable + logic +1 | Con trỏ ghi — đường **hồi tiếp** |
| `en_d0..en_d3` | 4×1 | giải mã vị trí | chân `S` của 4 nhóm `mux2i_1` | Write-enable cho từng thanh ghi digit |
| `d0[3:0]` | 4 | `_131_…_134_` | `_068_ nor4b` + mux giữ | Chữ số thứ 1 |
| `d1[3:0]` | 4 | `_135_…_138_` | `_069_ nor4b` + mux giữ | Chữ số thứ 2 |
| `d2[3:0]` | 4 | `_139_…_142_` | `_066_ nor4bb` + mux giữ | Chữ số thứ 3 |
| `d3[3:0]` | 4 | `_143_…_146_` | `_067_ nor4b` + mux giữ | Chữ số thứ 4 |
| `match` (`_039_`) | 1 | `_070_ and4` | lõi FSM | **Kết quả so sánh 16 bit, nén còn 1 bit** |
| `~match` (`_040_`) | 1 | `_071_ nand4` | logic `fails` | Bản đảo, tool sinh riêng để tránh thêm inverter trên đường tới hạn |
| `fails[1:0]` | 2 | `_149_/_150_` | so với hằng 2, logic +1 | Bộ đếm sai liên tiếp |
| `state[2:0]` | 3 | `_128_…_130_` | khắp nơi + `unlock`/`locked` | Trạng thái điều khiển |
| `~rst_n` (`_034_`) | 1 | inverter | **cả 23 chân D** qua cổng chèn | Reset đồng bộ |

## 3. Đồ thị phụ thuộc và độ sâu logic

Vì F03 là mạch tuần tự, "độ sâu" phải tính **trong một chu kỳ**, tức là từ FF (hoặc cổng vào)
tới FF kế tiếp.

```
 ┌── nhóm đường IN→REG (đường chậm nhất của thiết kế) ──────────────────────┐
 │                                                                          │
 │  digit_valid ─▶ nand2/and2 ─▶ nor3/and3 ─▶ mux2i ─▶ nor2(reset) ─▶ FF    │
 │      (in)        mức 1         mức 2        mức 3      mức 4      d_i    │
 │  digit[i] ──────────────────────────────▶ mux2i ─▶ nor2 ────────▶ FF    │
 │                                  (chỉ 2 mức — nhanh hơn nhiều)           │
 └──────────────────────────────────────────────────────────────────────────┘

 ┌── nhóm đường REG→REG (so sánh mã) ───────────────────────────────────────┐
 │                                                                          │
 │  d0[3:0] ─┐                                                              │
 │  d1[3:0] ─┼─▶ 4× nor4b/nor4bb ─▶ and4 ─▶ logic FSM ─▶ nor/o2111a ─▶ FF  │
 │  d2[3:0] ─┤      mức 1            mức 2     mức 3        mức 4    state  │
 │  d3[3:0] ─┘                                                              │
 │  ► 16 bit nén còn 1 bit chỉ trong 2 mức cổng — rất rẻ ◄                  │
 └──────────────────────────────────────────────────────────────────────────┘

 ┌── nhóm đường REG→REG (con trỏ vị trí) ───────────────────────────────────┐
 │  pos[1:0] ─▶ xnor2(_118_) ─▶ nor2(_119_) ─▶ FF pos                      │
 │              mức 1            mức 2                                      │
 │  ► bộ đếm 2 bit: nông nhất thiết kế ◄                                    │
 └──────────────────────────────────────────────────────────────────────────┘

 ┌── nhóm đường REG→OUT ────────────────────────────────────────────────────┐
 │  state[2:0] ─▶ giải mã 1 mức ─▶ unlock / locked                          │
 │  ► Moore: 1 mức cổng, không có đầu vào nào chen vào ◄                    │
 └──────────────────────────────────────────────────────────────────────────┘
```

| Nhóm đường | Độ sâu (số cell) | Arrival đo được | Nguồn |
|---|:-:|---:|---|
| `digit_valid` → `d0[0..3]` | 5 | **1,78 ns** | `sta/timing_report_max.txt` path 1–4 |
| `digit_valid` → `d3[0..3]` | 5 | 1,73 ns | path 5–8 |
| `digit_valid` → `state[0]` | 5 | 1,65 ns | path 9 |
| `digit_valid` → `d2[0]` | 5 | 1,64 ns | path 10 |
| `pos` → `pos` | 3 | ⬜ không nằm trong 10 đường chậm nhất được in | — |
| `d0..d3` → `state` (so sánh) | ~5 | ⬜ không nằm trong 10 đường chậm nhất được in | — |

## 4. Dự đoán đường tới hạn từ RTL — rồi đối chiếu với STA thật

**Dự đoán khi mới đọc RTL:** đường chậm nhất *nên là* đường so sánh 16 bit
`d0..d3 → match → quyết định LOCKED/UNLOCK → state`, vì nó gom 16 bit và đi qua nhiều mức
logic quyết định nhất.

**STA thật nói khác:**

```
Startpoint: digit_valid (input port clocked by clk)
Endpoint:   _131_ (rising edge-triggered flip-flop)     ← _131_.Q = d0[0]
data arrival time 1.78 ns      slack 8.09 (MET)
```

**Lệch. Vì sao?** Ba lý do, đọc được từ chính báo cáo:

1. **So sánh với hằng số rẻ hơn nhiều so với so sánh hai biến.** 16 bit so với hằng
   `0001_0010_0011_0100` chỉ cần **4 cổng 4-đầu-vào + 1 AND4** (`_066_`…`_070_`), tức **2 mức**.
   Nếu mã bí mật nằm trong thanh ghi thì phải là 16 XNOR + cây AND ⇒ ít nhất 4–5 mức. Việc
   để `SECRET` ở `parameter` đã **tự động rút ngắn đường so sánh**.

2. **Đường `digit_valid → d_i` có thêm `1,00 ns` input delay.** SDC đặt
   `set_input_delay 1.0 -clock clk [all_inputs]` (`design.sdc`). Trong 1,78 ns arrival thì
   **1,00 ns là giả định biên IO**, chỉ **0,78 ns** là logic thật. Đường REG→REG không chịu
   khoản này. Đây là lý do một đường chỉ-4-cổng lại thắng đường 5-cổng bên trong.

3. **Cell `_083_ nor3_1` tốn 0,46 ns trên tổng 0,78 ns logic** — hơn nửa. Nó có
   fanout 4 và output slew 0,59 ns. Đây là cổng giải mã `pos==0`, lái đồng thời 4 mux của
   `d0[3:0]`. Nút thắt thật là **fanout của tín hiệu load-enable**, không phải độ sâu logic.

> **Bài học rút ra:** đọc RTL cho ta *giả thuyết*; STA cho ta *sự thật*. Khi lệch, phải tìm
> cho ra cơ chế gây lệch — ở đây là (a) hằng-số-hoá làm comparator co lại, (b) input delay
> 1 ns đánh thuế mọi đường IN→REG, (c) fanout chứ không phải độ sâu.

**Cảnh báo bắt buộc kèm mọi con số trên:** `10,0 ns` và `1,0 ns` là **giả định khởi điểm**
trong `design.sdc`, không phải yêu cầu hệ thống. Slack 8,09 ns **không** cho phép kết luận
"F03 chạy được ở 100 MHz" hay "chạy được ở 550 MHz". Muốn biết tần số thật phải chạy STA
sau routing, nhiều góc PVT (`06_GDSII/sta/README.md`, `02_SPECIFICATION/timing.md` §3).

## 5. Chi phí datapath: 16 FF cho bộ đệm mã — **có cần không?**

Đây là điểm đánh đổi lớn nhất của F03, và là lý do số FF thật (23) vượt xa ước lượng của
Charter mục 10 ("2 + 3 + 1–2 ≈ **6–8 ô nhớ**").

| Cách làm | FF cần | Cơ chế |
|---|---:|---|
| **Cách hiện tại**: lưu cả 4 chữ số rồi so một lượt ở `CHECK_ST` | 3 + 2 + 2 + **16** = **23** | `d0..d3` giữ mã người dùng đến hết lần thử |
| **So từng chữ số ngay khi nhập** (streaming compare) | 3 + 2 + 2 + **1** = **8** | Mỗi lần nạp, so `digit` với `SECRET[pos]` (mux 4→1 của hằng số), gộp vào 1 bit `ok_so_far` |

Chênh **15 flip-flop ≈ 65 % tổng số FF của thiết kế**. Với công suất tuần tự chiếm
**91,4 %** tổng công suất (`power/power_report.txt`), đây cũng là khoản chi công suất lớn nhất.

Ba lý do **giữ** cách hiện tại dù tốn hơn:

1. **Dạy được nhiều hơn.** Bộ đệm + comparator hằng số cho sinh viên thấy tận mắt hiện
   tượng constant-folding trong netlist (`block_diagram.md` §3) — điều mà bản streaming
   giấu mất.
2. **An toàn hơn trước tấn công thời gian (timing attack).** Bản streaming *có thể* bị cám
   dỗ thoát sớm khi chữ số đầu đã sai ⇒ rò rỉ thông tin qua thời gian phản hồi. Bản hiện
   tại luôn mất đúng 2 chu kỳ sau chữ số thứ tư, bất kể sai ở đâu.
3. **Mở đường cho tính năng ngoài phạm vi.** Nếu sau này cho phép "đổi mã lúc chạy"
   (Charter mục 3 liệt ngoài phạm vi), bộ đệm 16 bit là chỗ đã sẵn sàng.

Đổi lại phải ghi rõ: **thiết kế hiện tại vượt ước lượng ô nhớ của Charter mục 10 gần 3 lần,
và đó là lựa chọn có ý thức chứ không phải sơ suất** — miễn là người làm nêu được lý do.
Xem thêm `tradeoff.md` §3.

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
