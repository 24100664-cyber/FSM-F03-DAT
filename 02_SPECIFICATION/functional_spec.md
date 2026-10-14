# F03 · Đặc tả chức năng (Functional Specification)

> ## ⚠️ CẢNH BÁO — RTL CHƯA THOẢ CHARTER MỤC 4
>
> **Trạng thái: CHƯA THOẢ.** Không tự sửa RTL; cần thầy duyệt trước khi thay đổi.
>
> Charter mục 4 yêu cầu ánh xạ chân:
> `ui_in[3:0]`=chữ số · `ui_in[4]`=xác nhận · `uo_out[0]`=mở khoá · `uo_out[1]`=khoá tạm ·
> **`uo_out[3:2]`=vị trí đang nhập** · **`uo_out[6:4]`=số lần sai** (7 bit ra).
>
> Module tổng hợp thật (`f03_lock_scaffold_explicit`, xem `06_GDSII/synthesis/synth_stat.txt`)
> chỉ có **2 bit ra**: `unlock`, `locked`. Đối chiếu:
>
> | Charter mục 4 đòi | Có trong `f03_lock_scaffold_explicit`? | Bằng chứng |
> |---|---|---|
> | chữ số 4 bit vào | ✅ `digit[3:0]` | RTL dòng 11 |
> | xác nhận chữ số | ✅ `digit_valid` | RTL dòng 11 |
> | mở khoá | ✅ `unlock` | RTL dòng 50 |
> | khoá tạm | ✅ `locked` | RTL dòng 51 |
> | **vị trí đang nhập (2 bit ra)** | ❌ **THIẾU** — `pos` là tín hiệu nội bộ, không đưa ra chân | RTL dòng 17 |
> | **số lần sai (3 bit ra)** | ❌ **THIẾU** — `fails` là tín hiệu nội bộ, không đưa ra chân | RTL dòng 17 |
> | wrapper Tiny Tapeout (`ui_in`/`uo_out`) | ❌ **THIẾU** — không có module wrapper nào trong `04_IMPLEMENTATION/rtl/` | liệt kê thư mục |
>
> Module thứ hai `f03_lock_scaffold` **có** `position[1:0]` và `fail_count[1:0]`, nhưng:
> (a) nó **không** phải top tổng hợp, (b) `fail_count` chỉ **2 bit** trong khi Charter đòi
> **3 bit** (`uo_out[6:4]`). Chính RTL cũng tự khai báo ở đầu file:
> *"IMPORTANT: not an official F03 interface"* (dòng 2) và *"Not an official F03 interface"*
> (`f03_lock_scaffold_explicit.sv` dòng 2).
>
> **Hệ quả trên hồ sơ:** REQ-F03-002 (giao diện đúng Charter mục 4) **KHÔNG ĐẠT**. Mọi số
> liệu diện tích/công suất trong hồ sơ là của phiên bản **thiếu 5 bit ra**; thêm đủ 5 bit ra
> sẽ làm tăng số chân và có thể tăng diện tích.
>
> **Cảnh báo thứ hai — bằng chứng mô phỏng không phủ module đã tổng hợp.**
> Testbench `f03_tb.sv` dòng 7 khởi tạo `f03_lock_scaffold`, còn Yosys tổng hợp
> `f03_lock_scaffold_explicit`. Hai module khác nhau về cổng và khác nhau về một chi tiết
> hành vi (xem §7). Vì vậy: **mô phỏng chứng minh cho module A, số liệu vật lý nói về
> module B.** Đây là lỗ hổng truy vết phải vá trước khi dùng hồ sơ để chấm.

---

## 1. Bài toán ở mức hành vi

F03 là một **bộ nhận dạng mật khẩu bốn chữ số có cơ chế chống dò (anti-bruteforce)**.
Khối nhận từng chữ số một qua giao diện bắt tay 1 bit (`digit_valid`), gom đủ bốn chữ số
thành một *lần thử*, so với mã bí mật, và quản lý một bộ đếm **số lần sai liên tiếp**. Khi
bộ đếm chạm ngưỡng 3, khối vào trạng thái **khoá tạm (lockout)** — trạng thái hấp thụ, chỉ
thoát được bằng `rst_n`.

Hai mức thời gian phải tách bạch:

| Mức | Đơn vị | Sự kiện |
|---|---|---|
| Mức **chữ số** | 1 chu kỳ có `digit_valid=1` | nạp một chữ số, tăng `pos` |
| Mức **lần thử** | 4 sự kiện chữ số + 1 chu kỳ đánh giá | so mã, cập nhật `fails` |

## 2. Định nghĩa chính xác từng đầu ra

