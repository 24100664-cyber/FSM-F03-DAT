# F03 — FSM khoá số bốn chữ số có khoá tạm · Ghi chú thực hiện

---

## 1. Bài toán này thực chất là gì

Nhìn qua, F03 là "so mật khẩu". Nhưng so mật khẩu là việc của một cổng AND — nó không cần
FSM. Bản chất của F03 nằm ở ba chữ khác: **bốn chữ số**, **nối tiếp**, và **khoá tạm**.

Giao diện chỉ có 4 bit dữ liệu (`digit[3:0]`) và một tín hiệu bắt tay (`digit_valid`). Mã
bí mật thì dài 16 bit. Vậy khối buộc phải **gom bốn sự kiện rời rạc theo thời gian thành
một sự kiện logic duy nhất**. Đây chính là định nghĩa của một máy trạng thái: một thiết bị
biến *chuỗi theo thời gian* thành *quyết định*.

Tầng thứ hai còn thú vị hơn. Charter mục 1 nói "khoá tạm sau ba lần sai để chống dò mã" —
nghĩa là khối không chỉ nhớ *đang nhập tới đâu*, mà còn nhớ *lịch sử của các lần thử trước*.
Và Charter mục 10 chỉ thẳng vào cái bẫy: phải là **ba lần sai LIÊN TIẾP**, không phải ba
lần sai tổng cộng. Khác biệt một dòng lệnh trong RTL, khác biệt một trời một vực về ý nghĩa:
"tổng cộng" nghĩa là một người dùng vụng về, dùng tủ mỗi ngày, sau vài tháng sẽ bị khoá
vĩnh viễn dù chưa bao giờ sai hai lần liền.

Vậy F03 thực chất là bài toán về **ba mức trạng thái lồng nhau, trên ba thang thời gian
khác nhau**:

| Mức | Thang thời gian | Cái được nhớ | Tín hiệu |
|---|---|---|---|
| 1 | trong một lần thử | đang nhập chữ số thứ mấy | `pos[1:0]` |
| 2 | giữa các lần thử | đã sai liên tiếp bao nhiêu lần | `fails[1:0]` |
| 3 | vĩnh viễn (tới reset) | đã bị khoá chưa | `state == LOCKED_ST` |

Ai thiết kế F03 mà chỉ nghĩ tới mức 1 sẽ ra một mạch đúng về so sánh nhưng vô dụng về bảo mật.

## 2. Bản chất kỹ thuật — cơ chế hoạt động

Ba cơ chế đáng nói, và cả ba đều có bằng chứng trong netlist.

**Cơ chế 1 — con trỏ ghi biến chuỗi thời gian thành chuỗi không gian.**
`pos[1:0]` là bộ đếm mod-4. Nó không tham gia tính toán gì; việc duy nhất của nó là **chọn
thanh ghi nào được ghi** ở chu kỳ này. Cơ chế vật lý: `pos` đi vào một bộ giải mã 2→4, ra
bốn tín hiệu write-enable, mỗi tín hiệu lái chân `S` của một nhóm 4 `mux2i_1`. Mỗi mux chọn
giữa "giữ giá trị cũ" (`A0 = d0[0]`) và "nạp giá trị mới" (`A1 = digit[0]`). Nhìn trong
netlist:

```verilog
sky130_fd_sc_hd__mux2i_1 _084_ (.A0(\d0[0] ), .A1(digit[0]), .S(_049_), .Y(_050_));
```

Đây là lý do có **16 cell `mux2i_1`** trong `synth_stat.txt` — đúng bằng số bit bộ đệm mã.
Con số 16 không phải trùng hợp; nó là dấu vân tay của kiến trúc "bốn thanh ghi có write-enable".

**Cơ chế 2 — nén 16 bit thành 1 bit trong đúng hai mức cổng.**
Bộ đệm rộng 16 bit, nhưng FSM chỉ có 3 bit trạng thái. Toàn bộ 16 bit phải được nén thành
**một bit duy nhất** (`match`) trước khi được phép ảnh hưởng tới quyết định. Việc nén này
rẻ tới bất ngờ vì mã bí mật là **hằng số**: so sánh `d0 == 4'b0001` không cần XNOR, nó chỉ
là "ba bit này phải bằng 0 và một bit kia phải bằng 1" — tức là **một cổng NOR 4 đầu vào có
một chân đảo**. Yosys tìm đúng cell đó trong sky130: `nor4b_1`.

