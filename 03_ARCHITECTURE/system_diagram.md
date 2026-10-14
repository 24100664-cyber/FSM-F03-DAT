# F03 · Sơ đồ hệ thống (System Diagram)

---

## 1. Bối cảnh ứng dụng — tủ đồ điện tử

Charter mục 1: *"Khối kiểm tra mã mở khoá tủ đồ điện tử, khoá tạm sau ba lần sai để chống dò mã."*
F03 là **bộ não logic**, không phải cả sản phẩm:

```
            ┌──────────── TỦ ĐỒ ĐIỆN TỬ (ngoài phạm vi trừ khối giữa) ─────────────┐
            │                                                                       │
 ┌────────┐ │  ┌──────────────┐   digit[3:0]   ╔═══════════════════╗   unlock       │  ┌──────────┐
 │ Người  │─┼─▶│ Bàn phím 12  │───────────────▶║                   ║───────────────┼─▶│ Driver   │
 │ dùng   │ │  │ phím + khử   │   digit_valid  ║   ►►►  F03  ◄◄◄   ║                │  │ solenoid │
 └────────┘ │  │ rung (debounce)──────────────▶║  f03_lock_scaffold║   locked       │  │ + chốt   │
            │  └──────────────┘                ║    _explicit      ║───────────────┼─▶│ cơ khí   │
            │         ▲                        ║                   ║                │  └──────────┘
            │         │ quét phím              ╚═══════════════════╝                │       │
            │  ┌──────┴───────┐                   ▲         ▲                       │       ▼
            │  │ Bộ đồng bộ   │                   │ clk     │ rst_n                 │  ┌──────────┐
            │  │ 2 FF (CDC)   │            ┌──────┴─────────┴──────┐                │  │ Cửa tủ   │
            │  └──────────────┘            │ Nguồn clock + mạch    │                │  └──────────┘
            │                              │ power-on-reset (POR)  │                │
            │                              └───────────────────────┘                │
            │                                         ▲                             │
            │                              ┌──────────┴────────────┐                │
            │                              │ Nút reset của nhân viên│  ← lối THOÁT  │
            │                              │ quản lý (khoá vật lý)  │    khoá tạm    │
            │                              └───────────────────────┘                │
            └───────────────────────────────────────────────────────────────────────┘
```

> **Điểm thiết kế đáng chú ý của bối cảnh này:** vì `LOCKED_ST` chỉ thoát được bằng `rst_n`
> (INV-2), lối ra khoá tạm **nằm ngoài khối** và là một hành động **vật lý có kiểm soát**
> (nhân viên quản lý). Đó chính là đánh đổi mà Charter mục 2 câu 2 hỏi: đổi sự tiện lợi của
> người dùng lấy việc không cần bộ đếm thời gian nào trong silicon.

## 2. Ranh giới khối — cái gì thuộc F03, cái gì không

| Chức năng | Thuộc F03? | Ai làm nếu không |
|---|:-:|---|
| Quét bàn phím, mã hoá phím → 4 bit | ❌ | Bộ quét phím ở tầng ngoài |
| Khử rung phím (debounce) | ❌ | Mạch debounce — **bắt buộc**, vì F03 nạp một chữ số mỗi chu kỳ có `digit_valid=1` |
| Tạo xung `digit_valid` đúng **1 chu kỳ** mỗi lần nhấn | ❌ | Tầng ngoài. Nếu giữ mức nhiều chu kỳ, F03 nạp nhiều chữ số (xem `functional_spec.md` §7) |
| Đồng bộ hoá tín hiệu từ miền clock bàn phím | ❌ | Bộ đồng bộ 2 FF ở tầng ngoài (`interface.md` §4) |
| **Gom 4 chữ số thành một lần thử** | ✅ | — |
| **So mã với mã bí mật** | ✅ | — |
| **Đếm số lần sai liên tiếp** | ✅ | — |
| **Vào và giữ trạng thái khoá tạm** | ✅ | — |
| Kéo dài `unlock` (1 chu kỳ) thành xung đủ để nhả solenoid | ❌ | Bộ kéo dài xung / mạch công suất ở tầng ngoài. **F03 chỉ phát 1 chu kỳ** (INV-6). |
| Cấp dòng cho solenoid | ❌ | Mạch công suất (analog) |
| Lưu mã bí mật bền vững qua mất điện | ❌ | **Ngoài phạm vi** Charter mục 3. Ở đây mã là hằng số trong logic. |
| Hiển thị vị trí đang nhập / số lần sai | ❌ **hiện tại** | ⚠️ Charter mục 4 **đòi** F03 xuất 2 bit vị trí + 3 bit số lần sai, nhưng RTL không có — xem cảnh báo đầu `02_SPECIFICATION/functional_spec.md` |

