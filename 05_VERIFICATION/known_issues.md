# F03 · Lỗi đã biết và phán xử (Known Issues)

## ✅ Trạng thái: ĐÃ ÁP DỤNG — 2026-09-24

Giảng viên đã duyệt. **Toàn bộ bản vá ở §4 đã được áp dụng**, kể cả bản vá chạm vào RTL
thiết kế. Nhật ký chi tiết: `08_ORIGINAL_SOURCE/PATCHLOG.md`.

| Bản vá | File | Trạng thái |
|---|---|:-:|
| P-1 — `pos_eff`, nhận chữ số trong `UNLOCK_ST` | `04_IMPLEMENTATION/rtl/f03_lock_scaffold.sv` | ✅ ĐÃ ÁP DỤNG (nguyên văn) |
| P-2 — nhận chữ số trong `UNLOCK_ST` | `04_IMPLEMENTATION/rtl/f03_lock_scaffold_explicit.sv` | ✅ ĐÃ ÁP DỤNG (nguyên văn) |
| P-3 — vá đứt gãy truy vết | `05_VERIFICATION/testbench/f03_tb.sv` | ✅ ĐÃ ÁP DỤNG **theo phương án thứ ba** — xem dưới |
| P-4 — ca C-5 và C-2' | `05_VERIFICATION/testbench/f03_tb.sv` | ✅ ĐÃ ÁP DỤNG (nguyên văn) |
| Giao diện thiếu 5 bit ra (Charter mục 4) | — | ⬜ **CHƯA VÁ**, có lý do — xem dưới |
| Mô hình chuẩn Python chưa theo-chu-kỳ | — | ⬜ **CHƯA VÁ**, có lý do — xem dưới |

**Kết quả xác minh bằng công cụ thật (iverilog 12.0 + Yosys 0.33 + sky130hd):**

| Bước | Trước khi vá | Sau khi vá |
|---|---|---|
| `reference_model.py` | PASS | PASS, mã thoát 0 |
| Biên dịch `iverilog -g2012` | Sạch | **Sạch** |
| Mô phỏng `vvp` | ❌ **`$fatal` tại t = 176** (`failure count 1 missing`) | ✅ **PASS** — `F03 TB PASS`, `$finish` tại 1086 ns |
| Tổng hợp, top `f03_lock_scaffold_explicit` | 88 cell / 23 FF / 892,1056 µm² | **95 cell / 23 FF / 908,3712 µm²** |
| Tổng hợp, top `f03_lock_scaffold` | *(chưa từng đo)* | **93 cell / 23 FF / 960,9216 µm²** |

Chi phí bản vá trên top `_explicit`: **+7 cell, +16,27 µm² (+1,8 %)**, **số FF không đổi**
(23) — đúng như §P-2 ước tính. ⚠️ Bản vá nối thêm `digit_valid` vào đường nạp `d0`, tức
**làm đường tới hạn dài thêm**; slack cũ 8,09 ns còn dư nhiều nhưng **STA bắt buộc phải
chạy lại**.

### Hai bằng chứng thực nghiệm (không phải suy đoán)

1. **Testbench đã vá vẫn bắt được lỗi gốc.** Chạy testbench đã vá trên RTL **bản gốc** ở
   `08_ORIGINAL_SOURCE/rtl/` → `FATAL: f03_tb.sv:63: failure count 1 missing, Time: 176`.
   Dừng **đúng t = 176** như log gốc ⟹ bản vá RTL là sửa thật, không phải "sửa testbench
   cho vừa lỗi".
2. **`check_equiv` bắt được việc chỉ vá một trong hai module.** Biên dịch scaffold đã vá
   cùng `_explicit` bản gốc → `FATAL: f03_tb.sv:31: scaffold vs explicit khac nhau:
   unlock 1/0 locked 0/0, Time: 256`.

### P-3: vì sao chọn phương án thứ ba thay vì P-3a hoặc P-3b

§4 đề nghị chọn một trong hai. Cả hai đều có vấn đề:

- **P-3a** (đổi testbench sang `_explicit`) **làm mất** khả năng quan sát `fail_count` và
  `position`, buộc viết lại ba assertion hiện có thành kiểm gián tiếp — đó là **mất bằng
  chứng**, không phải vá.
- **P-3b** (đổi top tổng hợp + mở rộng `fail_count` lên 3 bit) đòi sửa
  `04_IMPLEMENTATION/scripts/` — thư mục **PATCH_SPEC §0 cấm động vào** — và đòi **đổi giao
  diện module**, trái nguyên tắc 2 của PATCH_SPEC.