Hệ quả: comparator 16 bit chỉ tốn **5 cổng, 2 mức** (`_066_`…`_070_`). Đây là lý do
đường tới hạn **không** đi qua comparator. Nếu mã bí mật nằm trong thanh ghi, comparator
phải là 16 XNOR + cây AND ≥ 4 mức, và bức tranh timing sẽ khác hẳn.

**Cơ chế 3 — trạng thái hấp thụ là cách rẻ nhất để làm "khoá vĩnh viễn".**
`LOCKED_ST: state<=LOCKED_ST;` — một dòng. Về mặt phần cứng, nó tạo một vòng tự-giữ trên
`state`, và vì `case(state)` không có nhánh nào rời `LOCKED_ST`, **không tồn tại đường logic
nào** đưa `state` ra khỏi mã `3'b011`. Chỉ còn `rst_n`, vốn được xử lý ở tầng cao hơn
`case` (RTL dòng 21). Đây là cách chứng minh tính bất biến INV-2 mà không cần assertion nào:
nó đúng **về mặt cấu trúc**, không phải về mặt hành vi.

So sánh với phương án "khoá 30 giây": ở 100 kHz, đếm 30 s cần 22 bit ⇒ **+22 flip-flop**,
gần bằng toàn bộ 23 FF hiện có. Thiết kế đổi sự tiện lợi của người dùng lấy việc **không
tốn một flip-flop nào** cho cơ chế khoá.

## 3. Đọc mã nguồn: RTL làm gì, từng dòng quan trọng

Module đã tổng hợp là `f03_lock_scaffold_explicit` (bằng chứng: `synth_stat.txt` ghi
`=== f03_lock_scaffold_explicit ===`). Ba đoạn đáng đọc kỹ.

**Đoạn 1 — con trỏ ghi và điểm kết thúc lần thử (dòng 26–33):**

```systemverilog
                WAIT_ST: if(digit_valid) begin
                    case(pos)
                        0: begin d0<=digit; pos<=1; end
                        1: begin d1<=digit; pos<=2; end
                        2: begin d2<=digit; pos<=3; end
                        3: begin d3<=digit; pos<=0; state<=CHECK_ST; end
                    endcase
                end
```

Ba nhánh đầu giống hệt nhau về cấu trúc; nhánh thứ tư khác ở **hai** chỗ: `pos<=0` (đóng
vòng) và `state<=CHECK_ST` (kết thúc lần thử). Điều tinh tế: việc nạp `d3` và việc chuyển
trạng thái xảy ra **cùng một cạnh clock**. Vì thế ở chu kỳ `CHECK_ST`, `d3` đã sẵn sàng —
không cần chu kỳ chờ. Nếu tách thành hai chu kỳ, độ trễ sẽ là 3 chứ không phải 2.

**Đoạn 2 — logic chống dò (dòng 34–42), trái tim của đề:**

```systemverilog
                CHECK_ST: begin
                    if(d0==SECRET0 && d1==SECRET1 && d2==SECRET2 && d3==SECRET3) begin
                        fails<=0; state<=UNLOCK_ST;
                    end else if(fails==2) begin
                        fails<=3; state<=LOCKED_ST;
                    end else begin
                        fails<=fails+1'b1; state<=WAIT_ST;
                    end
                end
```

Dòng `fails<=0;` trong nhánh đúng là **toàn bộ** câu trả lời cho Charter mục 2 câu 3. Nó
biến `fails` từ "tổng số lần sai" thành "số lần sai kể từ lần đúng gần nhất". Xoá dòng đó
đi, mạch vẫn biên dịch, vẫn tổng hợp, vẫn qua mọi ca kiểm thử của testbench hiện tại — và
vẫn **sai hoàn toàn so với đề**. Đây chính xác là "chỗ hay tắc" mà Charter mục 10 cảnh báo.

Chi tiết thứ hai: điều kiện là `fails==2`, không phải `fails==3`. Vì kiểm tra xảy ra
**trước** khi tăng, nên `fails==2` nghĩa là "hai lần trước đã sai, lần này là lần thứ ba".
Đổi thành `fails==3` sẽ khoá ở lần thứ tư — lỗi off-by-one kinh điển.

