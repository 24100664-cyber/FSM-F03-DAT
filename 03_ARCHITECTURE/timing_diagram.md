# F03 · Giản đồ thời gian (Timing Diagram)

F03 là mạch **tuần tự** ⇒ mục này vẽ **dạng sóng theo chu kỳ clock**, không vẽ giản đồ lan
truyền tổ hợp.

---

## 1. Giao dịch điển hình — nhập đúng mã và mở khoá

Mốc thời gian lấy đúng theo testbench `f03_tb.sv` (chu kỳ 10 ns, `always #5 clk=~clk`, cạnh
lên ở t = 5, 15, 25, …). Ký hiệu `↑` = cạnh lên clock.

```
 chu kỳ    │  C0    C1    C2    C3    C4    C5    C6    C7    C8    C9   C10
 t (ns)    │   5    15    25    35    45    55    65    75    85    95   105
           │   ↑     ↑     ↑     ↑     ↑     ↑     ↑     ↑     ↑     ↑     ↑
           │
 clk       │ ─┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
           │  └─┘   └─┘   └─┘   └─┘   └─┘   └─┘   └─┘   └─┘   └─┘   └─┘   └─
           │
 rst_n     │ ──────┐ ┌─────────────────────────────────────────────────────
           │       └─┘  (nhả ở C1)
           │
 digit_val │ ________╱‾‾‾╲_____╱‾‾‾╲_____╱‾‾‾╲_____╱‾‾‾╲_________________
           │         C2        C4        C6        C8
           │
 digit     │ ──0────┤ 1 ├─0──┤ 2 ├─0──┤ 3 ├─0──┤ 4 ├──0──────────────────
           │
 state     │ WAIT  WAIT  WAIT  WAIT  WAIT  WAIT  WAIT  WAIT  WAIT CHECK UNLK
           │                                                       ▲     ▲
           │                             lấy mẫu d3 ở C8 ──────────┘     │
           │                             so sánh ở C9 ────────────────────┘
 pos       │  0     0     0 ──▶ 1 ───────▶ 2 ───────▶ 3 ───────▶ 0    0
           │              (C2)        (C4)        (C6)       (C8)
           │
 d0        │  0     0     0     1     1     1     1     1     1     1     1
 d1        │  0     0     0     0     0     2     2     2     2     2     2
 d2        │  0     0     0     0     0     0     0     3     3     3     3
 d3        │  0     0     0     0     0     0     0     0     0     4     4
           │
 fails     │  0     0     0     0     0     0     0     0     0     0     0
           │
 unlock    │ ______________________________________________________╱‾‾‾╲___
           │                                                    C10 ▲   ▲
 locked    │ ____________________________________________________________
```

**Đọc giản đồ:**

| Quan sát | Ý nghĩa |
|---|---|
| `pos` đổi **sau** cạnh lên có `digit_valid=1` | Logic đồng bộ: giá trị mới hiện ra ở chu kỳ kế |
| `state` sang `CHECK_ST` ở C9, **không** ở C8 | Cạnh C8 nạp `d3` *đồng thời* chuyển trạng thái; kết quả nhìn thấy được từ C9 |
| `unlock` lên ở C10, xuống ở C11 | **Đúng 1 chu kỳ** — INV-6. Đây là lý do tầng ngoài phải bắt bằng cạnh |
| Giữa mỗi chữ số có 1 chu kỳ `digit_valid=0` | Do testbench (dòng 20–21) chèn chu kỳ nghỉ. **F03 không đòi hỏi chu kỳ nghỉ này** — xem ca C-6 ở `corner_cases.md` §2 |
| Tổng độ trễ chữ số-cuối → `unlock` | **2 chu kỳ** (C8 → C10) |

## 2. Giao dịch vào khoá tạm — sai ba lần liên tiếp

Rút gọn: mỗi "lần thử" = 4 sự kiện chữ số + 1 chu kỳ `CHECK_ST`.

```
 lần thử   │   #1 (sai)          #2 (sai)          #3 (sai)
           │ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐
 state     │ W…W CHK  W…W      W…W CHK  W…W      W…W CHK  LOCKED LOCKED LOCKED…
           │      ▲                ▲                ▲      ▲
 fails     │  0 ──┴─▶ 1 ───────────┴─▶ 2 ──────────┴─▶ 3 ──┴──▶ 3 (đóng băng)
           │
 locked    │ ____________________________________________╱‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
           │                                              ▲ lên và GIỮ MÃI
 unlock    │ ______________________________________________________________
           │
 digit_val │ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~╱‾╲__╱‾╲__
           │                                                  ▲   ▲
           │                            mọi chữ số từ đây bị BỎ QUA hoàn toàn:
           │                            pos, fails, d0..d3 đều đóng băng (INV-7)
```

Lối ra duy nhất:

```
 rst_n     │ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾┐     ┌‾‾‾‾‾‾‾‾‾‾‾‾‾
           │                      └──↑──┘
 state     │ LOCKED LOCKED LOCKED │ WAIT WAIT …
 locked    │ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾┐
           │                       └_____________
           │  ► reset ĐỒNG BỘ: phải có ít nhất 1 cạnh lên clock trong lúc rst_n=0 ◄
```