**Phương án đã chọn:** khởi tạo **cả hai** module trong cùng testbench và so `unlock`/
`locked` ở **mọi** cạnh clock. Nó chỉ chạm một file được phép sửa, **giữ trọn** mọi
assertion cũ, và **mạnh hơn cả hai phương án gốc**: bằng chứng mô phỏng nay áp dụng cho
**cả hai** module, bất kể top tổng hợp là module nào.

### Hai hạng mục cố ý CHƯA vá (không im lặng bỏ qua)

1. **Giao diện thiếu 5 bit ra so với Charter mục 4** (§6, và cảnh báo đầu
   `functional_spec.md`). Đây là **đổi giao diện module** — PATCH_SPEC nguyên tắc 2 yêu cầu
   tránh, và nó buộc sinh lại toàn bộ tầng 02. Nằm ngoài phạm vi đợt vá này.
2. **Mô hình chuẩn Python chưa theo-chu-kỳ** (§3.2). `enter_digit` là hàm sự kiện, không
   biểu diễn được chu kỳ `CHECK_CODE`, nên không thể đồng mô phỏng với RTL. Viết lại thành
   máy trạng thái có `step()` (như F05) là thay đổi lớn, không thuộc "sửa tối thiểu". Tạm
   thời vai trò trọng tài theo chu kỳ do `check_equiv` (P-3) đảm nhiệm.

### Cập nhật §6 — trạng thái các khẳng định sau khi vá

| Khẳng định | Trước | Sau khi vá |
|---|---|---|
| **Chức năng RTL đúng đặc tả** | ❌ KHÔNG ĐẠT | ✅ **ĐẠT** — mô phỏng chạy hết, không assertion nào vi phạm |
| **Ba trong bốn ca bắt buộc Charter mục 8 đã chạy** | ❌ KHÔNG ĐẠT | ✅ **ĐẠT** — chạy hết mọi ca cũ **+ C-5 + C-2'** |
| **Bằng chứng mô phỏng áp dụng cho module đã tổng hợp** | ❌ KHÔNG ĐẠT | ✅ **ĐẠT** — `check_equiv` so hai module từng chu kỳ |
| Giao diện đúng Charter mục 4 | ❌ KHÔNG ĐẠT | ❌ **vẫn KHÔNG ĐẠT** — xem trên |
| Đường tới hạn đạt period 10 ns | ✅ ĐẠT (slack 8,09 ns) | ⚠️ **phải đo lại** — bản vá kéo dài đường tới hạn |

Phần chẩn đoán bên dưới được **giữ nguyên** làm tài liệu dạy học.

---

**Trạng thái mô phỏng RTL (nguyên văn lúc chẩn đoán): ⚠️ RAN_WITH_ISSUES — testbench dừng
giữa chừng bằng `$fatal`.**

---

## 1. Thông báo lỗi — trích nguyên văn

Từ `05_VERIFICATION/simulation.log` (toàn bộ nội dung file):

```
FATAL: /tmp/.../runs/F03/work/f03_tb.sv:41: failure count 1 missing
       Time: 176  Scope: f03_tb
```

Từ `05_VERIFICATION/iverilog_compile.log`:

```
(khong co loi)
```

> **Đọc đúng hai log này:** biên dịch **sạch hoàn toàn**. Đây **không** phải lỗi cú pháp,
> không phải giới hạn công cụ. Icarus Verilog đã chạy được thiết kế và thiết kế đã **cư xử
> sai** so với điều testbench chờ đợi. Đây là loại lỗi có giá trị nhất để mang ra dạy.

Dòng testbench bị vi phạm (`05_VERIFICATION/testbench/f03_tb.sv` dòng 40–41):

```systemverilog
        send_code(9,9,9,9);
        assert(fail_count==1) else $fatal(1,"failure count 1 missing");
```

## 2. Dựng lại toàn bộ chuỗi sự kiện tới t = 176

Testbench: `always #5 clk=~clk` ⇒ cạnh lên tại t = 5, 15, 25, … Mỗi `send_digit` tiêu thụ
**2 cạnh** (1 cạnh có `digit_valid=1`, 1 cạnh nghỉ).