Ký hiệu: `S` = thanh ghi trạng thái, `pos` = vị trí đang nhập (2 bit), `fails` = số lần sai
liên tiếp (2 bit), `d0..d3` = bốn chữ số đã nạp, `SECRET0..3` = tham số hằng (mặc định 1,2,3,4).

```
unlock = (S == UNLOCK_ST)
locked = (S == LOCKED_ST)
```

Cả hai đầu ra **chỉ phụ thuộc thanh ghi trạng thái**, không phụ thuộc `digit`/`digit_valid`
trong cùng chu kỳ ⇒ đây là FSM **Moore** (bằng chứng đầy đủ ở `03_ARCHITECTURE/fsm.md` §3).

| Đầu ra | Giá trị | Ý nghĩa hợp đồng |
|---|---|---|
| `unlock` | 1 trong **đúng 1 chu kỳ** sau khi lần thử thứ N đúng | xung mở khoá, tầng ngoài phải bắt bằng cạnh |
| `unlock` | 0 mọi lúc khác | |
| `locked` | 1 **vĩnh viễn** từ chu kỳ vào `LOCKED_ST` tới khi `rst_n=0` | mức, không phải xung |

## 3. Ràng buộc cấu trúc bắt buộc

Tên đề chỉ định **FSM**. Do đó RTL **bắt buộc** mô tả tường minh:

| Ràng buộc | Vì sao bắt buộc | RTL có tuân? |
|---|---|---|
| Có thanh ghi trạng thái tường minh, kiểu liệt kê | "FSM" là hợp đồng kiến trúc, không phải chỉ hành vi | ✅ `typedef enum logic [2:0] {...} state_t;` dòng 14–16 |
| Có nhánh `default` xử lý mã trạng thái bất hợp lệ | 3 bit mã hoá 4 trạng thái ⇒ 4 mã thừa | ✅ dòng 45 `default: state<=WAIT_ST;` |
| Trạng thái khoá tạm là **trạng thái hấp thụ** | Charter mục 1: "khoá tạm sau ba lần sai" | ✅ dòng 44 `LOCKED_ST: state<=LOCKED_ST;` |
| Bộ đếm sai phải **xoá khi nhập đúng** | Charter mục 10 nêu đây là chỗ hay tắc | ✅ dòng 36 `fails<=0;` trong nhánh đúng |
| Không dùng `always_latch`, không suy ra latch | mạch đồng bộ | ✅ chỉ có 1 `always_ff`, netlist 0 latch |

## 4. Bảng hành vi mức lần thử

Gọi `try` là lần thử vừa hoàn tất (4 chữ số đã nạp), `F` là giá trị `fails` **trước** khi
đánh giá lần thử đó.

| `try == SECRET`? | `F` | `fails` sau | Trạng thái kế | `unlock` | `locked` |
|:-:|:-:|:-:|---|:-:|:-:|
| đúng | bất kỳ | 0 | `UNLOCK_ST` | 1 (1 chu kỳ) | 0 |
| sai | 0 | 1 | `WAIT_ST` | 0 | 0 |
| sai | 1 | 2 | `WAIT_ST` | 0 | 0 |
| sai | 2 | 3 | `LOCKED_ST` | 0 | **1 vĩnh viễn** |
| — | 3 | 3 | `LOCKED_ST` | 0 | 1 |

Đọc trực tiếp từ `f03_lock_scaffold_explicit.sv` dòng 34–42.

## 5. Độ trễ đầu vào → đầu ra (tính bằng chu kỳ)

Giả định `digit_valid` tích cực đúng 1 chu kỳ cho mỗi chữ số.

```
chu kỳ  k    : nạp d0 (pos 0→1)
chu kỳ  k+a  : nạp d1 (pos 1→2)        a,b,c ≥ 1 tuỳ nhịp tầng ngoài
chu kỳ  k+b  : nạp d2 (pos 2→3)
chu kỳ  k+c  : nạp d3 (pos 3→0), S: WAIT_ST → CHECK_ST
chu kỳ  k+c+1: S = CHECK_ST, đánh giá
chu kỳ  k+c+2: S = UNLOCK_ST (unlock=1) HOẶC WAIT_ST HOẶC LOCKED_ST (locked=1)
```

**Độ trễ chốt: 2 chu kỳ** từ cạnh nạp chữ số thứ tư tới cạnh `unlock`/`locked` tích cực.
Một chu kỳ dành cho `CHECK_ST` (so sánh), một chu kỳ để đầu ra Moore hiện ra.

## 6. Tính chất bất biến (invariants)

Đánh số để dùng trực tiếp làm assertion SVA.

