■ PART 1: LPG++ INSTALLATION (PDDL 2.1 Numeric) ■

STEP 1: System Setup
---------------------
A. For WSL (Windows Users):
   1. Check WSL installation:
      > wsl --list --verbose
      * Expected output:
        NAME      STATE           VERSION
        * Ubuntu    Running         2

   2. If not installed:
      > wsl --install
      > wsl --set-default-version 2

   3. Launch WSL terminal:
      > wsl

B. For Linux (Native Ubuntu/Debian):
   * Skip WSL steps if using native Linux

STEP 2: Toolchain Installation
------------------------------
1. Update packages:
   > sudo apt update && sudo apt upgrade -y

2. Install essential tools (both WSL and Linux):
   > sudo apt install g++ make git

3. Verify installations:
   > g++ --version  # Should show GCC 9+
   > make --version # Should show GNU Make 4+

STEP 3: Source Download
-----------------------
1. Clone repository:
   > git clone https://github.com/matteocarde/unige-aai.git

2. Navigate to LPG directory:
   > cd unige-aai/planners/LPG

STEP 4: Compilation
-------------------
1. Clean previous builds (if any):
   > make clean

2. Compile LPG++:
   > make

3. Verify successful compilation:
   > ls -l lpg++
   * Correct output format:
     -rwxr-xr-x 1 user group [file_size] lpg++

STEP 5: Basic Verification
-------------------------
1. Test executable functionality:
   > ./lpg++ --help
   * Expected: Shows usage instructions with PDDL2.1 options

2. Quick test (optional):
   > ./lpg++ --version
   * Should display version info

STEP 6: First Run
-----------------
Basic execution command:
> ./lpg++ -o domain.pddl -f problem.pddl -out plan.txt

* Notes:
  - Place domain/problem files in current directory
  - For WSL: Access Windows files via /mnt/c/path_to_files/


■ PART 2: ENHSP INSTALLATION (PDDL+) ■

STEP 1: WSL Setup (Windows Only)
--------------------------------
1. Check WSL:
   > wsl --list --verbose
2. Enter WSL:
   > wsl
3. Update:
   > sudo apt update && sudo apt upgrade -y

STEP 2: Java Installation
-------------------------
1. Install JDK 17:
   > sudo apt install openjdk-17-jre openjdk-17-jdk
2. Verify:
   > java -version
   (Should show "openjdk 17.x.x")

STEP 3: ENHSP Compilation
-------------------------
1. Clone repository:
   > git clone https://gitlab.com/enricos83/ENHSP-Public.git
   > cd ENHSP-Public
2. Compile:
   > ./compile
   (Check for enhsp.jar in enhsp-dist folder)

STEP 4: Usage
-------------
1. Basic execution:
   > java -jar enhsp-dist/enhsp.jar -o domain.pddl -f problem.pddl -planner sat-had

2. Save plan:
   > java -jar enhsp-dist/enhsp.jar -o domain.pddl -f problem.pddl -sp plan.txt

3. Alternative planners:
   > java -jar enhsp-dist/enhsp.jar -o domain.pddl -f problem.pddl -planner sat-hmax
   > java -jar enhsp-dist/enhsp.jar -o domain.pddl -f problem.pddl -planner sat-aibr


■ PART 3: UBUNTU DIRECT INSTALLATION ■

For native Ubuntu (skip WSL steps if using this):

1. Install Java:
   > sudo apt update
   > sudo apt install openjdk-17-jre openjdk-17-jdk

2. Follow ENHSP compilation steps from PART 2


■ VERIFICATION CHECKS ■
-----------------------
1. LPG++:
   > file lpg++ (should show "ELF executable")
   > ./lpg++ --help (should display help)

2. ENHSP:
   > java -version (must show Java 17+)
   > ls enhsp-dist/enhsp.jar (should exist)


■ NOTES ■
---------
• Replace domain.pddl/problem.pddl with your files
• Windows users access files via: /mnt/c/your_path/
• Timeout handling: Add "-t 300" for 5-minute timeout

============================================
END OF GUIDE
============================================