| t (ns) | `digit_valid` | `digit` | `state` **trước** cạnh | Việc xảy ra tại cạnh | `pos` sau | `fails` sau |
|---:|:-:|:-:|---|---|:-:|:-:|
| 15 | 0 | 0 | — | `rst_n` nhả | 0 | 0 |
| 25 | 1 | 1 | `WAIT` | nạp `d0=1` | 1 | 0 |
| 35 | 0 | – | `WAIT` | — | 1 | 0 |
| 45 | 1 | 2 | `WAIT` | nạp `d1=2` | 2 | 0 |
| 55 | 0 | – | `WAIT` | — | 2 | 0 |
| 65 | 1 | 3 | `WAIT` | nạp `d2=3` | 3 | 0 |
| 75 | 0 | – | `WAIT` | — | 3 | 0 |
| 85 | 1 | 4 | `WAIT` | nạp `d3=4`, → `CHECK_CODE` | 3 | 0 |
| 95 | 0 | – | `CHECK_CODE` | mã **đúng** → `UNLOCK_ST`, `fails←0` | 3 | 0 |
| **105** | **1** | **9** | **`UNLOCK_ST`** | ⚠️ **chữ số 9 BỊ NUỐT**; chỉ `→WAIT_DIGIT`, `pos←0` | **0** | 0 |
| 115 | 0 | – | `WAIT` | — | 0 | 0 |
| 125 | 1 | 9 | `WAIT` | nạp `d0=9` | 1 | 0 |
| 135 | 0 | – | `WAIT` | — | 1 | 0 |
| 145 | 1 | 9 | `WAIT` | nạp `d1=9` | 2 | 0 |
| 155 | 0 | – | `WAIT` | — | 2 | 0 |
| 165 | 1 | 9 | `WAIT` | nạp `d2=9` | 3 | 0 |
| 175 | 0 | – | `WAIT` | — | 3 | 0 |
| **176** | — | — | `WAIT` | **`assert(fail_count==1)` → thực tế 0 → `$fatal`** | 3 | **0** |

**Chuỗi nhân quả, ba bước:**

```
  chữ số '9' thứ nhất bị nuốt ở UNLOCK_ST
        ↓
  chỉ nạp được 3/4 chữ số  ⇒  pos dừng ở 3, không quay về 0
        ↓
  không bao giờ vào CHECK_CODE lần hai  ⇒  fails không bao giờ tăng
        ↓
  assert(fail_count==1) thấy 0  ⇒  $fatal tại t=176
```

Thời điểm `$fatal` trong log là **t = 176**, khớp chính xác với bảng dựng lại ở trên. Đây
là kiểm chứng chéo cho thấy phán xử không phải suy đoán.

## 3. Phán xử — lỗi nằm ở đâu

| Khả năng | Phán xử | Lập luận |
|---|:-:|---|
| Lỗi trong **DUT** (thiết kế sai) | ✅ **ĐÚNG — đây là nguồn gốc** | Xem §3.1 |
| Lỗi trong **mô hình chuẩn** (golden model) | ❌ Không | Xem §3.2 |
| Lỗi trong **testbench** | ⚠️ **Có một lỗi phụ, không phải nguyên nhân** | Xem §3.3 |
| **Giới hạn công cụ** (Icarus) | ❌ Không | `iverilog_compile.log` = "(khong co loi)". Icarus biên dịch và chạy sạch. |

### 3.1 Lỗi chính — DUT nuốt chữ số đầu tiên sau khi mở khoá

Mã gây lỗi, `04_IMPLEMENTATION/rtl/f03_lock_scaffold.sv` **dòng 41–56** (module mà testbench
khởi tạo):

```systemverilog
        if (state == LOCKED_ST) begin
            next_state = LOCKED_ST;
        end else if (state == UNLOCK_ST) begin     // ← nhánh này ĂN TRỌN chu kỳ
            next_state = WAIT_DIGIT;
            npos=0;
        end else if (digit_valid) begin            // ← không bao giờ tới được khi UNLOCK_ST
            case (position)
                2'd0: begin n0=digit; npos=1; end
                ...
```

Chuỗi `if / else if` đặt `state == UNLOCK_ST` **trước** `digit_valid`. Khi cả hai cùng
đúng, nhánh `digit_valid` bị bỏ qua ⇒ **chữ số bị mất**.

Cùng một khiếm khuyết trong module đã tổng hợp,
`04_IMPLEMENTATION/rtl/f03_lock_scaffold_explicit.sv` **dòng 43**:

```systemverilog
                UNLOCK_ST: state<=WAIT_ST;     // không có nhánh nạp digit
```

