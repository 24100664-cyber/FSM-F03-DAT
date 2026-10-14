# F03 · Ca biên và lý do chọn (Corner Cases)

Mọi ca dưới đây đã đối chiếu với testbench thật `05_VERIFICATION/testbench/f03_tb.sv`
(61 dòng) và mô hình chuẩn `05_VERIFICATION/golden_model/reference_model.py` (59 dòng).

---

## 1. Ca bắt buộc của Charter mục 8 — và **vì sao** từng ca tồn tại

| # | Ca Charter | Lý do kỹ thuật (ca này bắt lỗi gì) | Có trong TB? | Dòng TB | Kết quả thật |
|---|---|---|:-:|---|---|
| C-1 | **Nhập đúng ngay** | Phủ đường `WAIT_ST → CHECK_ST → UNLOCK_ST`. Bắt lỗi so sánh sai chiều bit, bắt lỗi quên chuyển sang `CHECK_ST` ở `pos==3`. | ✅ | 36–38 | ✅ qua (không `$fatal`) |
| C-2 | **Sai một lần rồi đúng** | Ca **quyết định** để phân biệt "sai liên tiếp" với "sai tổng cộng". Nếu thiếu lệnh `fails<=0` ở nhánh đúng, ca này vẫn qua nhưng ca C-2' (§2) sẽ vỡ. | ✅ | 40–44 | ❌ **dừng ở dòng 41** — xem `known_issues.md` |
| C-3 | **Sai ba lần liên tiếp → khoá tạm** | Phủ nhánh `fails==2 → LOCKED_ST`. Bắt lỗi off-by-one ngưỡng (khoá ở lần 2 hoặc lần 4). | ✅ | 46–49 | ⬜ chưa chạy tới (TB đã `$fatal` ở dòng 41) |
| C-4 | **Reset để thoát khoá tạm** | Chứng minh `LOCKED_ST` là trạng thái **hấp thụ** và reset là lối ra **duy nhất** (INV-2). | ✅ | 54–57 | ⬜ chưa chạy tới |

> ⚠️ Vì testbench dừng ở dòng 41, **ba trên bốn ca bắt buộc chưa có bằng chứng thực thi**.
> `test_matrix.csv` ghi TC-001/TC-002 là "XEM known_issues.md" — đúng, không được đọc thành PASS.

## 2. Ca tự xây dựng bổ sung (yêu cầu ≥ 2, phải có ca biên)

| # | Ca | Kích thích | Kỳ vọng | Bắt lỗi gì | Đã có trong TB? |
|---|---|---|---|---|:-:|
| **C-2'** | **Sai 2 → đúng → sai 2** | `9999, 9999, 1234, 9999, 9999` | **không** khoá; `fails` cuối = 2 | Đây là ca duy nhất phân biệt tuyệt đối "3 lần liên tiếp" với "3 lần tổng cộng". Tổng cộng đã sai 4 lần mà vẫn không được khoá. | ❌ **THIẾU** |
| **C-5 (biên)** | **Nhập chữ số ngay trong chu kỳ `UNLOCK_ST`** | mở khoá xong, `digit_valid=1` ở đúng chu kỳ `unlock=1` | chữ số phải được nạp làm `d0` của lần thử kế | Bắt đúng khiếm khuyết đã phát hiện (xem `known_issues.md`). TB hiện chạm phải ca này **một cách vô tình** ở dòng 40 và vì thế mới FAIL. | ⚠️ chạm phải, nhưng không có assertion mô tả đúng ý đồ |
| **C-6 (biên)** | **`digit_valid` giữ mức 1 suốt 4 chu kỳ** | `digit_valid` = 1 liên tục, `digit` đổi mỗi chu kỳ | nạp 4 chữ số trong 4 chu kỳ liên tiếp, không cần khoảng nghỉ | Bắt giả định sai "phải có chu kỳ nghỉ giữa hai chữ số". TB hiện **luôn** chèn 1 chu kỳ nghỉ (`f03_tb.sv` dòng 20–21), nên vùng hành vi này hoàn toàn chưa được thử. | ❌ **THIẾU** |
| **C-7 (biên)** | **`digit_valid` trong chu kỳ `CHECK_ST`** | phát chữ số đúng vào chu kỳ đánh giá | chữ số bị bỏ qua (theo `functional_spec.md` §7) | Chốt hợp đồng "được phép mất chữ số ở `CHECK_ST`" thành điều đã kiểm, không phải điều ngầm hiểu. | ❌ **THIẾU** |
| **C-8 (biên)** | **Mã sai ở đúng **một** vị trí** | `1235` (chỉ `d3` sai) | phải bị tính là SAI | Bắt lỗi comparator bỏ sót một digit. Với netlist hiện tại, mỗi digit có một cổng riêng (`_066_`…`_069_`) nên cần 4 biến thể: `2234`, `1334`, `1244`, `1235`. | ❌ **THIẾU** |
| **C-9** | **Mở khoá rồi lại nhập sai 3 lần** | `1234` → `9999`×3 | phải khoá được lần nữa | Chứng minh `UNLOCK_ST` không làm hỏng bộ đếm ở chiều ngược lại. | ❌ **THIẾU** |

## 3. Phân loại ca theo tiêu chí kỹ thuật riêng của F03

F03 là FSM có **hai bộ đếm lồng nhau** (`pos` mức chữ số, `fails` mức lần thử). Phân loại
ca theo *nhánh FSM được phủ* là cách duy nhất thấy được chỗ hở:

| Nhánh RTL (`f03_lock_scaffold_explicit.sv`) | Dòng | Ca phủ nó | Trạng thái phủ |
|---|---|---|---|
| `WAIT_ST`, `pos==0..2` — nạp không chuyển trạng thái | 28–30 | C-1 | ✅ |
| `WAIT_ST`, `pos==3` — nạp + `→CHECK_ST` | 31 | C-1 | ✅ |
| `CHECK_ST`, mã đúng | 35–36 | C-1 | ✅ |
| `CHECK_ST`, mã sai & `fails<2` | 39–40 | C-2 | ❌ chưa tới được (TB chết trước) |
| `CHECK_ST`, mã sai & `fails==2` | 37–38 | C-3 | ❌ chưa tới được |
| `UNLOCK_ST → WAIT_ST` | 43 | C-1 (đi qua), C-5 (kiểm đúng) | ⚠️ đi qua nhưng **không** kiểm |
| `LOCKED_ST` tự vòng | 44 | C-3, C-4 | ❌ chưa tới được |
| `default` (mã trạng thái 3'd4…3'd7) | 45 | — | ❌ **không thể phủ bằng mô phỏng chức năng** |

**Độ phủ nhánh FSM ước tính theo bằng chứng hiện có: 4/8 nhánh.** Con số này lấy từ việc
đọc mã và đọc `simulation.log`, **không** phải từ công cụ đo coverage — Icarus Verilog
trong gói này không chạy coverage.

Phân loại thứ hai, theo **số chu kỳ từ kích thích tới đầu ra**:

| Nhóm | Độ trễ | Ca |
|---|---|---|
| Không sinh đầu ra | 0 | C-6, C-7 (chữ số bị nuốt hoặc chỉ nạp) |
| Sinh đầu ra sau 2 chu kỳ | 2 | C-1, C-3 |
| Đầu ra mức, giữ vô hạn | ∞ | C-3, C-4 (`locked`) |

## 4. Ca **KHÔNG** áp dụng cho đề này — và vì sao

| Ca | Vì sao không áp dụng |
|---|---|
| Đổi mã bí mật lúc chạy | Charter mục 3 liệt vào **ngoài phạm vi**. Hơn nữa `SECRET0..3` là `parameter` → đã bị hằng-số-hoá vào *cực tính chân cổng* (xem `implementation-notes_F03.md` §6), không tồn tại đường ghi. |
| Khoá theo thời gian (tự mở sau T giây) | **Ngoài phạm vi** (Charter mục 3). Không có bộ đếm thời gian nào trong RTL — netlist không có thanh ghi nào ngoài 23 FF đã liệt kê. |
| Nhiều người dùng / nhiều mã | **Ngoài phạm vi** (Charter mục 3). |
| Ca tràn số của `fails` | Không tồn tại: `fails` 2 bit và `LOCKED_ST` hấp thụ ở giá trị 3 ⇒ không có đường tăng quá 3 (INV-4). |
| Ca metastability trên `digit_valid` | Không thuộc khối: `interface.md` §4 giao nghĩa vụ đồng bộ hoá cho **tầng ngoài**. Muốn kiểm phải mô phỏng cả bộ đồng bộ 2 FF, mà bộ đó không nằm trong F03. |
| Ca glitch trên `unlock` | Mô phỏng hiện tại là **zero-delay behavioral** ⇒ về nguyên lý không sinh glitch. Phải chờ tầng L5 (post-layout + SDF). |

## 5. Ca phải bổ sung khi chuyển sang gate-level / post-layout

| Tầng | Ca mới cần thêm | Vì sao chỉ xuất hiện ở tầng này |
|---|---|---|
| L4 — gate-level trên `06_GDSII/synthesis/netlist.v` | **X-propagation sau power-up**: thả 23 FF ở `X`, giữ `rst_n=0`, xem `unlock`/`locked` có về giá trị xác định không | Mô phỏng RTL khởi tạo `logic` = `X` nhưng `always_ff` với reset đồng bộ chỉ xoá được khi có cạnh clock; netlist `dfxtp_1` **không có chân reset** — reset đã bị ánh xạ thành logic trước chân `D` (thấy rõ ở `_085_ nor2(A=_034_, B=_050_)`, `_034_` là `~rst_n`). Cần ít nhất 1 cạnh clock có `rst_n=0`. |
| L4 | **Chạy lại toàn bộ C-1…C-9 trên netlist** | Chứng minh tổng hợp không đổi chức năng (logic equivalence bằng mô phỏng) |
| L5 — post-layout + SDF | **Ca chạm biên setup của đường `digit_valid → d0[0]`** | Đường tới hạn thật (1,78 ns, `sta/timing_report_max.txt`). Ở RTL zero-delay đường này vô hình. |
| L5 | **Ca hold trên `pos`/`fails`** | `timing_report_min.txt` hiện chưa được phân tích; hold chỉ có ý nghĩa sau CTS. |
| L5 | **Glitch trên `unlock`** trong chu kỳ chuyển `UNLOCK_ST → WAIT_ST` | `unlock` là hàm tổ hợp của 3 bit `state` đổi không đồng thời ⇒ có thể có glitch. Tầng ngoài nếu lấy mẫu bằng mức (không bằng cạnh clock) sẽ mở khoá nhầm. |

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
