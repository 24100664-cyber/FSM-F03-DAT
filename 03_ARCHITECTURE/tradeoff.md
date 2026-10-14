# F03 · Phân tích đánh đổi (Trade-off)

Mọi con số trong bảng lấy từ `06_GDSII/synthesis/synth_stat.txt`,
`06_GDSII/sta/timing_report_max.txt` và `06_GDSII/power/power_report.txt`.
Ô ghi `⬜` là **chưa chạy** — không được điền số ước lượng.

---

## 1. Số liệu thật của kiến trúc đã chọn

| Chỉ số | Giá trị đo được | Nguồn |
|---|---:|---|
| Tổng số cell | **88** | `synth_stat.txt` |
| Flip-flop (`dfxtp_1`) | **23** | ″ |
| Cell tổ hợp | 65 | 88 − 23 |
| Diện tích | **892,1056 µm²** | ″ |
| Data arrival đường tới hạn | **1,78 ns** | `sta/summary.txt` |
| Slack (period 10 ns giả định) | **8,09 ns** | ″ |
| Số cell trên đường tới hạn | **5** | `timing_report_max.txt` |
| Công suất tổng | **1,08e-04 W** | `power_report.txt` |
| — trong đó Sequential | **9,86e-05 W (91,4 %)** | ″ |
| — trong đó Combinational | 9,29e-06 W (8,6 %) | ″ |
| Charter mục 10 ước lượng ô nhớ | 6–8 | brief F03 |
| Charter metadata ước lượng quy mô | ~230–330 cell | brief F03 |

> **Hai con số lệch Charter, phải giải thích:**
> - **88 cell < 230–330 cell.** Nhỏ hơn ước lượng Charter ~3 lần. Nguyên nhân: mã bí mật là
>   hằng số nên comparator co lại còn 5 cổng (`block_diagram.md` §3), và thiết kế **thiếu**
>   5 bit ra mà Charter mục 4 đòi (`functional_spec.md`, cảnh báo đầu file).
> - **23 FF > 6–8 ô nhớ.** Lớn hơn ước lượng Charter ~3 lần, vì thiết kế đệm cả 4 chữ số
>   người dùng (16 FF). Chi tiết ở `datapath.md` §5.

## 2. So sánh ba kiến trúc cho cùng bài toán

### Kiến trúc A — **Đã chọn**: đệm 4 chữ số + so một lượt ở `CHECK_ST`

```
 digit ─▶ [d0][d1][d2][d3] ─16bit─▶ comparator hằng ─1bit─▶ FSM 4 trạng thái
          (16 FF)                    (5 cổng, 0 FF)
```

### Kiến trúc B — **So từng chữ số ngay khi nhập** (streaming compare)

```
 digit ─┬─▶ comparator 4 bit ◀── mux4→1 chọn SECRET[pos] (hằng số)
        │        │
        │        ▼
        └──▶ ok_so_far (1 FF)  ─▶ FSM
 (không cần d0..d3)
```

### Kiến trúc C — **Mã bí mật để trong thanh ghi ghi được**

```
 digit ─▶ [d0..d3] (16 FF) ─┐
                            ├─▶ comparator 16 bit thật ─▶ FSM
 secret_wr ─▶ [s0..s3] (16 FF)┘
```

| Tiêu chí | **A (đã chọn)** | **B (streaming)** | **C (mã trong thanh ghi)** |
|---|---|---|---|
| Flip-flop | **23** (đo được) | ước tính ~8 = 3+2+2+1 | ước tính ~39 = 23 + 16 |
| Số cell | **88** (đo được) | ⬜ chưa chạy | ⬜ chưa chạy |
| Diện tích | **892,1056 µm²** (đo được) | ⬜ chưa chạy | ⬜ chưa chạy |
| Comparator | 4 cổng 4-vào + 1 AND4 (**2 mức**) | 1 comparator 4 bit + mux hằng | 16 XNOR + cây AND (**≥4 mức**) |
| Độ trễ nhận biết kết quả | 2 chu kỳ sau chữ số cuối | 1 chu kỳ (có thể sớm hơn) | 2 chu kỳ |
| Công suất tuần tự | **91,4 %** của 1,08e-04 W | thấp hơn nhiều (ít FF hơn ~65 %) | cao hơn (thêm 16 FF luôn bật) |
| Mã bí mật lộ trong netlist? | **CÓ** — thành cực tính chân cổng (§4) | **CÓ** — thành hằng ở mux | **KHÔNG** — nằm trong FF |
| Đổi mã lúc chạy | không thể | không thể | **được** |
| Nguy cơ timing attack | thấp (luôn 2 chu kỳ) | **cao nếu thoát sớm** | thấp |
| Độ phức tạp mã RTL | trung bình | thấp | cao (thêm giao diện ghi mã) |
| **Khi nào nên dùng** | Khi cần đường so sánh nông và muốn dạy hiện tượng constant-folding | Khi diện tích/công suất là ràng buộc gắt và mã cố định | Khi **bắt buộc** đổi mã lúc chạy |

**Quan trọng — điều bảng này chứng minh và không chứng minh:** chỉ cột A có số thật. Cột B
và C là **suy luận từ cấu trúc**, không phải kết quả chạy tool. Muốn so sánh nghiêm túc
phải viết cả ba, chạy cùng một script Yosys + OpenSTA, rồi đặt ba bộ số cạnh nhau. Hồ sơ
này **chưa làm việc đó**.

