# RTL-to-GDS Implementation of a Low-Power Configurable Multi-Clock Digital System

## 📌 Project Overview

This project implements a **Low-Power Configurable Multi-Clock Digital System** that receives commands through a UART receiver, executes register-file operations or arithmetic and logical operations, and transmits the results through a UART transmitter.

The system contains multiple clock domains to support different operating frequencies. An asynchronous FIFO provides buffering between clock domains, helping ensure reliable data transfer while reducing the risk of data loss. Clock-gating techniques are used to reduce unnecessary switching activity in the ALU clock domain.

The project demonstrates the digital IC implementation flow, starting from synthesizable RTL design and progressing through logic synthesis, Design for Testability (DFT), and formal equivalence verification.

## 🎯 Project Objectives

- Design a configurable digital system using Verilog HDL.
- Implement UART-based communication between the system and an external controller.
- Support arithmetic, logical, and register-file operations.
- Handle clock-domain crossings using synchronization techniques and asynchronous buffering.
- Apply low-power design techniques, including clock gating.
- Synthesize the RTL design into a gate-level netlist.
- Implement scan-based Design for Testability.
- Verify functional equivalence at different implementation stages.
- Develop practical experience with ASIC design tools and Tcl-based implementation scripts.

## 🏗️ System Architecture

The system is organized into functional blocks that communicate through a command-driven control architecture.

### System Operation

1. The external controller sends a command through the UART interface.
2. The UART receiver captures the incoming serial frame and converts it into parallel data.
3. The system controller decodes the command and determines the required operation.
4. The register file performs a read or write operation, or the ALU executes the requested function.
5. The resulting data is transferred through the appropriate interface and buffered by the asynchronous FIFO when required.
6. The UART transmitter sends the result back to the external controller.

### Supported Operations

**Register File Operations**
- Register write.
- Register read.

**ALU Operations**
- Arithmetic operations, including addition, subtraction, multiplication, and division, subject to the implemented ALU functionality.
- Logical operations, including AND, OR, NAND, NOR, XOR, and XNOR.
- Comparison and shift operations, as supported by the RTL implementation.

**Communication Commands**
- Register-file write command.
- Register-file read command.
- ALU operation with operands.
- ALU operation using previously stored operands.

## ⏱️ Multi-Clock Architecture and Low-Power Design

The design uses separate clock domains for system processing and UART communication.

### Clock-Domain Management

Different operating frequencies introduce clock-domain crossing (CDC) challenges. Synchronization logic is used where appropriate, while the asynchronous FIFO provides buffering for data transfers between independently clocked blocks.

### Low-Power Techniques

- **Clock gating:** Reduces unnecessary clock transitions when the ALU is not required to perform an operation.
- **Clock division:** Generates a lower-frequency clock for UART timing requirements.
- **Controlled activity:** The system controller coordinates operations to avoid unnecessary processing.

These techniques are intended to reduce dynamic power while preserving the required system functionality.

## 🔧 ASIC Implementation Flow

The project focuses on the ASIC implementation process, from RTL development to GDS.

### 1. RTL Design

The system modules are described using synthesizable Verilog HDL and integrated into the top-level architecture.

### 2. Functional Verification

Simulation is used to verify command decoding, register-file operations, ALU functionality, UART communication, and system-level behavior.

### 3. Logic Synthesis

The RTL design is synthesized using Synopsys Design Compiler to generate a technology-mapped gate-level netlist.

Typical synthesis activities include:
- Reading RTL and technology libraries.
- Applying timing and design constraints.
- Performing logic optimization and technology mapping.
- Generating area, timing, and synthesis reports.

### 4. Design for Testability (DFT)

Scan-based DFT techniques are used to improve controllability and observability of internal sequential logic for manufacturing test.

### 5. Formal Equivalence Verification

Synopsys Formality is used to compare corresponding design representations and verify functional equivalence at supported implementation stages.


## 📁 Repository Structure

RTL-to-GDS-Implementation-of-Low-Power-Configurable-Multi-Clock-Digital-System/
│
├── RTL/
│   └── Verilog RTL source files
│
├── synthise/
│   └── Synthesis scripts, constraints, and related files
│
├── DFT/
│   └── DFT scripts, scan configuration, and related files
│
├── formality/
│   └── Formal equivalence verification scripts and setup files
│
└── README.md



## 📊 Verification and Implementation Results

The project uses simulation and formal verification to evaluate the system at different stages of the ASIC flow.

Relevant results to document include:

- RTL functional simulation results.
- Synthesis area and timing reports.
- Setup and hold timing analysis.
- DFT scan-insertion results.
- Post-synthesis and post-DFT formal equivalence results.
- Physical-design and final layout results, if available.


## 👩‍💻 Author

**Mariam Gomaa**
Communication and Electronics Engineering  
Faculty of Engineering, Cairo University
