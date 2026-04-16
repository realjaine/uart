#A complete industrial ASIC DFT flow: From RTL synthesis to Scan Chain Insertion to 99.89% Test Coverage ATPG 🚀

[![Language](https://img.shields.io/badge/Language-Verilog-yellow.svg)](https://en.wikipedia.org/wiki/Verilog)
[![Tools](https://img.shields.io/badge/Tools-Cadence%20Genus%20%7C%20Modus-brightgreen.svg)](https://www.cadence.com)
[![Technology](https://img.shields.io/badge/Technology-90nm-blue.svg)](#)
[![Coverage](https://img.shields.io/badge/Fault%20Coverage-99.89%25-success.svg)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

*A complete industrial ASIC DFT flow: From RTL synthesis to **Scan Chain Insertion** to 99.89% Test Coverage ATPG*

[Features](#-key-highlights) • [Architecture](#-design-architecture) • [Pre vs Post DFT](#-pre-dft-vs-post-dft-comparison) • [Synthesis Results](#-synthesis-key-metrics-90nm-genus) • [DFT & ATPG](#-dft--atpg-deep-dive) • [Repository](#-repository-structure)

---

## 📖 Overview

This project implements a high-reliability **UART (Universal Asynchronous Receiver-Transmitter)** core using a complete industrial-grade **RTL-to-ATPG (Automated Test Pattern Generation)** flow. The design is optimized for a **90nm CMOS technology node**, featuring full scan chain insertion and sign-off level fault coverage verification.

### ✨ Key Highlights

- ✅ **Full Scan Architecture**: 100% register scanability via `muxed_scan` style
- ✅ **High-Coverage ATPG**: Achieved **99.89% static fault coverage** using Cadence Modus
- ✅ **Sign-off Timing Closure**: 50 MHz operation with a massive **13.7 ns setup margin**
- ✅ **Formal Verification**: RTL vs. Gate-Level Netlist (GLN) verified via LEC
- ✅ **Industrial Toolchain**: Powered by Cadence Genus (Synthesis) and Modus (DFT)

---

## 🏗️ Design Architecture

The `uart_top` core follows a modular hierarchy designed for high **observability** and **controllability** during manufacturing tests.

```
uart_top.v (Top Module)
├── uart_rx.v    (Receiver Logic with Sync Stages)
├── uart_tx.v    (Transmitter Logic & Baud Generation)
└── [Scan Chain] (Inserted during DFT Synthesis)
```

### How it Works 🤔

```
                       UART TRANSMIT PATH

┌───────────────────────────────────────────────────────────────┐
│                    PARALLEL DATA IN                           │
│                  tx_data[7:0] + tx_start                      │
└───────────────────────┬───────────────────────────────────────┘
                        │
             ┌──────────▼──────────┐
             │   BAUD RATE GEN     │
             │  (50 MHz / 434)     │  ← 115200 baud
             └──────────┬──────────┘
                        │
             ┌──────────▼──────────┐
             │   SHIFT REGISTER    │
             │  [START | D0..D7 |  │
             │        STOP]        │
             └──────────┬──────────┘
                        │
                  ──────▼──────
                       TX  ──────────────────► Serial Output


                       UART RECEIVE PATH

          Serial Input ────►  SYNC STAGES  ──►  START DETECT
                                                      │
                                           ┌──────────▼──────────┐
                                           │   BIT SAMPLER       │
                                           │ (Sample at mid-bit) │
                                           └──────────┬──────────┘
                                                      │
                                           ┌──────────▼──────────┐
                                           │   SHIFT REGISTER    │
                                           │   (8-bit capture)   │
                                           └──────────┬──────────┘
                                                      │
                                        ┌─────────────▼──────────────┐
                                        │     PARALLEL DATA OUT       │
                                        │         rx_data[7:0]        │
                                        └─────────────────────────────┘


                       DFT SCAN PATH

    scan_in ──► [FF0]──►[FF1]──►...──►[FF53] ──► scan_out
                  ↕       ↕              ↕
               (All 54 flip-flops connected in single scan chain)
               (Controlled by scan_en; transparent to normal op)
```

---

## 🛰️ Interface Specifications

| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `clk` | 1 | Input | System Clock (50 MHz) |
| `rst_n` | 1 | Input | Active-low Reset / Test Mode Control |
| `scan_en` | 1 | Input | DFT: Scan Shift Enable (Active High) |
| `scan_in` | 1 | Input | DFT: Scan Chain Input |
| `scan_out` | 1 | Output | DFT: Scan Chain Output |
| `rx` | 1 | Input | Asynchronous Serial Input |
| `tx` | 1 | Output | Asynchronous Serial Output |
| `tx_data` | 8 | Input | 8-bit Parallel Data for Transmission |
| `tx_start` | 1 | Input | Trigger for Data Transmission |

---

## 📊 Pre-DFT vs Post-DFT Comparison

This table shows the measurable impact of scan chain insertion on area, power, and timing — extracted directly from Cadence Genus reports.

### 🔹 Area & Cell Count

| Metric | Pre-DFT | Post-DFT | Overhead |
|:---|:---|:---|:---|
| **Total Cell Count** | 179 | 209 | **+30 cells (+16.8%)** |
| **Total Cell Area** | 1743.898 μm² | 2145.811 μm² | **+401.913 μm² (+23.1%)** |
| **Sequential Area** | 1233.747 μm² (70.7%) | 1419.944 μm² (66.2%) | **+186.197 μm²** |
| **Combinational Area** | 510.151 μm² (29.3%) | 725.867 μm² (33.8%) | **+215.716 μm²** |
| **Sequential FF Type** | DFFRHQX1 / DFFRXL / DFFSHQX1 | SDFFRHQX1/4/8, SDFFRXL, SDFFSHQX1/2, SDFFSXL | Scan FFs inserted ✅ |
| **Scan FFs** | 0 (normal FFs only) | **54 (100% scan-mapped)** | Full scan ✅ |

> **Note:** The area increase is primarily due to scan mux insertion — each normal FF (DFFRHQX1) is replaced by a scan FF (SDFFRHQX1) which includes an extra multiplexer for the scan path.

---

### 🔹 Power Comparison

| Power Component | Pre-DFT (W) | Post-DFT (W) | Change |
|:---|:---|:---|:---|
| **Internal Power** | 5.872 × 10⁻⁵ (78.35%) | 6.223 × 10⁻⁵ (75.09%) | **+5.98%** |
| **Switching Power** | 7.665 × 10⁻⁶ (10.23%) | 8.638 × 10⁻⁶ (10.42%) | **+12.70%** |
| **Leakage Power** | 8.565 × 10⁻⁶ (11.43%) | 1.200 × 10⁻⁵ (14.48%) | **+40.10%** |
| **Total Power** | **7.495 × 10⁻⁵ (0.0749 mW)** | **8.287 × 10⁻⁵ (0.0829 mW)** | **+10.57%** |

> **Note:** Leakage power increases the most (+40%) because scan FFs are physically larger cells than standard FFs, contributing more static leakage current.

---

### 🔹 Timing Comparison

| Parameter | Pre-DFT | Post-DFT | Impact |
|:---|:---|:---|:---|
| **Clock Period** | 20,000 ps (50 MHz) | 20,000 ps (50 MHz) | No change |
| **Critical Path** | `u_tx_tx_busy_reg/CK → tx_busy` | `tx_start → u_tx_shift_reg_reg[6]/D` | Path changed |
| **Data Arrival Time** | 663 ps | 5,593 ps | Path restructured |
| **Setup Uncertainty** | 500 ps | 500 ps | No change |
| **Worst Setup Slack** | **+13,837 ps** ✅ | **+13,706 ps** ✅ | **−131 ps (minimal)** |
| **DFT Rule Violations** | — | **0** | ✅ Clean |
| **Scannable Registers** | 0% | **100%** | Full scan ✅ |

> **Note:** Timing degradation is only 131 ps — well within margin. The design comfortably meets timing at 50 MHz even after full scan insertion.

---

### 🔹 Summary Snapshot

| Metric | Pre-DFT | Post-DFT | Impact |
|:---|:---|:---|:---|
| Cell Count | 179 | 209 | +16.8% |
| Total Area | 1743.898 μm² | 2145.811 μm² | +23.1% |
| Total Power | 0.0749 mW | 0.0829 mW | +10.57% |
| Worst Slack | +13,837 ps | +13,706 ps | −131 ps |
| Scan FFs | 0 | 54 | ✅ 100% scan-mapped |
| DFT Violations | — | 0 | ✅ |

---

## 📊 Synthesis Key Metrics (90nm Genus)

The design was synthesized using the **slow.lib** corner to ensure worst-case reliability.

### 🧩 Area & Gate Utilization (Post-DFT)

| Metric | Value | File Source |
|:---|:---|:---|
| **Total Cell Area** | 2145.811 μm² | `post_dft_area.rpt` |
| **Total Instance Count** | 209 | `post_dft_gates.rpt` |
| **Sequential Instances** | 54 (All Scan-Mapped) | `post_dft_rules.rpt` |
| **Combinational Area** | 725.87 μm² | `post_dft_gates.rpt` |

### ⚡ Power Breakdown — Post-DFT (Joules Engine)

Vectorless analysis at V_DD = 0.67V:

| Power Component | Value (W) | % of Total | Description |
|:---|:---|:---|:---|
| **Internal Power** | 6.222 × 10⁻⁵ | 75.1% | Power within logic cells |
| **Switching Power** | 8.638 × 10⁻⁶ | 10.4% | Charging/discharging nets |
| **Leakage Power** | 1.200 × 10⁻⁵ | 14.5% | Static power dissipation |
| **Total Power** | **8.286 × 10⁻⁵** | **100%** | **Total consumption (0.082 mW)** |

### ⏱️ Timing Analysis — Post-DFT (Sign-off)

| Parameter | Value | Unit | Description |
|:---|:---|:---|:---|
| **Target Period** | 20,000 | ps | 50 MHz clock |
| **Data Arrival Time** | 5,593 | ps | `tx_start → u_tx_shift_reg_reg[6]/D` |
| **Setup Uncertainty** | 500 | ps | Guard band for jitter |
| **Setup Slack** | **+13,706** | **ps** | ✅ **Sign-off Met** |

---

## GUI Schematic

<img width="974" height="734" alt="gui_schematic" src="https://github.com/user-attachments/assets/1e367f75-ece0-4e2a-8410-15112a1a9379" />

---

## 🛡️ DFT & ATPG Deep-Dive

This project prioritizes **Design-for-Testability**, ensuring that internal faults can be detected post-fabrication.

### 🔗 Scan Chain Configuration

A single, optimized scan chain was inserted to minimize routing overhead while maximizing coverage.

| Parameter | Value |
|:---|:---|
| **Chain Length** | 54 Scan Flip-Flops |
| **Scan Style** | `muxed_scan` using SDFFRHQ library cells |
| **Test Mode** | FULLSCAN |
| **Clock Domain** | `clk_test` (20 ns period) |

## 🧪 Fault Coverage Summary (Modus)

| Category | Total Faults | Tested | Coverage |
| :--- | :--- | :--- | :--- |
| **Static Stuck-at** | 1,786 | 1,784 | 99.89% ✅ |
| **Dynamic Faults** | 1,554 | 330 | 21.24% |

**Total ATPG Cycles:** 2,129  
**Cycle Breakdown:** 77 Test / 2,052 Scan  
**Status:** 100% Generated

| Stage | Tool | Deliverable | Runtime |
|:---|:---|:---|:---|
| **Logic Synthesis** | Cadence Genus | DFT-Inserted Netlist | 6s |
| **Formal Verification** | Conformal LEC | Equivalence Report | — |
| **DFT Rule Check** | Genus | 0 Violations Report | <1s |
| **Model Building** | Cadence Modus | Optimized Fault Model | 6s |
| **ATPG** | Cadence Modus | Stuck-at Test Vectors | 12s |

---

## 📊 Performance Summary

### Design Metrics at a Glance

| Metric | Value | Status |
|:---|:---|:---|
| **Technology Node** | 90nm CMOS | — |
| **Operating Frequency** | 50 MHz (20 ns period) | ✅ Target met |
| **Total Cell Area** | 2,145.811 μm² | Compact |
| **Cell Count** | 209 standard cells | — |
| **Sequential (Scan) FFs** | 54 | ✅ 100% scan-mapped |
| **Power Consumption** | 0.082 mW | ✅ Ultra low power |
| **Timing Slack (WCS)** | +13,706 ps | ✅ Massive margin |
| **DFT Rule Violations** | 0 | ✅ Clean |
| **Static Fault Coverage** | 99.89% | ✅ Sign-off grade |

### Critical Path Analysis

**Post-DFT (Worst Setup Path):**
- Launch: `tx_start`
- Capture: `u_tx_shift_reg_reg[6]/D`
- Data Arrival: 5,593 ps
- Slack: **+13,706 ps** ✅

---

## 📂 Repository Structure

```
uart-dft-core/
├── rtl/                        # UART Verilog Source
│   ├── uart_rx.v               # Serial-to-Parallel Receiver
│   ├── uart_tx.v               # Parallel-to-Serial Transmitter
│   └── uart_top.v              # Core Wrapper (DFT ports included)
│
├── scripts/                    # Automation TCL/DO Scripts
│   ├── run_genus_dft_uart.tcl  # Synthesis & Scan Insertion Automation
│   ├── run_modus_atpg_uart.tcl # ATPG Pattern Generation
│   └── rtl_to_fv_map.do        # LEC Verification Script
│
├── reports/                    # Industrial Log Files
│   ├── pre_dft_area.rpt        # Pre-DFT Area & Cell Count
│   ├── pre_dft_gates.rpt       # Pre-DFT Gate-level Instance Report
│   ├── pre_dft_power.rpt       # Pre-DFT Power Analysis
│   ├── pre_dft_timing.rpt      # Pre-DFT Slack & Path Analysis
│   ├── post_dft_area.rpt       # Post-DFT Area & Cell Count
│   ├── post_dft_gates.rpt      # Post-DFT Gate-level Instance Report
│   ├── post_dft_power.rpt      # Post-DFT Joules Power Analysis
│   ├── post_dft_rules.rpt      # DFT Rule Check (0 violations)
│   ├── post_dft_timing.rpt     # Post-DFT Slack & Path Analysis
│   └── test_coverage.rpt       # 99.89% Fault Summary
│
├── fv/                         # Formal Verification
│   └── fv_map.fv.json          # RTL-to-Gate Mapping (LEC)
│
└── logs/                       # Raw Execution Logs
    ├── genus.log               # Synthesis Execution Log
    └── modus.log               # ATPG Run Log
```

---

## 🎯 Learning Outcomes

This project demonstrates hands-on proficiency in:

1. ✅ **Industrial DFT Insertion**: Expertise in scan chain synthesis and `muxed-scan` conversion
2. ✅ **Advanced ATPG**: Proficiency in fault modeling (Static/Dynamic) using Cadence Modus
3. ✅ **Timing Sign-off**: Understanding slack calculation, uncertainty, and setup/hold metrics
4. ✅ **Formal Sign-off**: Utilizing mapping files for Logical Equivalence Checking (LEC)
5. ✅ **RTL Design**: Modular Verilog implementation with DFT-aware architecture
6. ✅ **Power Analysis**: Vectorless power estimation using Cadence Joules engine

---

## 💻 Technology Stack

| Category | Tools & Technologies |
|:---|:---|
| **HDL** | Verilog HDL (IEEE 1364-2001) |
| **Synthesis** | Cadence Genus |
| **DFT & ATPG** | Cadence Modus |
| **Formal Verification** | Cadence Conformal LEC |
| **Technology Library** | 90nm CMOS Standard Cells (slow.lib corner) |
| **Operating System** | Linux (CentOS/RHEL) |

---

## 🤝 Contributing

Contributions are welcome! Here are some areas for improvement:

### Future Enhancements

- 🔧 Port to advanced technology nodes (65nm, 45nm, 28nm)
- 🔧 Implement full RTL-to-GDSII physical design flow
- 🔧 Add dynamic fault (transition fault) ATPG coverage improvement
- 🔧 Extend to UART with FIFO buffers and flow control (RTS/CTS)
- 🔧 Add boundary scan (JTAG/IEEE 1149.1) support
- 🔧 Evaluate power-aware test compression techniques

### How to Contribute

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -m 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a pull request

---

## 📚 References

1. **IEEE 1149.1** – Standard for Boundary-Scan Architecture (JTAG)
2. **Cadence Design Systems** – Genus & Modus User Guides
3. **Bushnell, M. & Agrawal, V.** – *Essentials of Electronic Testing*, Springer
4. **Weste, N. & Harris, D.** – *CMOS VLSI Design*, Addison-Wesley
5. **Wang, L-T et al.** – *Electronic Design Automation*, Morgan Kaufmann

---

## 🎓 Academic Information

| | |
|:---|:---|
| **Project** | DFT & ATPG Suite for UART Core |
| **Institution** | IIITDM Kurnool |
| **Department** | Electronics and Communication Engineering |
| **Developer** | Tanmay Jain (123ec0025) |

---

## 📧 Contact

**Tanmay Jain**  
B.Tech, Electronics and Communication Engineering  
Indian Institute of Information Technology, Design and Manufacturing (IIITDM) Kurnool

- 📧 Email: 123ec0025@iiitk.ac.in
- 💼 LinkedIn: [Tanmay Jain](https://www.linkedin.com/in/tanmay-jain-838b19261)
- 🐙 GitHub: [realjaine](https://github.com/realjaine)

---

## 📄 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

Special thanks to:

- **Dr. P. Ranga Babu** – Course instructor and mentor
- **Cadence Design Systems** – EDA tools and support
- **IIITDM Kurnool** – Infrastructure and resources

---

<div align="center">

**⭐ If this industrial flow helped your learning, please give it a star! ⭐**

---

*Developed with 💙 for learning and research*

**© 2026 Tanmay Jain • IIITDM Kurnool**

</div>