## 3. Trả lời Charter mục 9 bằng số liệu thật

> *"Thiết kế lưu mã đúng ở đâu — hằng số trong RTL hay thanh ghi? Nêu lựa chọn của mình và
> chỉ ra hệ quả trong báo cáo tổng hợp."*

**Lựa chọn: hằng số trong RTL** (`parameter logic [3:0] SECRET0=4'd1, …`, RTL dòng 5–8).

**Hệ quả đo được trong báo cáo tổng hợp — bốn bằng chứng:**

1. **0 flip-flop cho mã bí mật.** Kiểm toán toàn bộ 23 FF trong netlist:
   `state[0..2]` (3) + `d0..d3` (16) + `pos[0..1]` (2) + `fails[0..1]` (2) = **23**. Không
   còn chỗ cho bất kỳ FF nào mang mã. Nếu mã nằm trong thanh ghi, `synth_stat.txt` phải ghi
   `dfxtp_1 = 39`.

2. **Comparator bị hằng-số-hoá thành đúng 5 cổng.** `netlist.v` dòng 114–148:

   ```verilog
   sky130_fd_sc_hd__nor4b_1  _068_ (.A(\d0[3] ), .B(\d0[2] ), .C(\d0[1] ), .D_N(\d0[0] ), .Y(_037_));
   sky130_fd_sc_hd__and4_1   _070_ (.A(_035_), .B(_036_), .C(_037_), .D(_038_), .X(_039_));
   ```

   Một comparator 16 bit "thật" cần 16 XNOR + cây AND. Ở đây chỉ còn 4 cổng 4-đầu-vào + 1 AND4.

3. **Mã bí mật đọc được thẳng từ netlist.** Chân nào để thường, chân nào để `_N` chính là
   bit nào phải bằng 0, bit nào phải bằng 1 — giải mã đầy đủ ở `block_diagram.md` §3, ra
   đúng (1,2,3,4). **Đây là hệ quả bảo mật nghiêm trọng của việc hằng-số-hoá**: ai có
   netlist hoặc soi được layout là có mã. Trong sản phẩm thật, mã phải nằm trong OTP/eFuse
   hoặc thanh ghi nạp lúc khởi động — cả hai đều **ngoài phạm vi** Charter mục 3.

4. **Đường tới hạn *không* đi qua comparator.** `sta/summary.txt` cho endpoint là `_131_`
   (= `d0[0]`), tức đường nạp, không phải đường so sánh. Hằng-số-hoá đã làm comparator rẻ
   tới mức nó biến mất khỏi danh sách 10 đường chậm nhất.

## 4. Những đánh đổi **KHÔNG được phép** trong đề này

| Đánh đổi bị cấm | Cơ sở | Vì sao có người muốn làm |
|---|---|---|
| Thêm cơ chế **đổi mã lúc chạy** | Charter mục 3: *ngoài phạm vi* | Để tránh lộ mã trong netlist (§3.3) |
| Thêm **khoá theo thời gian** (tự mở sau T) | Charter mục 3: *ngoài phạm vi* | Để không phải reset bằng tay |
| Hỗ trợ **nhiều người dùng / nhiều mã** | Charter mục 3: *ngoài phạm vi* | Bài toán thực tế của tủ đồ |
| **Lưu mã bền vững** (OTP/eFuse/flash) | Charter mục 3: *ngoài phạm vi* | Bảo mật thật |
| Tự **sửa RTL** để chữa lỗi nuốt chữ số | Quy tắc hồ sơ: giữ nguyên bản gốc của thầy | Để mô phỏng PASS. **Bản vá đã soạn sẵn nhưng CHƯA áp dụng** — `05_VERIFICATION/known_issues.md` §4 |
| Tự **tối ưu netlist bằng tay** | Charter mục 3 (áp dụng chung cho mọi đề) | Để giảm 88 cell |
| Tự **làm physical design** | Charter mục 3 | Để có GDS |
| Tuyên bố "đã sign-off / tape-out / chạy được ở X MHz" | Charter mục 3 + `02_SPECIFICATION/timing.md` §3 | Slack 8,09 ns nhìn "đẹp" nên dễ bị diễn giải sai |

## 5. Ba đánh đổi **được phép và nên bàn** khi bảo vệ

| Đánh đổi | Chi phí thật | Lợi ích | Có được phép? |
|---|---|---|---|
| Thu `state` từ `logic [2:0]` về `logic [1:0]` | −1 FF (23 → 22) | Giảm 4,3 % số FF, mà FF chiếm 91,4 % công suất | ✅ Được — chỉ là sửa khai báo RTL, không phải tối ưu netlist thủ công. **Chưa thử, chưa có số.** |
| Bổ sung đủ 5 bit ra Charter mục 4 đòi | +5 chân, có thể +vài cell đệm | **Đạt REQ-F03-002** (hiện KHÔNG ĐẠT) | ✅ **Bắt buộc phải làm** để hồ sơ hợp lệ |
| Đổi sang kiến trúc B (streaming) | Mất khả năng mở rộng sang đổi-mã-lúc-chạy | ~ −15 FF | ⚠️ Được bàn trên giấy; đổi thật là **đổi kiến trúc**, phải hỏi thầy |

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