**Đoạn 3 — nơi có khiếm khuyết (dòng 43–45):**

```systemverilog
                UNLOCK_ST: state<=WAIT_ST;
                LOCKED_ST: state<=LOCKED_ST;
                default: state<=WAIT_ST;
```

Dòng `UNLOCK_ST` chỉ làm **một** việc: chuyển trạng thái. Nó không xét `digit_valid`. Hậu
quả: chữ số nào đến trong chu kỳ này bị **mất hẳn**. Đây là nguyên nhân trực tiếp của lỗi
mô phỏng, phán xử đầy đủ ở `05_VERIFICATION/known_issues.md`.

Dòng `default` thì đúng về ý (đưa mã trạng thái bất hợp lệ về nơi an toàn) nhưng **chưa
đủ**: nó không xoá `pos` và `fails`, nên sau một sự cố, khối trở lại hoạt động với con trỏ
lệch pha.

## 4. Vì sao chọn kiến trúc này

Kiến trúc đã chọn — **đệm bốn chữ số rồi so một lượt** — không phải kiến trúc rẻ nhất. Bản
"so từng chữ số ngay khi nhập" (streaming) chỉ cần ~8 FF thay vì 23. Vậy tại sao?

**Lý do 1 — an toàn trước tấn công thời gian.** Bản streaming rất dễ bị cám dỗ thoát sớm:
"chữ số đầu đã sai rồi, cần gì chờ ba chữ số nữa". Nếu làm vậy, thời gian phản hồi rò rỉ
thông tin: kẻ tấn công biết chữ số nào đúng bằng cách bấm giờ. Bản hiện tại luôn mất **đúng
2 chu kỳ** sau chữ số thứ tư, bất kể mã sai ở đâu.

**Lý do 2 — dạy được hiện tượng constant-folding.** Khi so sánh 16 bit với hằng số, ta thấy
tận mắt cách Yosys biến một mệnh đề logic thành **cực tính chân cổng**. Bản streaming giấu
hiện tượng này (chỉ còn so 4 bit). Với một đề dùng để giảng dạy, đây là giá trị thật.

**Lý do 3 — mở đường cho tính năng tương lai.** Nếu sau này cho phép đổi mã lúc chạy
(Charter mục 3 hiện liệt vào ngoài phạm vi), bộ đệm 16 bit đã sẵn ở đó.

**Nhưng phải nói thẳng cái giá:** 23 FF vượt ước lượng Charter mục 10 (6–8 ô nhớ) gần **ba
lần**. Với công suất tuần tự chiếm **91,4 %** tổng công suất, đây cũng là khoản chi công
suất lớn nhất. Một sinh viên bảo vệ đề này **phải** nêu được cả ba lý do trên; nếu chỉ nói
"em làm thế vì thấy dễ" thì đó là 15 flip-flop lãng phí không có biện hộ.

## 5. Cách thực hiện — lộ trình 8 bước từ đặc tả tới GDSII

| # | Bước | Đầu ra phải có | Trạng thái F03 |
|---:|---|---|---|
| 1 | **Chốt hợp đồng hành vi** — viết `functional_spec.md` với INV-1…INV-9 **trước khi** viết RTL | Bảng chuyển trạng thái + danh sách invariant | ✅ đã có (nhưng viết *sau* RTL — xem §9) |
| 2 | **Viết mô hình chuẩn bằng ngôn ngữ khác** (Python) | `reference_model.py` chạy PASS | ✅ `python_reference_run.log` |
| 3 | **Viết RTL** đúng phong cách FSM: enum tường minh, có `default`, reset rõ ràng | `.sv` biên dịch sạch | ✅ `iverilog_compile.log` = "(khong co loi)" |
| 4 | **Mô phỏng RTL** với testbench phủ **từng cung chuyển trạng thái**, không phủ theo kịch bản | `simulation.log` không có `$fatal` | ⚠️ **FAIL tại t=176** |
| 5 | **Tổng hợp** bằng Yosys + thư viện sky130 | `synth_stat.txt`, `netlist.v` | ✅ 88 cell, 23 FF |
| 6 | **Kiểm cấu trúc**: đếm FF, đối chiếu với số bit khai báo trong RTL | 3+16+2+2 = 23 ✅ khớp | ✅ |
| 7 | **STA** với SDC nêu rõ 4 giả định | `timing_report_max.txt` | ✅ slack 8,09 ns |
| 8 | **Physical design** (floorplan → GDS) bằng LibreLane + sky130A | GDS + DRC/LVS sạch | ⬜ chưa chạy |

