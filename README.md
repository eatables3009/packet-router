# 🛰️ Verilog Packet Router

This project is a **Verilog-based 1-to-4 packet router**, designed to be synthesized for hardware or used in a simulation environment.

The system receives **20-bit data packets**, buffers them using an internal FIFO to prevent data loss, and routes the **16-bit payload** to one of four output ports based on a routing header.  
It includes a **complete testbench** for functional verification.

---

## 🚀 Key Features

- **State-Machine Controlled:**  
  A simple 3-state Finite State Machine (**IDLE**, **ROUTE**, **DONE**) manages the routing logic for reliability and clarity.

- **FIFO Buffering:**  
  Utilizes a **32-deep, 20-bit wide synchronous FIFO** to buffer incoming packets, preventing data loss when the router is busy.

- **Header-Based Routing:**  
  Routes packets to one of four output ports based on the **2 least significant bits of the packet header**.

- **Clear Status Signals:**  
  Outputs a `busy` signal when processing and `port_valid` signals to indicate which output has valid data.

- **Self-Contained Design:**  
  The main module includes a **parameterized FIFO**, making the design portable with no external dependencies.

- **Complete Verification Environment:**  
  Comes with a thorough **testbench** that checks all four routing paths and reports a final **pass/fail summary**.

---

## 🧩 Design & Verification

### Design Files
- `Packet_router.v` – Top-level synthesizable module containing the FSM, routing logic, and an embedded parameterized FIFO module.

### Verification
- `testbench.v` – Comprehensive testbench that instantiates the router, generates a clock, applies a reset, and sends packets to test all routing conditions.
- **Waveform Dumping:** The testbench automatically generates a `Packet_router_tb.vcd` file for visual debugging and waveform analysis in tools like **GTKWave**.

---

## ⚙️ Getting Started

### 1. Simulate the Design

You can use any Verilog simulator.  
Below are commands for **Icarus Verilog (iverilog)**:

```bash
# Compile the Verilog source files
iverilog -o router.out Packet_router.v testbench.v

# Run the compiled simulation
vvp router.out 

After running the simulation, you should see the following results:


Test 1: Header=0x0, Data=0xAAAA -> Expected Port 1
PASS: Correctly routed to Port 1

Test 2: Header=0x1, Data=0x5555 -> Expected Port 2
PASS: Correctly routed to Port 2

Test 3: Header=0x2, Data=0x1234 -> Expected Port 3
PASS: Correctly routed to Port 3

Test 4: Header=0x3, Data=0xABCD -> Expected Port 4
PASS: Correctly routed to Port 4

===============================
Tests Passed: 4/4
Tests Failed: 0/4
===============================
