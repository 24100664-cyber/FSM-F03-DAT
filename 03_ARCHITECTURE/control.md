# F03 · Phần điều khiển (Control)

F03 là mạch **tuần tự**, nên mục này mô tả khối điều khiển **thật**, không phải giải thích
vì sao vắng mặt.

---

## 1. Điều khiển gồm ba tầng lồng nhau

```
   ┌─────────────────────────────────────────────────────────────────┐
   │ TẦNG 3 — CHÍNH SÁCH BẢO MẬT   fails[1:0]  (2 FF)                │
   │   đếm số lần thử SAI LIÊN TIẾP; chạm 3 ⇒ ra lệnh khoá vĩnh viễn │
   └───────────────────────────┬─────────────────────────────────────┘
                               │ "fails==2 và lần này lại sai"
   ┌───────────────────────────▼─────────────────────────────────────┐
   │ TẦNG 2 — FSM GIAO DỊCH        state[2:0]  (3 FF)                │
   │   WAIT_ST → CHECK_ST → {UNLOCK_ST | WAIT_ST | LOCKED_ST}        │
   │   quyết định: khi nào nhận chữ số, khi nào đánh giá, khi nào mở │
   └───────────────────────────┬─────────────────────────────────────┘
                               │ "đang ở WAIT_ST, được phép nạp"
   ┌───────────────────────────▼─────────────────────────────────────┐
   │ TẦNG 1 — TUẦN TỰ HOÁ CHỮ SỐ    pos[1:0]  (2 FF)                 │
   │   con trỏ ghi 0→1→2→3→0; biến 4 sự kiện 1 chữ số thành 1 lần thử│
   └─────────────────────────────────────────────────────────────────┘
```

Ba tầng dùng **chung một clock, chung một reset**, và mỗi tầng chỉ cho phép tầng dưới hoạt
động. Đó là lý do một chữ số gửi lúc `state==LOCKED_ST` không làm gì cả: tầng 2 chặn tầng 1.

## 2. Bảng tín hiệu điều khiển và tác dụng

| Tín hiệu | Nguồn | Độ rộng | Tác dụng lên datapath | Hiện thực netlist |
|---|---|---:|---|---|
| `digit_valid` | cổng vào | 1 | Cho phép **toàn bộ** hoạt động nạp trong chu kỳ đó | `_075_ and2(digit_valid,_043_)`, `_076_ nand2(...)` |
| `state == WAIT_ST` | `state[2:0]` | 1 | Điều kiện **cần** để nạp bất kỳ chữ số nào | net `_043_` (vào `_075_`/`_076_`) |
| `en_d0…en_d3` | giải mã `pos` ∧ `digit_valid` ∧ `WAIT_ST` | 4 | Chọn **đúng một** trong 4 thanh ghi digit để ghi | `_083_ nor3` (en_d0), `_077_ and3`, `_101_ nand3b`, … |
| `pos` | 2 FF | 2 | Chọn đích ghi; đồng thời báo "chữ số thứ tư đã tới" khi `pos==3` | `_147_`,`_148_`, cộng `_118_ xnor2` |
| `match` (`_039_`) | comparator hằng số | 1 | Rẽ nhánh ở `CHECK_ST`: đúng → `UNLOCK_ST`, sai → nhánh đếm | `_070_ and4` |
| `fails == 2` | so sánh hằng | 1 | Rẽ nhánh sai: lần sai này là lần thứ ba ⇒ `LOCKED_ST` | `_125_ nand4(_032_, fails[0], _040_, _041_)` |
| `state == LOCKED_ST` | `state[2:0]` | 1 | **Đóng băng toàn bộ datapath** — chặn mọi nạp, mọi đếm | `_079_ nor3(..., locked)` |
| `rst_n` | cổng vào | 1 | Xoá đồng bộ cả 23 FF về giá trị khởi tạo | `_034_ = ~rst_n`, chèn trước mọi chân `D` |

## 3. Quan hệ điều khiển ↔ datapath