Bước 4 là bước đang hỏng, và nó chặn mọi khẳng định về chức năng. **Không được đi tiếp
bước 8 khi bước 4 còn đỏ** — có GDS của một mạch sai thì vẫn là mạch sai.

Một chi tiết về thứ tự bị bỏ sót trong hồ sơ này: bước 6 (kiểm cấu trúc) đáng ra phải phát
hiện sớm rằng 23 ≫ 6–8, và đặt câu hỏi "vì sao". Ở đây nó chỉ được dùng để xác nhận "có FF
⇒ đúng là mạch tuần tự", tức dùng chưa hết công suất.

## 6. Số liệu thật đã đo được và cách đọc chúng

| Chỉ số | Giá trị | Nguồn |
|---|---:|---|
| Số cell | 88 | `synth_stat.txt` |
| Flip-flop | 23 | ″ |
| Diện tích | 892,1056 µm² | ″ |
| Startpoint → Endpoint | `digit_valid` → `_131_` (= `d0[0]`) | `sta/summary.txt` |
| Data arrival | 1,78 ns | `sta/timing_report_max.txt` |
| Slack | 8,09 ns (MET) | ″ |
| Số cell trên đường tới hạn | 5 | ″ |
| Công suất tổng | 1,08e-04 W | `power/power_report.txt` |
| — Sequential | 9,86e-05 W = **91,4 %** | ″ |
| — Combinational | 9,29e-06 W = 8,6 % | ″ |
| — Internal / Switching | 94,7 % / 5,3 % | ″ |

**Những số này CHỨNG MINH:**
- Thiết kế **tổng hợp được** ra standard cell sky130 thật, không phải mã giả.
- Thiết kế **là mạch tuần tự** (23 cell tuần tự > 0), đúng phân loại Charter.
- Với **giả định** period 10 ns và IO delay 1 ns, đường dài nhất chỉ dùng hết 1,78/9,87 ns
  ⇒ timing **không phải** ràng buộc của đề này.
- Kiểm toán 23 FF = 3 + 16 + 2 + 2 chứng minh **không có thanh ghi nào bị suy ra ngoài ý
  muốn** (không latch, không FF thừa).
- Công suất tuần tự 91,4 % chứng minh **flip-flop là khoản chi chính** ⇒ muốn tiết kiệm thì
  phải bớt FF, không phải bớt cổng logic.

**Những số này KHÔNG chứng minh:**
- **Không** chứng minh mạch đúng chức năng. Mô phỏng FAIL (`known_issues.md`).
- **Không** cho phép nói "F03 chạy được ở 100 MHz". `10,0 ns` là giả định khởi điểm trong
  `design.sdc`, không phải yêu cầu hệ thống; và đây là STA **sau tổng hợp**, chưa có ký
  sinh dây RC, chưa có CTS, chỉ một góc PVT (`tt_025C_1v80`).
- **Không** chứng minh diện tích 892 µm² là diện tích cuối. Chưa chạy floorplan; với thiết
  kế nhỏ thế này, diện tích nhiều khả năng do **số chân IO** quyết định (`floorplan/README.md`).
- **Không** chứng minh công suất 1,08e-04 W là công suất thật — đây là ước lượng của OpenSTA
  với activity mặc định, không phải từ VCD của một ca chạy thật.
- **Không** áp dụng cho module mà testbench kiểm: sim chạy `f03_lock_scaffold`, tổng hợp
  chạy `f03_lock_scaffold_explicit` (`known_issues.md` §3.3).

**Hai con số đáng đặt câu hỏi nhất:**

*88 cell so với ước lượng Charter 230–330.* Nhỏ hơn gần ba lần. Hai nguyên nhân đã xác
định: (a) comparator bị hằng-số-hoá còn 5 cổng, (b) thiết kế **thiếu** 5 bit ra mà Charter
mục 4 đòi. Khi bổ sung đủ cổng ra, con số sẽ tăng.

*23 FF so với ước lượng Charter 6–8.* Lớn hơn gần ba lần. Nguyên nhân duy nhất: 16 FF bộ
đệm mã. Ba thứ Charter thật sự hỏi (`pos` 2 + `fails` 2 + `state` 3) đúng bằng **7 FF** —
nằm gọn trong khoảng Charter dự đoán.

