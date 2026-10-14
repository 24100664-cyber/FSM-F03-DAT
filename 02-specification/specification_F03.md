# ĐẶC TẢ KỸ THUẬT (SPECIFICATION) – F03

**Đề tài:** FSM khóa số bốn chữ số có khóa tạm  
**Môn học:** EEE703128 – Nhập môn Thiết kế Vi mạch Tích hợp  
**Loại mạch:** Mạch tuần tự – Finite State Machine (FSM)



## 1\. Bảng Cổng Tín hiệu (Pinout Interface)

|Tên tín hiệu|Hướng|Độ rộng|Miền Clock|Mô tả chức năng|
|-|:-:|:-:|:-:|-|
|`clk`|Input|1 bit|—|Xung nhịp hệ thống dùng để cập nhật FSM, vị trí nhập và bộ đếm số lần sai.|
|`rst\_n`|Input|1 bit|`clk`|Reset bất đồng bộ, tích cực mức thấp (Active-Low). Khi `rst\_n = 0`, xóa tiến trình nhập, số lần sai và trạng thái khóa/mở khóa.|
|`ui\_in\[3:0]`|Input|4 bit|`clk`|Giá trị chữ số đang nhập, mã hóa một chữ số từ `0` đến `9`. Các giá trị `10`–`15` được xem là đầu vào không hợp lệ.|
|`ui\_in\[4]`|Input|1 bit|`clk`|Tín hiệu xác nhận chữ số. Theo giả định thiết kế, mỗi lần xác nhận hợp lệ được biểu diễn bằng một xung mức cao trong một chu kỳ clock; không giữ mức cao qua nhiều chu kỳ.|
|`ui\_in\[7:5]`|Input|3 bit|—|Không sử dụng trong F03; cần bỏ qua và không để ảnh hưởng đến chức năng.|
|`uo\_out\[0]`|Output|1 bit|`clk`|`unlock`: báo mở khóa khi mã bốn chữ số nhập vào đúng.|
|`uo\_out\[1]`|Output|1 bit|`clk`|`locked`: báo đang ở trạng thái khóa tạm sau ba lần nhập sai liên tiếp.|
|`uo\_out\[3:2]`|Output|2 bit|`clk`|`position`: vị trí nhập hiện tại, mã hóa từ `0` đến `3`. `0` nghĩa là chưa nhập chữ số nào trong lượt hiện tại; `1`–`3` là số chữ số đã nhận trước chữ số tiếp theo. Sau khi hoàn tất lượt nhập, vị trí trở về `0`.|
|`uo\_out\[6:4]`|Output|3 bit|`clk`|`attempt\_count`: số lần nhập mã sai liên tiếp, từ `0` đến `3`. Khi đạt `3`, mạch vào trạng thái khóa tạm.|
|`uo\_out\[7]`|Output|1 bit|—|Không sử dụng; xuất `0`.|

### 1.1 Quy ước và giả định giao diện

1. `clk` là clock hệ thống; không ấn định tần số clock trong đặc tả chức năng này. Tần số và chu kỳ dùng cho flow STA phải được ghi riêng trong cấu hình chạy.
2. `rst\_n` là reset bất đồng bộ tích cực mức thấp. Reset có ưu tiên cao nhất và là cách thoát khỏi trạng thái khóa tạm.
3. Một lượt nhập gồm đúng bốn chữ số hợp lệ, mỗi chữ số được chấp nhận khi có xung xác nhận. Chỉ đánh giá mã sau khi nhận đủ bốn chữ số.
4. Chữ số `10`–`15` không thuộc miền chữ số thập phân. Theo giả định thiết kế, khi xác nhận một giá trị như vậy, mạch bỏ qua chữ số đó và giữ nguyên vị trí nhập.
5. Giá trị mã đúng chưa được nêu trong Charter. Mã phải được xác định trong RTL dưới dạng hằng số hoặc các hằng số chữ số; không tự xem giá trị minh họa là mã chính thức.
6. `unlock` được giả định là tín hiệu trạng thái: lên `1` sau khi nhập đúng mã và được xóa khi bắt đầu lượt nhập mới hoặc khi reset. Nếu yêu cầu của hệ thống cần xung mở khóa một chu kỳ, phải sửa quy ước này trước khi viết RTL.
7. `attempt\_count` chỉ đếm các lượt nhập mã sai hoàn chỉnh. Khi nhập đúng mã, bộ đếm được xóa về `0`; vì vậy điều kiện khóa là **ba lượt sai liên tiếp**, không phải ba lượt sai tích lũy.
8. Trong trạng thái khóa tạm, mạch bỏ qua tín hiệu xác nhận và không nhận thêm chữ số cho đến khi reset.