> **Đây là điểm quyết định của phán xử:** khiếm khuyết có mặt trong **cả hai** module, viết
> theo **hai phong cách khác nhau** (một khối vs hai khối). Một lỗi gõ nhầm không tự nhân
> đôi như vậy. Đây là **thiếu sót trong đặc tả hành vi**: người viết chưa quyết định "trong
> chu kỳ `UNLOCK_ST`, khối có nhận chữ số không?" — và mặc định của cả hai cách viết là *không*.

**Vì sao ca này ít khi bị bắt:** nó chỉ lộ ra khi có **một lần thử đúng rồi ngay sau đó một
lần thử nữa**. Chuỗi kiểm thử phổ biến "nhập đúng → xong" hoặc "nhập sai → nhập sai → nhập
sai" đều **không** đi qua cung `UNLOCK_ST` với `digit_valid=1`. Testbench này bắt được lỗi
**một cách tình cờ** vì nó kiểm cả hai tính chất trong một chuỗi liên tục.

### 3.2 Mô hình chuẩn Python — **ĐÚNG**, và chính nó định nghĩa hành vi mong đợi

`05_VERIFICATION/golden_model/reference_model.py` dòng 14–29:

```python
    def enter_digit(self,d):
        if self.locked:
            return None
        self.digits.append(d)
        if len(self.digits)==4:
            ...
            if code==self.secret:
                self.failures=0
                return "UNLOCK"
```

Mô hình **không có trạng thái `UNLOCK` tiêu tốn một chu kỳ**. Sau khi trả `"UNLOCK"`, lời
gọi `enter_digit` kế tiếp nạp chữ số **ngay**. Nghĩa là mô hình chuẩn quy định: *chữ số
ngay sau lần mở khoá phải được nhận*. Mô hình chạy PASS (`python_reference_run.log`).

⇒ **Mô hình chuẩn và testbench đồng thuận với nhau; chỉ có RTL đứng ngoài.** Đó là tiêu
chuẩn vàng để kết luận lỗi ở DUT chứ không ở mô hình.

Mô hình chuẩn có một **khác biệt về mô hình hoá** cần ghi nhận (không phải lỗi): nó dùng
`enter_digit` là hàm sự kiện, không có khái niệm chu kỳ clock, nên nó **không thể** biểu
diễn chu kỳ `CHECK_CODE`. Muốn dùng nó làm mô hình chuẩn theo-chu-kỳ (cycle-accurate) thì
phải viết lại thành máy trạng thái có `step()` — như cách F05 đã làm.

### 3.3 Testbench — có **một lỗi phụ**, nhưng không gây ra `$fatal` này

`f03_tb.sv` dòng 7 khởi tạo `f03_lock_scaffold`. Yosys lại tổng hợp
`f03_lock_scaffold_explicit` (`06_GDSII/synthesis/synth_stat.txt`).

⇒ **Mô phỏng chứng minh cho module A; mọi số liệu diện tích, công suất, STA nói về module B.**
Đây là đứt gãy truy vết (traceability gap) độc lập với lỗi trên, và phải vá dù lỗi kia đã
sửa. Xem §5, bản vá P-3.