## 7. Trả lời các câu hỏi kỹ thuật của Charter (mục 2)

**Câu 1 — Ba thứ phải nhớ cùng lúc tốn tổng bao nhiêu ô nhớ?**
**7 flip-flop**: `pos[1:0]` = 2 (`_147_`,`_148_`), `fails[1:0]` = 2 (`_149_`,`_150_`),
`state[2:0]` = 3 (`_128_`…`_130_`). Khớp ước lượng Charter mục 10 (6–8). Tổng FF của thiết
kế là **23** vì có thêm 16 FF bộ đệm mã nhập — không thuộc ba thứ Charter hỏi. Một ghi chú
đáng nêu: `state` dùng 3 bit cho 4 trạng thái vì khai báo `logic [2:0]`; thu về `logic [1:0]`
sẽ tiết kiệm 1 FF mà không mất gì.

**Câu 2 — Vì sao khoá tạm chỉ thoát được bằng reset, và đánh đổi cái gì?**
Vì `LOCKED_ST` là trạng thái hấp thụ về mặt **cấu trúc**: `case(state)` không có nhánh nào
rời nó, nên trong netlist không tồn tại đường logic nào đưa `state` khỏi `3'b011`. `rst_n`
được xử lý ngoài `case` (dòng 21) nên là lối ra duy nhất. **Đánh đổi:** được 0 flip-flop
cho cơ chế khoá (một timeout 30 s ở 100 kHz cần ~22 FF, gần gấp đôi phần điều khiển hiện
tại) và một tính chất bất biến chứng minh được bằng cấu trúc; mất trải nghiệm người dùng và
phải có hạ tầng reset vật lý có kiểm soát ở ngoài chip.

**Câu 3 — Bằng chứng nào chứng minh 'sai ba lần LIÊN TIẾP'?**
Dòng 36: `fails<=0;` trong nhánh mã đúng. Mỗi lần thử đúng xoá sạch bộ đếm ⇒ `fails` đo số
lần sai *kể từ lần đúng gần nhất*. Đó là bằng chứng **đọc mã**. Bằng chứng **thực thi**
tương ứng phải là ca C-2' (sai 2 → đúng → sai 2 ⇒ tổng 4 lần sai mà không khoá), và ca này
**hiện chưa có trong testbench** (`corner_cases.md` §2). Phải nói thẳng: khẳng định này mới
được chứng minh một nửa.

## 8. Trả lời câu phân tích riêng (Charter mục 9)

> *Thiết kế lưu mã đúng ở đâu — hằng số trong RTL hay thanh ghi?*

**Lựa chọn: hằng số** — `parameter logic [3:0] SECRET0=4'd1, SECRET1=4'd2, SECRET2=4'd3,
SECRET3=4'd4` (RTL dòng 5–8).

**Hệ quả đo được, bốn bằng chứng:**

1. **0 flip-flop cho mã.** Kiểm toán 23 FF: 3 (`state`) + 16 (`d0..d3`) + 2 (`pos`) + 2
   (`fails`) = 23. Không thừa một FF nào. Phương án "mã trong thanh ghi" sẽ cho 39.

2. **Comparator co từ ~20 cổng xuống 5 cổng.** `netlist.v` dòng 114–148 chỉ có 4 cổng
   4-đầu-vào (`nor4b_1` ×3, `nor4bb_1` ×1) + 1 `and4_1` + 1 `nand4_1` (bản đảo).

3. **Mã bí mật biến thành cực tính chân cổng — và đọc được từ netlist:**

   | Cổng | Chân thường (phải = 0) | Chân `_N` (phải = 1) | ⇒ digit | SECRET |
   |---|---|---|---:|---:|
   | `_068_` | d0[3],d0[2],d0[1] | d0[0] | 1 | 1 ✅ |
   | `_069_` | d1[3],d1[2],d1[0] | d1[1] | 2 | 2 ✅ |
   | `_066_` | d2[3],d2[2] | d2[1],d2[0] | 3 | 3 ✅ |
   | `_067_` | d3[3],d3[1],d3[0] | d3[2] | 4 | 4 ✅ |

   **Đây là hệ quả bảo mật thật:** ai có netlist hoặc soi được layout là có mã. Trong sản
   phẩm thật, mã phải nằm trong OTP/eFuse — nhưng đó là **ngoài phạm vi** Charter mục 3.