## 3. Phân loại — F03 là khối **số thuần tuý (digital)**

| Bằng chứng | Nguồn |
|---|---|
| 23 cell tuần tự `dfxtp_1`, 65 cell tổ hợp, 0 macro analog | `06_GDSII/synthesis/synth_stat.txt` |
| Công suất nhóm Macro = 0,0 %, nhóm Pad = 0,0 % | `06_GDSII/power/power_report.txt` |
| Chỉ dùng thư viện `sky130_fd_sc_hd` (standard cell số) | `06_GDSII/synthesis/netlist.v` |

Ranh giới analog/số nằm **hẳn bên ngoài**: bàn phím (cơ-điện) và driver solenoid (công suất).

## 4. Vòng đời RTL → GDSII — trạng thái THẬT của F03

```
  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
  │ Đặc tả        │→ │ RTL           │→ │ Mô phỏng RTL  │→ │ Tổng hợp      │
  │ (Charter)     │  │ SystemVerilog │  │ Icarus 12.0   │  │ Yosys 0.33    │
  │      ✅       │  │      ✅       │  │   ⚠️ FAIL    │  │      ✅       │
  └───────────────┘  └───────────────┘  └───────────────┘  └───────────────┘
                                          │                        │
                        Python reference ✅│                        ▼
                        (python_reference_ │            ┌───────────────┐
                         run.log)          │            │ STA (OpenSTA  │
                                           │            │ 3.1.0)   ✅   │
                                           │            │ slack 8,09 ns │
                                           │            └───────────────┘
                                           │                        │
                                           ▼                        ▼
                               05_VERIFICATION/         ┌───────────────┐
                               known_issues.md          │ Power (ước    │
                               (phán xử lỗi)            │ lượng)   ✅   │
                                                        │ 1,08e-04 W    │
                                                        └───────────────┘
                                                                 │
  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  ┌─────┴─────────┐
  │ GDS           │← │ DRC / LVS     │← │ Routing       │← │ Floorplan +   │
  │      ⬜       │  │      ⬜       │  │      ⬜       │  │ Placement +   │
  │               │  │               │  │               │  │ CTS      ⬜   │
  └───────────────┘  └───────────────┘  └───────────────┘  └───────────────┘
        ⬛ Tape-out · chế tạo · kiểm tra sau chế tạo — NGOÀI PHẠM VI (Charter mục 3)
```

| Ký hiệu | Nghĩa | Bước |
|:-:|---|---|
| ✅ | đã chạy, có log | Đặc tả · RTL · Python reference · Tổng hợp · STA · Power |
| ⚠️ | đã chạy nhưng **không đạt** | Mô phỏng RTL — `$fatal` ở `f03_tb.sv:41`, t = 176 |
| ⬜ | chưa chạy, **có thể chạy** | Floorplan · Placement · CTS · Routing · DRC · LVS · GDS — cần PDK sky130A + LibreLane |
| ⬛ | **không áp dụng** — ngoài phạm vi đề | Tape-out, chế tạo, kiểm tra sau chế tạo |

Nguồn của bảng trạng thái: `06_GDSII/physical_report.md` §1 và `05_VERIFICATION/verification_report.md` §2.

> **Đọc đúng biểu đồ này:** nhánh *vật lý* (Tổng hợp → STA → Power) đã đi được ba bước và
> cho số thật; nhánh *chức năng* mới chỉ có mô hình Python đạt, còn mô phỏng RTL thì dừng
> giữa chừng. Nói cách khác: **hồ sơ hiện chứng minh mạch tổng hợp được và đủ nhanh, chưa
> chứng minh mạch đúng.**

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