## 2\. Bảng Ưu tiên Mức Điều khiển (Priority Logic Table)

Các điều kiện được xét theo thứ tự ưu tiên từ trên xuống. `X` nghĩa là không quan tâm.

|`rst\_n`|`locked` hiện tại|`ui\_in\[4]`|Điều kiện bổ sung|Hành động / trạng thái kế tiếp|
|:-:|:-:|:-:|-|-|
|`0`|`X`|`X`|Reset được kích hoạt|Xóa vị trí nhập về `0`, xóa số lần sai về `0`, xóa `unlock`; thoát khóa tạm và trở về trạng thái chờ nhập.|
|`1`|`1`|`X`|Chưa có reset|Giữ trạng thái khóa tạm; `locked = 1`, không nhận chữ số mới.|
|`1`|`0`|`0`|Không có xác nhận|Giữ nguyên tiến trình nhập và các bộ đếm; không nhận chữ số mới.|
|`1`|`0`|`1`|`ui\_in\[3:0]` nằm trong `0`–`9`, chưa đủ bốn chữ số|Chấp nhận chữ số, lưu/so sánh với chữ số mã tương ứng và tăng `position` lên `1`.|
|`1`|`0`|`1`|Chữ số xác nhận là `10`–`15`|Bỏ qua giá trị không hợp lệ; giữ nguyên `position` và `attempt\_count`.|
|`1`|`0`|`1`|Đây là chữ số hợp lệ thứ tư và toàn bộ mã đúng|Đặt `unlock = 1`; xóa `attempt\_count = 0`; kết thúc lượt nhập và đưa `position` về `0`.|
|`1`|`0`|`1`|Đây là chữ số hợp lệ thứ tư nhưng mã sai; `attempt\_count < 2`|Đặt `unlock = 0`; tăng `attempt\_count` thêm `1`; kết thúc lượt nhập và đưa `position` về `0`.|
|`1`|`0`|`1`|Đây là chữ số hợp lệ thứ tư nhưng mã sai; `attempt\_count = 2`|Đặt `unlock = 0`; đưa `attempt\_count` lên `3`; chuyển sang trạng thái khóa tạm (`locked = 1`); đưa `position` về `0`.|
|`1`|`0`|`1`|Bắt đầu lượt nhập mới sau trạng thái mở khóa|Xóa `unlock` về `0`, rồi nhận chữ số đầu tiên hợp lệ của lượt mới.|

**Lưu ý về thứ tự cập nhật:** khi xử lý chữ số thứ tư, phải đánh giá mã dựa trên cả bốn chữ số của lượt hiện tại, bao gồm chữ số đang được xác nhận. Không được so sánh trước khi chữ số thứ tư được tính đến. Khi mã đúng, phải xóa số lần sai liên tiếp; nếu không, thiết kế sẽ đếm sai ba lượt sai tổng cộng thay vì ba lượt sai liên tiếp.

## 3\. Quy tắc chức năng và trạng thái

|Trạng thái / thông tin|Quy tắc|
|-|-|
|Chờ nhập (`position = 0`)|Chờ xác nhận chữ số hợp lệ đầu tiên.|
|Đang nhập (`position = 1`–`3`)|Mỗi xung xác nhận với chữ số hợp lệ nhận thêm một chữ số; sau chữ số thứ tư, đánh giá toàn bộ mã.|
|Mở khóa (`unlock = 1`)|Chỉ được bật khi mã bốn chữ số đúng. Xóa tín hiệu này khi bắt đầu lượt nhập mới hoặc khi reset theo giả định tại Mục 1.|
|Nhập sai (`attempt\_count = 1` hoặc `2`)|Sau một lượt mã sai hoàn chỉnh, tăng bộ đếm sai liên tiếp lên một và chờ lượt nhập mới.|
|Khóa tạm (`locked = 1`)|Kích hoạt sau lượt sai hoàn chỉnh thứ ba liên tiếp. Không nhận thêm chữ số; chỉ reset mới thoát khóa.|
|Reset|Xóa trạng thái mở khóa, trạng thái khóa tạm, vị trí nhập và số lần sai; quay về chờ nhập.|