4. **Đường tới hạn không đi qua comparator.** Endpoint là `_131_` (= `d0[0]`), tức đường
   nạp. Hằng-số-hoá làm comparator rẻ tới mức nó biến mất khỏi 10 đường chậm nhất.

**Kết luận cân bằng:** hằng số thắng về diện tích, công suất và timing; thua hoàn toàn về
bảo mật và tính linh hoạt. Với phạm vi Charter (mã cố định, không đổi lúc chạy), đây là
lựa chọn đúng — miễn là **ghi rõ giới hạn bảo mật** thay vì im lặng.

## 9. Những chỗ sinh viên hay sai và cách phát hiện

| # | Sai lầm | Hậu quả | Phát hiện bằng bằng chứng nào |
|---:|---|---|---|
| 1 | **Không xoá `fails` khi nhập đúng** | Thành "sai ba lần tổng cộng". Người dùng bình thường bị khoá sau vài tuần. Đúng "chỗ hay tắc" Charter mục 10. | Chạy ca **C-2'**: sai 2 → đúng → sai 2. Nếu `locked` lên ⇒ sai. Hoặc đọc mã: tìm `fails<=0` trong nhánh đúng — nếu không có, sai. |
| 2 | **Quên rằng trạng thái xung (`UNLOCK_ST`) tiêu tốn một chu kỳ** | Chữ số đầu của lần thử kế bị nuốt. **Đây chính là lỗi đang có trong F03.** | `simulation.log` `$fatal` tại t=176; dựng lại bảng sự kiện ở `known_issues.md` §2. Cách phát hiện chủ động: liệt kê mọi cung chuyển trạng thái, với mỗi cung hỏi "nếu `digit_valid=1` trong chu kỳ này thì sao?" |
| 3 | **Off-by-one ngưỡng khoá** (`fails==3` thay vì `fails==2`) | Khoá ở lần sai thứ **tư**. | Chạy ca C-3 và đếm chính xác số lần thử trước khi `locked` lên. Hoặc đọc mã: nhớ rằng so sánh xảy ra *trước* khi tăng. |
| 4 | **Giữ `digit_valid` ở mức cao nhiều chu kỳ** (lỗi tích hợp, không phải lỗi RTL) | Nạp nhiều chữ số cho một lần nhấn phím; mã người dùng hỏng hoàn toàn. | Xem waveform: `pos` nhảy nhiều bậc trong một lần nhấn. Ca C-6 (`corner_cases.md` §2) bắt đúng điều này. Cách chặn: ghi vào hợp đồng interface (`control.md` §4). |
| 5 | **Tưởng `unlock` là mức, không phải xung** | Tầng ngoài lấy mẫu ở clock chậm hơn sẽ bỏ sót; hoặc tệ hơn, giữ cửa mở mãi. | INV-6 (`unlock |=> !unlock`). Trên waveform: `unlock` chỉ cao đúng 1 chu kỳ (`timing_diagram.md` §1, C10). |
| 6 | **Quên nhánh `default` cho mã trạng thái thừa** | 3 bit ⇒ 4 mã thừa; nếu không xử lý, tool suy ra latch hoặc mạch treo sau SEU. | Đọc RTL tìm `default`. Kiểm netlist: đếm cell latch (`dlxtp`, `dlatch`) — F03 có **0** ⇒ sạch. F03 **có** `default` ✅ nhưng **không** xoá `pos`/`fails` — thiếu sót nhỏ hơn, xem `fsm.md` §6. |
| 7 | **Đọc slack 8,09 ns thành "chạy được ở 550 MHz"** | Phát biểu vượt mức, sai về phương pháp. | `design.sdc` ghi rõ 10 ns là *giả định khởi điểm*; `timing.md` §3 liệt 4 giả định (period, IO delay, PVT, chưa có RC). STA sau tổng hợp không phải STA sign-off. |
| 8 | **Nhầm số flip-flop "cần" với số flip-flop "có"** | Trả lời Charter mục 2 câu 1 là "23" trong khi câu hỏi chỉ hỏi ba thứ (= 7). | Kiểm toán từng FF trong netlist theo tên `.Q()`: `state[0..2]`, `d0..d3`, `pos[0..1]`, `fails[0..1]`. Phân loại rồi mới cộng. |
| 9 | **Testbench kiểm module A, tổng hợp module B** | Mọi số liệu vật lý nói về một thiết kế chưa từng được mô phỏng. | So `f03_tb.sv` dòng 7 (`f03_lock_scaffold`) với `synth_stat.txt` (`f03_lock_scaffold_explicit`). **F03 đang mắc lỗi này.** |
| 10 | **Viết đặc tả sau khi viết RTL** | Đặc tả trở thành bản mô tả RTL, không còn khả năng bắt lỗi RTL. | Dấu hiệu: đặc tả "đúng" ở mọi chỗ RTL sai. Cách chặn: viết mô hình chuẩn bằng ngôn ngữ khác **trước** — F03 đã làm đúng, và chính mô hình Python là thứ chứng minh RTL sai. |

