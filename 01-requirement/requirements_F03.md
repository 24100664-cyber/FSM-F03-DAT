# YÊU CẦU KỸ THUẬT (REQUIREMENTS) – F03

**Đề tài:** FSM khóa số bốn chữ số có khóa tạm  
**Môn học:** EEE703128 – Nhập môn Thiết kế Vi mạch Tích hợp  
**Loại mạch:** Mạch tuần tự – Finite State Machine (FSM)

## 1. Yêu cầu chức năng (Functional Requirements)

| Mã yêu cầu | Tên yêu cầu | Mô tả yêu cầu | Mức độ | Cách kiểm chứng |
| :--- | :--- | :--- | :---: | :--- |
| FR-01 | Nhận chữ số đầu vào | Mạch phải nhận chữ số từ `ui_in[3:0]` khi tín hiệu xác nhận `ui_in[4]` được kích hoạt. | Bắt buộc | Mô phỏng việc nhập từng chữ số và quan sát `position`. |
| FR-02 | Nhập mã bốn chữ số | Mạch phải theo dõi tiến trình nhập đủ bốn chữ số trước khi đánh giá mã mở khóa. | Bắt buộc | Nhập lần lượt bốn chữ số và kiểm tra thời điểm đánh giá mã. |
| FR-03 | Nhận biết mã đúng | Khi bốn chữ số nhập vào khớp với mã đúng được cấu hình, mạch phải kích hoạt tín hiệu mở khóa `uo_out[0]`. | Bắt buộc | Nhập đúng mã và kiểm tra `uo_out[0]`. |
| FR-04 | Nhận biết mã sai | Khi hoàn tất một lượt nhập có mã không khớp, mạch phải ghi nhận một lần nhập sai. | Bắt buộc | Nhập một mã sai hoàn chỉnh và kiểm tra bộ đếm sai. |
| FR-05 | Đếm số lần sai liên tiếp | Mạch phải theo dõi số lượt nhập sai liên tiếp thông qua `uo_out[6:4]`. | Bắt buộc | Nhập nhiều mã sai liên tiếp và quan sát bộ đếm. |
| FR-06 | Khóa tạm sau ba lần sai | Sau ba lượt nhập mã sai liên tiếp, mạch phải chuyển sang trạng thái khóa tạm và kích hoạt `uo_out[1]`. | Bắt buộc | Nhập ba mã sai liên tiếp và kiểm tra `uo_out[1]` cùng bộ đếm. |
| FR-07 | Xóa bộ đếm khi nhập đúng | Một lượt nhập mã đúng phải xóa số lần sai liên tiếp về `0`. | Bắt buộc | Nhập sai, sau đó nhập đúng; kiểm tra `uo_out[6:4]`. |
| FR-08 | Duy trì trạng thái khóa | Khi đang khóa tạm, mạch phải giữ trạng thái khóa và không tiếp nhận lượt nhập mới. | Bắt buộc | Sau khi khóa, tiếp tục tác động tín hiệu xác nhận và kiểm tra trạng thái. |
| FR-09 | Thoát khóa bằng reset | Trạng thái khóa tạm chỉ được thoát bằng reset theo yêu cầu của Charter F03. | Bắt buộc | Kích hoạt reset khi đang khóa và kiểm tra trạng thái sau reset. |
| FR-10 | Theo dõi vị trí nhập | Mạch phải xuất vị trí/tiến trình nhập qua `uo_out[3:2]`. | Bắt buộc | Quan sát giá trị đầu ra sau mỗi lần xác nhận chữ số. |
| FR-11 | Reset trạng thái | Reset phải đưa mạch về trạng thái ban đầu, xóa tiến trình nhập và số lần sai, đồng thời hủy trạng thái mở khóa/khóa tạm. | Bắt buộc | Kích hoạt reset ở trạng thái chờ, đang nhập, mở khóa và khóa tạm. |

## 2. Yêu cầu giao diện (Interface Requirements)

| Mã yêu cầu | Tín hiệu | Hướng | Độ rộng | Yêu cầu |
| :--- | :--- | :---: | :---: | :--- |
| IR-01 | `clk` | Input | 1 bit | Cung cấp xung clock cho mạch tuần tự. |
| IR-02 | `rst_n` | Input | 1 bit | Tín hiệu reset tích cực mức thấp theo quy ước giao diện trong bản đặc tả. |
| IR-03 | `ui_in[3:0]` | Input | 4 bit | Mang giá trị chữ số cần nhập. |
| IR-04 | `ui_in[4]` | Input | 1 bit | Xác nhận chữ số đầu vào. |
| IR-05 | `uo_out[0]` | Output | 1 bit | Báo trạng thái mở khóa. |
| IR-06 | `uo_out[1]` | Output | 1 bit | Báo trạng thái khóa tạm. |
| IR-07 | `uo_out[3:2]` | Output | 2 bit | Báo vị trí nhập hiện tại. |
| IR-08 | `uo_out[6:4]` | Output | 3 bit | Báo số lần nhập sai liên tiếp. |