## 3. Giản đồ của **ca gây lỗi mô phỏng** — chữ số bị nuốt ở `UNLOCK_ST`

Đây là giản đồ quan trọng nhất trong hồ sơ này. Mốc t lấy đúng từ `simulation.log`
(`$fatal` tại **t = 176**).

```
 t (ns)    │  85    95   105   115   125   135   145   155   165   175  (176)
 sự kiện   │  d4↑  CHK  9(1)  idle  9(2)  idle  9(3)  idle  9(4)  idle  assert
           │
 digit_val │ ╱‾‾╲__________╱‾‾╲______╱‾‾╲______╱‾‾╲______╱‾‾╲__________
 digit     │ ┤4├────────── ┤9├────── ┤9├────── ┤9├────── ┤9├──────────
           │
 state     │ WAIT CHECK UNLOCK WAIT  WAIT  WAIT  WAIT  WAIT  WAIT  WAIT
           │              ▲▲▲
           │              ││└── chữ số '9' thứ nhất tới ĐÚNG lúc này
           │              │└─── RTL: `UNLOCK_ST: state<=WAIT_ST;` — KHÔNG có nhánh nạp
           │              └──── ⇒ chữ số bị NUỐT, pos giữ nguyên 0
           │
 pos       │  0 ──▶ 0     0     0 ──▶ 1 ──▶ 1 ──▶ 2 ──▶ 2 ──▶ 3 ──▶ 3
           │                    ▲           ▲           ▲
           │              chỉ nạp được 3 chữ số '9' → pos dừng ở 3, KHÔNG về 0
           │
 d0/d1/d2  │  1,2,3 ───────────────────▶ 9 ────▶ 9 ────▶ 9
 d3        │   4 ────────────────────────────────────────── 4 (CŨ, chưa bị ghi đè)
           │
 fails     │  0 ───────────────────────────────────────────────────── 0
           │                                                           ▲
           │                        testbench dòng 41: assert(fail_count==1)
           │                        thực tế = 0  ⇒  $fatal "failure count 1 missing"
```

**Phân tích 3 dòng:** chữ số thứ tư của lần thử sai **chưa bao giờ được nạp**, nên
`pos` chưa quay về 0, nên `CHECK_ST` **chưa bao giờ được vào lần hai**, nên `fails` **chưa
bao giờ tăng**. Testbench kiểm `fail_count==1` và thấy 0. Phán xử đầy đủ kèm bản vá:
`05_VERIFICATION/known_issues.md`.

## 4. ⚠️ Waveform này là mô phỏng **hành vi (zero-delay)**

| Điều giản đồ trên **có** minh hoạ | Điều giản đồ trên **KHÔNG** minh hoạ |
|---|---|
| Quan hệ nhân quả giữa các chu kỳ | Độ trễ clock-to-Q thật của `dfxtp_1` |
| Số chu kỳ độ trễ (2 chu kỳ tới `unlock`) | Thời gian lan truyền tổ hợp (thật: **1,78 ns** arrival, `sta/timing_report_max.txt`) |
| Thứ tự và điều kiện chuyển trạng thái | Glitch trên `unlock` khi 3 bit `state` đổi lệch nhau |
| Chỗ testbench đứt | Vi phạm setup/hold |
| | Hiệu ứng clock skew (chưa có CTS — `06_GDSII/cts/README.md`: ⬜ chưa chạy) |

Icarus Verilog mô phỏng ở mức hành vi với mọi cổng có độ trễ bằng 0, nên mọi tín hiệu trên
giản đồ đổi **đúng tại** cạnh clock. Trong silicon thật, `state` đổi sau ~0,35 ns kể từ cạnh
clock và `unlock` đổi sau đó thêm một mức cổng nữa. Muốn thấy đúng phải chạy tầng **L5 —
post-layout có back-annotate SDF** (`05_VERIFICATION/testplan.md`: ⬜ chưa chạy).

**Con số thời gian duy nhất đáng tin trong hồ sơ này là của OpenSTA**, và nó nói về đường
`digit_valid → d0[0]`, không nói gì về `unlock`.

## 5. Hai ràng buộc thời gian tầng ngoài phải tôn trọng

```
 ĐÚNG — xung 1 chu kỳ:             SAI — giữ mức nhiều chu kỳ:
 digit_valid ___╱‾‾‾╲_______        digit_valid ___╱‾‾‾‾‾‾‾‾‾‾‾╲___
 digit       ───┤ 7 ├───────        digit       ───┤     7     ├───
 → nạp 1 chữ số '7'                 → nạp 7 BA LẦN, pos nhảy 0→3
                                    → mã người dùng bị hỏng hoàn toàn
```

```
 ĐÚNG — bắt unlock bằng cạnh:      SAI — lấy mẫu bằng mức ở clock chậm:
 unlock  ______╱‾‾╲______           unlock  ______╱‾‾╲______
 clk_sys ┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌            clk_sys ──┐      ┌──┐
         └─┘└─┘└─┘└─┘└─             (chậm hơn)└──────┘  └───
 → bắt được                         → có thể bỏ sót hoàn toàn
```

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