Testbench cũng **thiếu** các ca quan trọng (đặc biệt C-2': sai 2 → đúng → sai 2), liệt kê
đầy đủ ở `02_SPECIFICATION/corner_cases.md` §2. Nhưng những thiếu sót đó là *thiếu độ phủ*,
không phải nguyên nhân của `$fatal` ở dòng 41.

## 4. Bản vá tối thiểu

> ⚠️ **CÁC BẢN VÁ DƯỚI ĐÂY CHƯA ĐƯỢC ÁP DỤNG.** RTL trong hồ sơ giữ nguyên bản gốc của
> thầy. Cần thầy duyệt trước khi sửa, vì việc sửa làm thay đổi **hợp đồng hành vi** của
> khối, không chỉ sửa một dòng.

### P-1 — Vá `f03_lock_scaffold.sv` (module testbench dùng)

Ý tưởng: tách "vị trí hiệu dụng" (`pos_eff`) khỏi thanh ghi `position`, để chu kỳ
`UNLOCK_ST` vừa quay về `WAIT_DIGIT` vừa **nhận được** chữ số đầu của lần thử kế.

```diff
@@ module f03_lock_scaffold — khai báo tín hiệu (sau dòng 33)
     logic [1:0] npos, nfail;
     logic [3:0] ndigit;
+    logic [1:0] pos_eff;   // vị trí hiệu dụng: 0 khi vừa mở khoá xong

@@ always_comb (dòng 35–56)
     always_comb begin
+        // Vừa mở khoá ⇒ lần thử kế bắt đầu từ vị trí 0 NGAY trong chu kỳ này.
+        pos_eff = (state == UNLOCK_ST) ? 2'd0 : position;
+
         next_state = state;
         n0=d0; n1=d1; n2=d2; n3=d3;
-        npos=position; nfail=fail_count;
+        npos=pos_eff;  nfail=fail_count;
         ndigit=digit;

         if (state == LOCKED_ST) begin
             next_state = LOCKED_ST;
-        end else if (state == UNLOCK_ST) begin
-            next_state = WAIT_DIGIT;
-            npos=0;
-        end else if (digit_valid) begin
-            case (position)
+        end else if (state == UNLOCK_ST || state == WAIT_DIGIT) begin
+            if (state == UNLOCK_ST) next_state = WAIT_DIGIT;
+            if (digit_valid) begin
+              case (pos_eff)
                 2'd0: begin n0=digit; npos=1; end
                 2'd1: begin n1=digit; npos=2; end
                 2'd2: begin n2=digit; npos=3; end
                 2'd3: begin
                     n3=digit;
+                    npos=0;
                     next_state=CHECK_CODE;
                 end
-            endcase
+              endcase
+            end
         end
```

**Vì sao vá thế này là tối thiểu:** nó không thêm trạng thái, không thêm flip-flop
(`pos_eff` là tổ hợp thuần), không đổi số chu kỳ độ trễ, không đụng tới `LOCKED_ST` hay
logic đếm `fails`. Chỉ đổi **thứ tự ưu tiên** giữa "thoát `UNLOCK_ST`" và "nhận chữ số",
cho hai việc xảy ra trong **cùng một** chu kỳ.

### P-2 — Vá `f03_lock_scaffold_explicit.sv` (module đã tổng hợp)

```diff
@@ dòng 25–46 : case(state)
-                UNLOCK_ST: state<=WAIT_ST;
+                UNLOCK_ST: begin
+                    state<=WAIT_ST;
+                    // Nhận luôn chữ số đầu của lần thử kế tiếp.
+                    if(digit_valid) begin d0<=digit; pos<=1; end
+                    else            pos<=0;
+                end
```

Phiên bản `_explicit` dễ vá hơn vì `pos` đã được đặt về 0 ngay tại chữ số thứ tư (dòng 31),
nên trong `UNLOCK_ST` ta biết chắc vị trí kế là 0.

**Chi phí phần cứng ước tính:** thêm một điều kiện vào đường nạp `d0` — tức thêm đầu vào
cho nhóm cổng `_083_`/`_084_`. Đường tới hạn hiện tại **chính là** đường này
(`sta/summary.txt`: `digit_valid → _131_`, arrival 1,78 ns), nên bản vá **sẽ làm đường tới
hạn dài thêm**. Với slack 8,09 ns thì dư sức, nhưng **bắt buộc phải chạy lại STA sau khi
vá** — không được giả định.

### P-3 — Vá đứt gãy truy vết

Chọn **một** trong hai, không được để lửng:

| Phương án | Việc phải làm | Hệ quả |
|---|---|---|
| **P-3a** (khuyến nghị) | Đổi `f03_tb.sv` dòng 7 sang `f03_lock_scaffold_explicit`, bỏ hai cổng `position`/`fail_count` khỏi danh sách nối, và kiểm `fails` gián tiếp qua hành vi (`locked` lên đúng ở lần sai thứ ba) | Mô phỏng và tổng hợp cùng nói về một module. Mất khả năng quan sát trực tiếp `fail_count`. |
| **P-3b** | Đổi top tổng hợp sang `f03_lock_scaffold` **và** mở rộng `fail_count` lên 3 bit, thêm wrapper Tiny Tapeout | Đồng thời giải quyết luôn phần **CHƯA THOẢ** Charter mục 4 (`functional_spec.md` cảnh báo đầu file). Phải chạy lại toàn bộ tổng hợp + STA + power; **mọi số liệu trong hồ sơ sẽ đổi.** |

### P-4 — Bổ sung ca kiểm thử chặn hồi quy

```systemverilog
        // C-5: chữ số phát ra ĐÚNG trong chu kỳ unlock=1 phải được nhận.
        send_code(1,2,3,4);              // mở khoá
        assert(unlock) else $fatal(1,"unlock pulse missing");
        send_code(1,2,3,4);              // lần thử kế, bắt đầu ngay
        assert(!locked && fail_count==0) else $fatal(1,"digit swallowed after unlock");

        // C-2': sai 2 → đúng → sai 2 ⇒ tổng 4 lần sai mà KHÔNG được khoá.
        send_code(9,9,9,9); send_code(9,9,9,9);
        send_code(1,2,3,4);
        send_code(9,9,9,9); send_code(9,9,9,9);
        assert(!locked) else $fatal(1,"counted TOTAL failures, not CONSECUTIVE");
```

Ca C-2' bắt đúng "chỗ hay tắc" mà Charter mục 10 cảnh báo.

## 5. Giá trị dạy học của lỗi này

Đây là một **bẫy kinh điển** và rất đáng giữ lại trong giáo trình:

| Bài học | Nội dung |
|---|---|
| **1. Trạng thái "nhất thời" vẫn tiêu tốn một chu kỳ** | Sinh viên hay nghĩ `UNLOCK_ST` "chỉ để bật đầu ra" nên vô hại. Thực tế nó chiếm trọn một chu kỳ, và mọi đầu vào đến trong chu kỳ đó phải được **quyết định** sẽ nhận hay bỏ — không có lựa chọn "không nghĩ tới". |
| **2. Thứ tự `else if` là thứ tự ưu tiên phần cứng** | Đặt `state == UNLOCK_ST` trước `digit_valid` không phải chuyện phong cách; nó tạo ra một mux có `state` ở chân select cao hơn. Mọi `if/else if` trong `always_comb` đều là một cây ưu tiên vật lý. |
| **3. Moore FSM trả giá bằng chu kỳ** | Nếu `unlock` là Mealy (phát ngay ở `CHECK_ST`), trạng thái `UNLOCK_ST` biến mất và lỗi này **không tồn tại**. Đây là minh hoạ rất đẹp cho đánh đổi Mealy/Moore — cùng bài toán, chọn Moore thì phát sinh một chu kỳ "chết" phải xử lý. So sánh trực tiếp với đề **F04**, nơi cùng một bài toán được làm cả hai kiểu. |
| **4. Độ phủ chuỗi ≠ độ phủ nhánh** | Testbench đi qua cung `UNLOCK_ST → WAIT_DIGIT` nhưng **không kiểm** nó. Lỗi chỉ lộ vì testbench tình cờ nối hai giao dịch liền nhau. Bài học: phải thiết kế ca theo **cung chuyển trạng thái**, không theo "kịch bản người dùng". |
| **5. Mô hình chuẩn viết bằng ngôn ngữ khác đã làm đúng việc của nó** | Nguyên tắc *diverse redundancy* (`testplan.md` §1) phát huy: mô hình Python và RTL do cùng ý đồ nhưng khác cách nghĩ, nên bất đồng lộ ra. Nếu mô hình chuẩn cũng viết bằng SystemVerilog theo cùng khuôn mẫu, rất có thể nó đã **cùng sai**. |
| **6. Biên dịch sạch không chứng minh gì về chức năng** | `iverilog_compile.log` = "(khong co loi)", `Tổng hợp = PASS`, `STA = PASS`, slack 8,09 ns — tất cả đều xanh, mà mạch vẫn sai. Ba cái "PASS" đó nói về *tổng hợp được* và *đủ nhanh*, không nói về *đúng*. |

## 6. Trạng thái các khẳng định của hồ sơ sau phán xử

| Khẳng định | Trạng thái |
|---|---|
| RTL tổng hợp được ra standard cell sky130 | ✅ ĐẠT — `yosys.log`, 88 cell |
| Thiết kế là mạch tuần tự | ✅ ĐẠT — 23 `dfxtp_1` |
| Đường tới hạn đạt period 10 ns giả định | ✅ ĐẠT — slack 8,09 ns (với 4 giả định ở `timing.md` §3) |
| Mô hình chuẩn Python đúng | ✅ ĐẠT |
| **Chức năng RTL đúng đặc tả** | ❌ **KHÔNG ĐẠT** — lỗi §3.1 |
| **Ba trong bốn ca bắt buộc Charter mục 8 đã chạy** | ❌ **KHÔNG ĐẠT** — testbench dừng ở ca thứ hai |
| Giao diện đúng Charter mục 4 | ❌ **KHÔNG ĐẠT** — thiếu 5 bit ra (`functional_spec.md`, cảnh báo đầu file) |
| Bằng chứng mô phỏng áp dụng cho module đã tổng hợp | ❌ **KHÔNG ĐẠT** — §3.3 |

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
