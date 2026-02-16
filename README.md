# ⚡ Embedded Systems - ECE NTUA

![Course](https://img.shields.io/badge/Course-Embedded_Systems-blue)
![University](https://img.shields.io/badge/University-NTUA-red)
![Specialization](https://img.shields.io/badge/Focus-Optimization_&_HLS-orange)

Laboratory projects for the **Embedded Systems** course at at the School of Electrical and Computer Engineering, **National Technical University of Athens (NTUA)**. This repository covers the complete design flow from high-level algorithmic optimization to hardware acceleration and cross-compilation for ARM architectures.

---

## 📂 Repository Structure

The labs follow a path from software performance analysis to hardware-level implementation:

| Lab Unit | Topic | Description |
| :--- | :--- | :--- |
| **`Lab 1`** | **Loop Transformations** | Design Space Exploration (DSE) using loop tiling, unrolling, and fusion to optimize memory access and execution time. |
| **`Lab 2`** | **Data Type Refinement** | Dynamic data type refinement for memory footprint reduction. Optimization of the Dijkstra algorithm. |
| **`Lab 3`** | **HLS: Reed-Solomon** | High-Level Synthesis (HLS) implementation of a Reed-Solomon decoder for hardware acceleration on FPGAs. |
| **`Lab 4`** | **HLS: GANs** | Implementing and optimizing Generative Adversarial Networks (GANs) using HLS tools for performance/area trade-offs. |
| **`Lab 5`** | **ARM Assembly** | Low-level optimization and performance tuning using ARM-specific instruction sets. |
| **`Lab 6`** | **Cross-Compiling** | Setting up cross-compilation environments for deploying embedded Linux applications on target boards. |

---

## 🧠 Key Technical Concepts

### 🚀 Design Space Exploration
Analysis of different loop transformation combinations to find the "Pareto optimal" solutions between performance (latency) and resource usage (area/power).


### 🛠️ High-Level Synthesis (HLS)
Using C/C++ to generate RTL (Register-Transfer Level) hardware descriptions. Focus on pragmas for pipelining, array partitioning, and resource allocation.


### 🏗️ Heterogeneous Computing
* **ARM Architecture:** Assembly-level programming and cross-compilation for embedded processors.
* **FPGA Acceleration:** Offloading computationally intensive kernels (RS Decoders, GANs) to hardware logic.

---

## 🔧 Tools & Technologies
* **Xilinx Vitis / Vivado HLS:** For hardware synthesis.
* **GCC / Arm-linux-gnueabihf:** For cross-compilation.
* **C / C++ / Assembly:** Primary development languages.
* **Embedded Linux:** Target operating system for deployment.


---
*Disclaimer: This repository is intended for educational purposes and contains solutions for the ECE NTUA laboratory exercises.*