## 3. Yêu cầu kiểm chứng (Verification Requirements)

| Mã yêu cầu | Nội dung | Tiêu chí đạt |
| :--- | :--- | :--- |
| VR-01 | Kiểm thử nhập đúng ngay | Nhập đúng mã sau reset phải kích hoạt tín hiệu mở khóa. |
| VR-02 | Kiểm thử sai một lần rồi đúng | Bộ đếm sai tăng sau lượt sai và trở về `0` sau lượt đúng. |
| VR-03 | Kiểm thử ba lần sai liên tiếp | Mạch phải vào trạng thái khóa tạm sau lượt sai thứ ba liên tiếp. |
| VR-04 | Kiểm thử reset khi khóa | Reset phải đưa mạch ra khỏi trạng thái khóa tạm. |
| VR-05 | Kiểm thử đầu vào/biên bổ sung | Có ít nhất hai ca kiểm thử do người thiết kế tự xây dựng, trong đó có một ca biên; mỗi ca phải nêu rõ lỗi cần phát hiện. |
| VR-06 | Kiểm tra waveform | Waveform phải thể hiện được clock, reset, tín hiệu xác nhận, các đầu ra trạng thái và bộ đếm liên quan; có chú thích giải thích. |
| VR-07 | Kiểm tra tính nhất quán | Hành vi RTL và kết quả mô phỏng phải phù hợp với đặc tả giao diện, quy tắc chuyển trạng thái và yêu cầu chức năng. |

## 4. Yêu cầu triển khai và báo cáo (Implementation & Reporting Requirements)

| Mã yêu cầu | Nội dung | Tiêu chí / sản phẩm |
| :--- | :--- | :--- |
| NFR-01 | Thiết kế RTL | Có mã RTL mô tả FSM, tiến trình nhập mã và bộ đếm số lần sai. |
| NFR-02 | Testbench | Có testbench hoặc test script kiểm tra các ca bắt buộc và ít nhất hai ca tự xây dựng. |
| NFR-03 | Flow RTL-to-GDSII | Đưa thiết kế qua flow RTL-to-GDSII theo quy trình môn học; lưu artifacts hoặc nhật ký lỗi và chẩn đoán nếu flow thất bại. |
| NFR-04 | Phân tích báo cáo | Đọc và giải thích các báo cáo synthesis, STA, power, DRC/LVS và layout dựa trên kết quả thực tế. |
| NFR-05 | Khả năng tái lập | Ghi lại repository, commit, CI run, phiên bản LibreLane, phiên bản PDK và ngày chạy. |
| NFR-06 | Báo cáo cuối kỳ | Nộp báo cáo PDF 8–15 trang, kèm thông tin cần thiết để tái lập kết quả. |
| NFR-07 | Giới hạn kết luận | Không tuyên bố đã sign-off, tape-out, chế tạo chip hoặc đạt một tần số hoạt động cụ thể nếu chưa có bằng chứng phù hợp. |

## 5. Ngoài phạm vi (Out of Scope)

| Mã | Nội dung ngoài phạm vi |
| :--- | :--- |
| OOS-01 | Chế tạo chip, tape-out và sign-off sản xuất. |
| OOS-02 | Thay đổi mã mở khóa trong khi mạch đang hoạt động. |
| OOS-03 | Hỗ trợ nhiều người dùng. |
| OOS-04 | Tự động mở khóa sau một khoảng thời gian; theo Charter, trạng thái khóa tạm chỉ thoát bằng reset. |
| OOS-05 | Lưu mã mở khóa bền vững qua mất nguồn. |

## 6. Các thông tin cần xác nhận trước khi chốt yêu cầu

- [ ] Giá trị cụ thể của mã mở khóa bốn chữ số.
- [ ] Quy ước thời gian của tín hiệu xác nhận `ui_in[4]` (xung một chu kỳ hay có cơ chế chống xác nhận lặp).
- [ ] Hành vi mong muốn khi `ui_in[3:0]` nhận giá trị ngoài miền chữ số thập phân `0`–`9`.
- [ ] `uo_out[0]` là trạng thái mở khóa được giữ đến lượt nhập mới hay chỉ là xung báo mở khóa.
- [ ] Xác nhận quy ước `rst_n` tích cực mức thấp có khớp với top-level và môi trường triển khai.

> **Ghi chú:** Charter F03 quy định các chức năng chính, giao diện Tiny Tapeout, các ca kiểm thử tối thiểu, phạm vi và sản phẩm bàn giao. Những chi tiết chưa được Charter xác định được liệt kê ở Mục 6 để nhóm thống nhất, không mặc nhiên xem là yêu cầu gốc.