## 10. Câu hỏi mentor nên đặt khi bảo vệ

| # | Câu hỏi | Đáp án mong đợi |
|---:|---|---|
| 1 | Chỉ cho tôi **dòng lệnh** làm cho đây là "sai ba lần liên tiếp" chứ không phải "tổng cộng". | Dòng 36, `fails<=0;` trong nhánh mã đúng. Kèm ca C-2' để chứng minh bằng mô phỏng — và thừa nhận ca đó chưa có. |
| 2 | Thiết kế có 23 flip-flop. Charter nói 6–8. Ai sai? | Không ai sai. Charter hỏi ba thứ (`pos`+`fails`+`state` = 7 FF, nằm trong 6–8). 16 FF còn lại là bộ đệm mã — lựa chọn kiến trúc có ý thức, đổi diện tích lấy chống-timing-attack và khả năng mở rộng. |
| 3 | Đường tới hạn kết thúc ở `_131_`. `_131_` là cái gì, và vì sao nó chậm nhất? | `_131_.Q = d0[0]` (netlist dòng 490–493) — bit 0 của thanh ghi chữ số đầu. Chậm nhất vì: (a) chịu 1,00 ns input delay của SDC, (b) cổng `_083_ nor3` có fanout 4 lái 4 mux, tốn 0,46/0,78 ns logic. **Không phải** vì nó sâu. |
| 4 | Mã bí mật nằm ở đâu trong silicon? Chỉ cho tôi. | Không nằm ở flip-flop nào. Nó nằm ở **cực tính chân cổng** của `_066_`…`_069_`. Giải mã ra đúng 1,2,3,4. Hệ quả: đọc netlist là đọc được mã. |
| 5 | Mô phỏng FAIL. Lỗi ở RTL, mô hình chuẩn, testbench hay công cụ? | RTL. Lập luận ba bước: (a) `iverilog_compile.log` sạch ⇒ không phải công cụ; (b) mô hình Python PASS và quy định chữ số sau `UNLOCK` phải được nhận ⇒ không phải mô hình; (c) khiếm khuyết có mặt trong **cả hai** module RTL viết theo hai phong cách ⇒ lỗi thiết kế, không phải gõ nhầm. |
| 6 | Nếu đổi `unlock` từ Moore sang Mealy thì lỗi đó còn không? | Không. Trạng thái `UNLOCK_ST` biến mất, không còn chu kỳ nào nuốt chữ số. Đổi lại: `unlock` thành hàm của đầu vào ⇒ có thể glitch, và độ trễ giảm từ 2 chu kỳ xuống 1. Đây đúng là đánh đổi mà đề **F04** khảo sát trực tiếp. |
| 7 | Vì sao `state` dùng 3 bit cho 4 trạng thái? Tool có tự thu lại không? | Vì khai báo `logic [2:0]`. Tool **không** thu: netlist có đủ `_128_`,`_129_`,`_130_` và tổng FF là 23 = 3+16+2+2. Thu về `logic [1:0]` tiết kiệm 1 FF (4,3 % số FF, mà FF chiếm 91,4 % công suất). |
| 8 | Slack 8,09 ns. Vậy mạch chạy được bao nhiêu MHz? | **Không trả lời được từ số này.** 10 ns là giả định trong `design.sdc`; đây là STA sau tổng hợp, chưa có RC dây, chưa có CTS, một góc PVT. Muốn biết phải chạy STA sau routing, nhiều góc. |
| 9 | Chuyện gì xảy ra nếu `state` bị nhiễu thành `3'b101`? | `default` (dòng 45) đưa về `WAIT_ST`. Nhưng `pos` và `fails` **không** được xoá ⇒ lần nhập kế lệch pha và ngưỡng khoá có thể đã bị tiêu hao. Bản vá: thêm `pos<=0; fails<=0;` vào `default`. |
| 10 | Hồ sơ này chứng minh được gì, và chưa chứng minh được gì? | Chứng minh: tổng hợp được (88 cell), là mạch tuần tự (23 FF), đủ nhanh với giả định 10 ns (slack 8,09), mô hình chuẩn đúng. Chưa chứng minh: chức năng đúng (sim FAIL), giao diện đúng Charter mục 4 (thiếu 5 bit ra), timing thật (chưa P&R), DRC/LVS (chưa chạy). |
| 11 | Testbench khởi tạo module nào? Yosys tổng hợp module nào? | `f03_lock_scaffold` vs `f03_lock_scaffold_explicit`. **Hai module khác nhau.** Đây là đứt gãy truy vết phải vá (`known_issues.md` P-3), độc lập với lỗi chức năng. |