| ID | Phát biểu | Dùng làm |
|---|---|---|
| **INV-1** | `!(unlock && locked)` — hai đầu ra loại trừ nhau ở mọi chu kỳ | assert tức thời |
| **INV-2** | `locked` một khi lên 1 thì giữ 1 cho tới khi `rst_n==0`; không có đường nào từ `LOCKED_ST` ra ngoài trừ reset | assert `$rose(locked) |-> locked throughout (rst_n)` |
| **INV-3** | `pos` luôn ∈ {0,1,2,3} và tăng đúng 1 (mod 4) mỗi sự kiện `digit_valid` được chấp nhận | assert trên `pos` |
| **INV-4** | `fails ≤ 3` ở mọi chu kỳ | assert `fails <= 2'd3` |
| **INV-5** | Một lần thử **đúng** luôn đặt `fails` về 0 ⇒ ngưỡng đếm là "sai **liên tiếp**", không phải "sai tổng cộng" | assert `unlock |-> $past(fails_next)==0`; đây chính là bằng chứng cho Charter mục 2 câu 3 |
| **INV-6** | `unlock` tích cực **đúng 1 chu kỳ** mỗi lần mở khoá (`UNLOCK_ST` luôn chuyển đi ngay chu kỳ sau) | assert `unlock |=> !unlock` |
| **INV-7** | Ở `LOCKED_ST`, `digit_valid` không làm thay đổi bất kỳ thanh ghi nào (`d0..d3`, `pos`, `fails` đóng băng) | assert `locked |=> $stable({d0,d1,d2,d3,pos,fails})` |
| **INV-8** | Sau `rst_n` xuống rồi lên: `S=WAIT_ST`, `pos=0`, `fails=0`, `d0..d3=0` | assert sau reset |
| **INV-9** | Mã bí mật **không** nằm trong thanh ghi: số flip-flop = 3 (state) + 16 (d0..d3) + 2 (pos) + 2 (fails) = **23**, khớp đúng với `synth_stat.txt` | kiểm cấu trúc, không phải assertion |

## 7. Điều kiện biên và hành vi không xác định

| Ca biên | Hành vi đặc tả | Hành vi RTL thật | Nhận xét |
|---|---|---|---|
| `digit_valid` giữ 1 nhiều chu kỳ liên tiếp | Mỗi **chu kỳ** nạp một chữ số mới | Đúng như vậy — không có phát hiện cạnh | Hợp đồng tầng ngoài: phải tạo xung 1 chu kỳ/chữ số. Đây là nguồn lỗi tích hợp rất hay gặp. |
| `digit_valid=1` khi `S=CHECK_ST` | Chữ số bị bỏ qua (đang đánh giá) | Bỏ qua — `CHECK_ST` không có nhánh nạp | Chấp nhận được, phải ghi vào hợp đồng |
| **`digit_valid=1` khi `S=UNLOCK_ST`** | Đặc tả *mong muốn*: chữ số này là chữ số đầu của lần thử kế tiếp, phải được nạp | **RTL BỎ QUA chữ số này** (dòng 43: `UNLOCK_ST: state<=WAIT_ST;` — không có nhánh nạp) | ⚠️ **KHIẾM KHUYẾT** — đây chính là nguyên nhân mô phỏng FAIL. Xem `05_VERIFICATION/known_issues.md` |
| `digit_valid=1` khi `S=LOCKED_ST` | Bỏ qua hoàn toàn | Bỏ qua ✅ | Đúng ý đồ chống dò |
| `S` mang mã 3'd4…3'd7 (SEU, khởi động lạ) | Quay về `WAIT_ST` | ✅ `default` dòng 45 | Nhưng `pos`/`fails` **không** bị xoá trong nhánh này |
| `rst_n` bất đồng bộ với `clk` | Không đặc tả | RTL dùng reset **đồng bộ** (`if(!rst_n)` bên trong `always_ff @(posedge clk)`) | Tầng ngoài phải giữ `rst_n=0` ≥ 1 chu kỳ đầy đủ |
| `digit` mang `X`/`Z` | Không đặc tả | `d_i` sẽ mang `X`, so sánh cho `X` | Nghĩa vụ tầng ngoài (xem `interface.md` §4) |

## 8. Những gì đặc tả này **không** ràng buộc

- Giá trị mã bí mật: là **tham số** `SECRET0..3`, mặc định (1,2,3,4) — chỉ là mặc định của
  mentor, không phải giá trị chính thức của đề (ghi rõ trong `reference_model.py` dòng 56).
- Thời gian khoá tạm: Charter mục 3 liệt "khoá theo thời gian" vào **ngoài phạm vi**; ở đây
  khoá là vĩnh viễn-cho-tới-reset.
- Đổi mã lúc chạy, nhiều người dùng, lưu mã bền vững: **ngoài phạm vi** (Charter mục 3).

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
