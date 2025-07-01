# Hospital Multi-Robot Medicine Delivery System (PDDL) 

This project presents a Planning Domain Definition Language (PDDL)-based simulation of a hospital environment where autonomous robots deliver medicines across multiple floors using a shared elevator. The system models operational constraints like robot/elevator capacity, patient-specific delivery, and urgent medicine prioritization.

## 🔍 Overview

- **Scenario**: 4 robots deliver 16 medicines (4 per floor) to patients across 4 floors, then return to base floor to robot room.
- **Goal**: Deliver all medicines efficiently and return the robot to robot room, while minimizing total cost and respecting operational constraints.
- **Tech**: Modeled using four PDDL variants to explore trade-offs in realism, performance, and planner compatibility.

## 🧠 PDDL Variants

| Variant           | Key Features                              | Planner     |
|------------------|--------------------------------------------|-------------|
| PDDL 1.2 (STRIPS)| High compatibility, urgent delivery logic  | [LAMA](https://editor.planning.domains/) |
| PDDL 2.1         | Numeric fluents for load tracking          | [ENHSP](https://gitlab.com/enricos83/ENHSP-Public) |
| PDDL 2.1 Temporal| Durative actions, concurrency, cost model  | [LPG++](https://github.com/matteocarde/unige-aai/tree/master/planners/LPG) |
| PDDL+            | Processes/events, realism, battery-aware   | [ENHSP](https://gitlab.com/enricos83/ENHSP-Public) |

## 📂 Structure

- `Boolean/` – Boolean logic version for baseline STRIPS model  
- `Numeric_SenzaTemporal/` – PDDL 2.1 with numeric fluents, no temporal extensions  
- `Pddl2.1/` – PDDL 2.1 with numeric fluents and action durations  
- `Priority/` – STRIPS version with priority-based delivery model  
- `Pddl+/` – Basic PDDL+ version with continuous processes  
- `Pddl+_Battery/8Pazienti/` – Advanced PDDL+ model with battery constraints and 8 patients  
- `pddl2.1_Battery/` – PDDL 2.1 with custom battery consumption modeling  
- 📄 [`pddl_hospital_robot_implementation_report.pdf`](https://github.com/AInsteinGroup/WALL-E-HOSPITAL/blob/main/WALL-E-HOSPITAL/pddl_hospital_robot_implementation_report.pdf) – Full technical report


## 🚀 How to Run

# PDDL Planners Installation and Usage Guide

This guide provides step-by-step instructions for installing and using two PDDL planners: **LPG++** (for PDDL 2.1 Temporal) and **ENHSP** (for PDDL+). It supports both Windows (via WSL) and native Linux (Ubuntu/Debian) environments.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [LPG++ Installation (PDDL 2.1 Temporal)](#lpg-installation)
   - [System Setup](#system-setup)
   - [Toolchain Installation](#toolchain-installation)
   - [Source Download](#source-download)
   - [Compilation](#compilation)
   - [Verification](#verification)
   - [First Run](#first-run)
3. [ENHSP Installation (PDDL+)](#enhsp-installation)
   - [System Setup](#enhsp-system-setup)
   - [Java Installation](#java-installation)
   - [Compilation](#enhsp-compilation)
   - [Usage](#enhsp-usage)
4. [Ubuntu Direct Installation](#ubuntu-direct-installation)
5. [Troubleshooting](#troubleshooting)
6. [Notes](#notes)

## Prerequisites
- **Operating System**: Ubuntu/Debian (native) or Windows with WSL2.
- **Hardware**: Minimum 4GB RAM, 2GB free disk space.
- **Software**:
  - For LPG++: `g++`, `make`, `git`.
  - For ENHSP: OpenJDK 17 (JRE and JDK).
- **PDDL Files**: Ensure you have valid `domain.pddl` and `problem.pddl` files for testing.

## LPG++ Installation (PDDL 2.1 Temporal)

### System Setup
#### For Windows (WSL2)
1. **Check WSL Installation**:
   ```bash
   wsl --list --verbose
   ```
   Expected output:
   ```
     NAME      STATE           VERSION
     * Ubuntu    Running         2
   ```
2. **Install WSL2** (if not installed):
   ```bash
   wsl --install
   wsl --set-default-version 2
   ```
3. **Launch WSL Terminal**:
   ```bash
   wsl
   ```

#### For Native Linux (Ubuntu/Debian)
- Skip WSL steps and proceed to the next section.

### Toolchain Installation
1. **Update Packages**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
2. **Install Essential Tools**:
   ```bash
   sudo apt install g++ make git -y
   ```
3. **Verify Installations**:
   ```bash
   g++ --version  # Should show GCC 9+ (e.g., 9.4.0)
   make --version  # Should show GNU Make 4+ (e.g., 4.3)
   ```

### Source Download
1. **Clone Repository**:
   ```bash
   git clone https://github.com/matteocarde/unige-aai.git
   ```
2. **Navigate to LPG Directory**:
   ```bash
   cd unige-aai/planners/LPG
   ```

### Compilation
1. **Clean Previous Builds** (if any):
   ```bash
   make clean
   ```
2. **Compile LPG++**:
   ```bash
   make
   ```
3. **Verify Compilation**:
   ```bash
   ls -l lpg++
   ```
   Expected output:
   ```
   -rwxr-xr-x 1 user group [file_size] lpg++
   ```

### Verification
1. **Test Executable**:
   ```bash
   ./lpg++ --help
   ```
   - Should display usage instructions with PDDL 2.1 options.
2. **Check Version** (optional):
   ```bash
   ./lpg++ --version
   ```
   - Should display version information.

### First Run
Run LPG++ with your PDDL files:
```bash
./lpg++ -o domain.pddl -f problem.pddl -out plan.txt
```
- Ensure `domain.pddl` and `problem.pddl` are in the current directory.
- For WSL, access Windows files via `/mnt/c/path_to_files/`.

## ENHSP Installation (PDDL+)

### ENHSP System Setup
#### For Windows (WSL2)
1. **Check WSL**:
   ```bash
   wsl --list --verbose
   ```
2. **Enter WSL**:
   ```bash
   wsl
   ```
3. **Update Packages**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

#### For Native Linux
- Skip WSL steps.

### Java Installation
1. **Install OpenJDK 17**:
   ```bash
   sudo apt install openjdk-17-jre openjdk-17-jdk -y
   ```
2. **Verify Java**:
   ```bash
   java -version
   ```
   Expected output:
   ```
   openjdk 17.x.x
   ```

### ENHSP Compilation
1. **Clone Repository**:
   ```bash
   git clone https://gitlab.com/enricos83/ENHSP-Public.git
   cd ENHSP-Public
   ```
2. **Compile ENHSP**:
   ```bash
   ./compile
   ```
3. **Verify Compilation**:
   ```bash
   ls enhsp-dist/enhsp.jar
   ```
   - Should confirm the presence of `enhsp.jar`.

### ENHSP Usage
1. **Basic Execution**:
   ```bash
   java -jar enhsp-dist/enhsp.jar -o "domain.pddl" -f "problem.pddl"
   ```
2. **Save Plan to File**:
   ```bash
   java -jar enhsp-dist/enhsp.jar -o "domain.pddl" -f "problem.pddl" -sp plan.txt
   ```
3. **Alternative Planners**:
   - Using `PDDL + With Battery`:
     ```bash
     java -Xmx6G -jar enhsp-20.jar -o "domain" -f "problem" -d 1.5 -s WAStar -h hmax -anytime -timeout 9000
     ```
**Search Configuration**:

- d 1.5 : ```bash Sets the discount factor to 1.5. This parameter influences the cost calculation in the search algorithm, giving more weight to immediate actions versus future actions.```
- s WAStar : ```bash Selects the Weighted A* (WA*) search algorithm. This is an anytime algorithm that finds solutions quickly and then iteratively improves them.```
- h hmax : ```bash Uses the hmax heuristic function. This heuristic provides an admissible estimate of the remaining cost to reach the goal state, helping guide the search efficiently.```


**Optimization Settings**

- anytime : ```bash Enables anytime search mode. The planner will find an initial solution quickly and then continue to search for better solutions until the timeout is reached.```
- timeout 9000 : ```bash Sets the maximum execution time to 9000 seconds (2.5 hours). The planner will terminate after this time limit, returning the best solution found.```

## Ubuntu Direct Installation
For native Ubuntu/Debian users (no WSL):
1. **Install Java**:
   ```bash
   sudo apt update
   sudo apt install openjdk-17-jre openjdk-17-jdk -y
   ```
2. **Follow ENHSP Compilation and Usage**:
   - Refer to the [ENHSP Installation](#enhsp-installation) section, starting from [Java Installation](#java-installation).

## Troubleshooting
- **LPG++ Compilation Fails**:
  - Ensure `g++` and `make` are installed (`sudo apt install g++ make`).
  - Check for missing dependencies in the repository’s documentation.
- **ENHSP: `java` Command Not Found**:
  - Verify Java installation (`java -version`).
  - Reinstall OpenJDK if needed (`sudo apt install openjdk-17-jre openjdk-17-jdk`).
- **File Access Issues in WSL**:
  - Use `/mnt/c/path_to_files/` to access Windows files.
  - Ensure correct file permissions (`chmod +r domain.pddl problem.pddl`).
- **Timeout Issues**:
  - Add `-t 300` to limit execution to 5 minutes (e.g., `./lpg++ -o domain.pddl -f problem.pddl -t 300`).

## Notes
- Replace `domain.pddl` and `problem.pddl` with your actual PDDL file names.
- For WSL, access Windows files via `/mnt/c/your_path/`.
- Ensure sufficient memory and CPU resources for large PDDL problems.
- Check repository documentation for additional planner options or updates.
- For ENHSP, experiment with different planners (`sat-had`, `sat-hmax`) based on your problem’s complexity.