```
                       ĐIỀU KHIỂN                                    DATAPATH
   ┌──────────────────────────────────────┐            ┌──────────────────────────────┐
   │ state[2:0] ──┬──▶ "cho phép nạp?"    │──en_d0..3─▶│ mux2i × 16 → d0..d3 (16 FF)  │
   │              ├──▶ "đóng băng?"        │            │                              │
   │              └──▶ unlock / locked ───────────────▶ cổng ra (Moore)                │
   │ pos[1:0] ───────▶ "ghi vào ô nào?"   │            │                              │
   │ fails[1:0] ─────▶ "đã đủ 3 lần sai?" │            │                              │
   └───────▲──────────────────────────────┘            └────────────┬─────────────────┘
           │                                                        │
           └──────────────── match (1 bit) ◀────────── comparator hằng số (0 FF)
                        ► kênh phản hồi DUY NHẤT từ datapath lên điều khiển ◄
```

**Điểm cần nhấn mạnh khi dạy:** 16 bit dữ liệu người dùng đi vào, nhưng **chỉ 1 bit** (`match`)
được phép ảnh hưởng tới quyết định điều khiển. Việc nén 16 → 1 xảy ra hoàn toàn trong tổ hợp,
trong đúng 2 mức cổng. Đây là kiến trúc "datapath rộng – control hẹp" kinh điển, và là lý do
lõi FSM chỉ tốn **3 FF** dù phải quản lý một giao dịch 16 bit.

## 4. Giao thức bắt tay với tầng ngoài (contract)

| Nghĩa vụ | Bên chịu trách nhiệm | Hậu quả nếu vi phạm |
|---|---|---|
| `digit_valid` tích cực **đúng 1 chu kỳ** mỗi chữ số | **Tầng ngoài** | Giữ mức 2 chu kỳ ⇒ nạp 2 chữ số, mã lệch pha, người dùng không bao giờ mở được khoá |
| `digit[3:0]` ổn định trong chu kỳ `digit_valid=1` | Tầng ngoài | Nạp giá trị rác |
| Không phát `digit_valid` trong chu kỳ `CHECK_ST` | Tầng ngoài (hoặc chấp nhận mất chữ số) | Chữ số bị bỏ, lệch pha |
| **Không phát `digit_valid` trong chu kỳ `UNLOCK_ST`** | ⚠️ Tầng ngoài — **vì DUT hiện nuốt chữ số này** | Chữ số đầu của lần thử kế bị mất. Đây là khiếm khuyết đang mở, xem `05_VERIFICATION/known_issues.md` |
| Bắt `unlock` bằng **cạnh lên**, không bằng mức | Tầng ngoài | `unlock` chỉ có **1 chu kỳ** (INV-6); lấy mẫu bằng mức ở miền clock chậm hơn sẽ bỏ sót |
| Giữ `rst_n=0` ít nhất 1 chu kỳ clock đầy đủ | Tầng ngoài | Reset **đồng bộ** — không có cạnh clock thì không có reset |
| Đồng bộ hoá `digit_valid`/`digit` nếu đến từ miền clock khác | Tầng ngoài | Metastability |
| Cung cấp lối ra khỏi `LOCKED_ST` (nút reset có kiểm soát) | Tầng ngoài | Tủ khoá vĩnh viễn |

## 5. Những gì phần điều khiển này **không** làm

| Không làm | Vì sao | Hệ quả |
|---|---|---|
| Không có timeout giữa các chữ số | Charter mục 3: khoá theo thời gian **ngoài phạm vi** | Nhập nửa chừng rồi bỏ đi ⇒ `pos` đứng yên, người sau tiếp tục vào mã dở của người trước |
| Không tự mở khoá tạm sau T giây | Ngoài phạm vi | Phải reset bằng tay |
| Không báo lỗi riêng cho "sai lần 1" và "sai lần 2" | Charter mục 4 **có** đòi `uo_out[6:4]` = số lần sai, nhưng RTL **thiếu** cổng này | ⚠️ CHƯA THOẢ — xem cảnh báo đầu `02_SPECIFICATION/functional_spec.md` |
| Không xoá `pos`/`fails` ở nhánh `default` (mã trạng thái lạ) | RTL dòng 45 chỉ đặt `state<=WAIT_ST` | Sau một sự kiện SEU, khối trở lại hoạt động nhưng `pos` có thể lệch. Xem `fsm.md` §6 |

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