## 4\. Ca kiểm thử chức năng tối thiểu

Trong bảng dưới đây, `C0 C1 C2 C3` là bốn chữ số của mã đúng đã được cấu hình trong RTL. Thay các ký hiệu này bằng mã thực tế khi xây dựng testbench.

|ID|Kích thích|Kết quả mong đợi|Mục đích|
|-|-|-|-|
|TC01|Reset, sau đó nhập đúng `C0 C1 C2 C3`.|`unlock = 1`, `locked = 0`, `attempt\_count = 0`, `position = 0`.|Xác minh đường đi mở khóa cơ bản.|
|TC02|Nhập một mã sai hoàn chỉnh, sau đó nhập đúng mã.|Sau lượt sai: `attempt\_count = 1`; sau lượt đúng: `attempt\_count = 0`, `unlock = 1`.|Xác minh bộ đếm sai được xóa khi nhập đúng.|
|TC03|Nhập ba mã sai hoàn chỉnh liên tiếp.|Sau lượt sai thứ ba: `attempt\_count = 3`, `locked = 1`, `unlock = 0`.|Xác minh ngưỡng khóa tạm.|
|TC04|Sau TC03, tiếp tục xác nhận các chữ số mà không reset.|Vẫn `locked = 1`; trạng thái nhập không tiến triển.|Xác minh khóa tạm không thể bị vượt qua bằng cách tiếp tục nhập.|
|TC05|Sau khi khóa tạm, kích hoạt reset.|`locked = 0`, `attempt\_count = 0`, `position = 0`, `unlock = 0`.|Xác minh reset là cách thoát khóa tạm.|
|TC06 – biên|Xóa trạng thái bằng reset, nhập hai mã sai rồi một mã đúng.|Bộ đếm lần lượt là `1`, `2`, rồi trở về `0`; không khóa tạm.|Bắt lỗi thiết kế không xóa bộ đếm khi nhập đúng hoặc khóa nhầm ở ngưỡng.|
|TC07 – biên|Khi `position = 0`, xác nhận giá trị `10` hoặc `15`.|Giá trị bị bỏ qua; `position` và `attempt\_count` không đổi.|Xác minh xử lý đầu vào ngoài miền chữ số thập phân theo giả định thiết kế.|
|TC08|Giữ `ui\_in\[4] = 0` trong nhiều chu kỳ khi đang nhập.|Không nhận thêm chữ số; vị trí nhập không thay đổi.|Xác minh mạch chỉ nhận chữ số khi có xác nhận.|

## 5\. Phạm vi và giới hạn

**Trong phạm vi:** đặc tả giao diện; thiết kế RTL cho FSM, vị trí nhập và bộ đếm sai; testbench; kiểm chứng waveform; chạy flow RTL-to-GDSII; đọc và giải thích báo cáo synthesis, STA, power, DRC/LVS và layout trong phạm vi kết quả thực tế thu được.

**Ngoài phạm vi:** chế tạo chip, tape-out, sign-off hoặc tuyên bố thiết kế sẵn sàng sản xuất; thay đổi mã trong lúc hoạt động; nhiều người dùng; tự động mở khóa theo thời gian; lưu mã bền vững qua mất nguồn.

## 6\. Các điểm phải chốt trước khi hoàn thiện RTL

* \[ ] Giá trị mã đúng gồm bốn chữ số.
* \[ ] Cách lưu mã: hằng số trong RTL hay thanh ghi.
* \[ ] Xác nhận `ui\_in\[4]` là xung một chu kỳ hay cần mạch phát hiện cạnh/chống lặp.
* \[ ] Xác nhận `unlock` là trạng thái giữ đến lượt nhập mới hay xung một chu kỳ.
* \[ ] Xác nhận hành vi khi chữ số ngoài miền `0`–`9` được xác nhận.
* \[ ] Xác nhận quy ước reset bất đồng bộ tích cực mức thấp phù hợp với top-level và môi trường Tiny Tapeout đang sử dụng.

> \*\*Giới hạn bằng chứng:\*\* các quy tắc đánh dấu là giả định thiết kế cần được xác nhận trước khi xem là yêu cầu chính thức. Số lượng cell, diện tích, timing, công suất và kết quả DRC/LVS chỉ được điền sau khi chạy flow và đọc báo cáo thực tế; không suy ra từ đặc tả này.

