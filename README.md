# RTL-to-ATPG Implementation of a Universal Asynchronous Receiver-Transmitter (UART) Core 🚀

[![Language](https://img.shields.io/badge/Language-Verilog-yellow.svg)](https://en.wikipedia.org/wiki/Verilog)
[![Tools](https://img.shields.io/badge/Tools-Cadence%20Genus%20%7C%20Modus-brightgreen.svg)](https://www.cadence.com)
[![Technology](https://img.shields.io/badge/Technology-90nm-blue.svg)](#)
[![Coverage](https://img.shields.io/badge/Fault%20Coverage-99.89%25-success.svg)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

*A complete industrial ASIC DFT flow: From RTL synthesis to 99.89% Test Coverage ATPG*

[Features](#-key-highlights) • [Architecture](#-design-architecture) • [Synthesis Results](#-synthesis-key-metrics-90nm-genus) • [DFT & ATPG](#-dft--atpg-deep-dive) • [Repository](#-repository-structure)

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

## 📊 Synthesis Key Metrics (90nm Genus)

The design was synthesized using the **slow.lib** corner to ensure worst-case reliability.

### 🧩 Area & Gate Utilization

| Metric | Value | File Source |
|:---|:---|:---|
| **Total Cell Area** | 2145.811 μm² | `post_dft_area.rpt` |
| **Total Instance Count** | 209 | `post_dft_gates.rpt` |
| **Sequential Instances** | 54 (All Scan-Mapped) | `post_dft_rules.rpt` |
| **Combinational Area** | 725.87 μm² | `post_dft_gates.rpt` |

### ⚡ Power Breakdown (Joules Engine)

Vectorless analysis at V_DD = 0.67V:

| Power Component | Value (W) | % of Total | Description |
|:---|:---|:---|:---|
| **Internal Power** | 6.222 × 10⁻⁵ | 75.1% | Power within logic cells |
| **Switching Power** | 8.638 × 10⁻⁶ | 10.4% | Charging/discharging nets |
| **Leakage Power** | 1.200 × 10⁻⁵ | 14.5% | Static power dissipation |
| **Total Power** | **8.286 × 10⁻⁵** | **100%** | **Total consumption (0.082 mW)** |

### ⏱️ Timing Analysis (Sign-off)

| Parameter | Value | Unit | Description |
|:---|:---|:---|:---|
| **Target Period** | 20,000 | ps | 50 MHz clock |
| **Data Arrival Time** | 5,593 | ps | `tx_start → u_tx_shift_reg_reg[6]/D` |
| **Setup Uncertainty** | 500 | ps | Guard band for jitter |
| **Setup Slack** | **+13,706** | **ps** | ✅ **Sign-off Met** |

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

🧪 Fault Coverage Summary (Modus)
CategoryTotal FaultsTestedCoverageStatic Stuck-at1,786 1,784 99.89%
✅Dynamic Faults1,554 330 21.24% Total ATPG Cycles2,129 77 Test / 2,052 Scan 100% Generated 

### 🔄 VLSI Flow & Tool Execution

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

**Pre-DFT Synthesis (Genus):**
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
│   ├── dft_setup.rpt           # Scan Chain Architecture
│   ├── post_dft_area.rpt       # Area & Cell Count
│   ├── post_dft_gates.rpt      # Gate-level Instance Report
│   ├── post_dft_power.rpt      # Joules Power Analysis
│   ├── post_dft_rules.rpt      # DFT Rule Check (0 violations)
│   ├── post_dft_timing.rpt     # Slack & Path Analysis
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