## 11. Giới hạn: đã chứng minh được gì, chưa chứng minh được gì

**Đã chứng minh, có bằng chứng file:**

- RTL biên dịch sạch bằng Icarus Verilog 12.0 — `iverilog_compile.log`.
- RTL tổng hợp được ra 88 standard cell sky130, 23 flip-flop, 892,1056 µm² — `synth_stat.txt`.
- Không có latch nào bị suy ra ngoài ý muốn; kiểm toán FF khớp chính xác với khai báo RTL.
- Với giả định period 10 ns, IO delay 1 ns, góc `tt_025C_1v80`: đường dài nhất 1,78 ns,
  slack 8,09 ns (MET) — `timing_report_max.txt`.
- Ước lượng công suất 1,08e-04 W, trong đó tuần tự 91,4 % — `power_report.txt`.
- Mô hình chuẩn Python độc lập chạy PASS — `python_reference_run.log`.
- Mã bí mật được hằng-số-hoá hoàn toàn, chiếm 0 flip-flop, và đọc được từ netlist.

**Chưa chứng minh được — và cần gì để chứng minh:**

| Chưa chứng minh | Cần gì |
|---|---|
| **Chức năng đúng đặc tả** | Sửa khiếm khuyết §3 (`known_issues.md` P-1/P-2), chạy lại mô phỏng tới `$finish` |
| 3/4 ca bắt buộc Charter mục 8 | Như trên — testbench hiện dừng ở ca thứ hai |
| "Sai ba lần **liên tiếp**" bằng thực thi | Thêm ca C-2' (`corner_cases.md` §2) |
| Giao diện đúng Charter mục 4 | Bổ sung `uo_out[3:2]` (vị trí) và `uo_out[6:4]` (số lần sai, **3 bit**) + wrapper Tiny Tapeout; rồi chạy lại toàn bộ tổng hợp/STA/power |
| Bằng chứng mô phỏng áp dụng cho module đã tổng hợp | Thống nhất một top duy nhất (`known_issues.md` P-3) |
| Netlist tương đương RTL | Mô phỏng gate-level (L4) — ⬜ chưa chạy |
| Hành vi sau power-up khi FF ở `X` | Mô phỏng gate-level có thả `X` — ⬜ chưa chạy |
| Timing thật | STA **sau routing**, nhiều góc PVT — cần LibreLane + sky130A |
| Diện tích cuối cùng | Floorplan + placement + routing — ⬜ chưa chạy |
| Không có glitch trên `unlock` | Mô phỏng post-layout có back-annotate SDF (L5) — ⬜ chưa chạy |
| DRC/LVS sạch | Magic/KLayout + Netgen — ⬜ chưa chạy |
| Mã trạng thái thừa thật sự về `WAIT_ST` trong silicon | Mô phỏng gate-level ép `state` vào `3'd4`…`3'd7` — ⬜ chưa chạy |

**Không thuộc phạm vi đề, không được tuyên bố:** tape-out, chế tạo, kiểm tra sau chế tạo,
ASIC sign-off, thiết kế analog mức transistor, physical design tự làm (Charter mục 3).

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
