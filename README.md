# Personal Expense and Budget Management System

## 1. Project Description
The Personal Expense and Budget Management System is developed using x86-64 Assembly Language (NASM). It allows users to manage their personal budgets and expenses through a menu-based system.

## 2. Requirements
Before running the program, make sure the following tools are installed in WSL:
- WSL (Windows Subsystem for Linux)
- NASM (Netwide Assembler)
- GCC (GNU Compiler Collection)

## 3. How to Run the Program in WSL
Follow these steps to compile and run the program.

**Step 1: Open WSL**
Open your Ubuntu terminal in Windows.

**Step 2: Navigate to the project folder**
```bash
cd ASM-Budget
```

**Step 3: Assemble the NASM source code**
```bash
nasm -f elf64 budget.asm -o budget.o
```

**Step 4: Compile and link the object file**
```bash
gcc -no-pie budget.o -o budget
```

**Step 5: Run the program**
```bash
./budget
```

The main menu will appear after successfully running the program.

## 4. Administrator Login Details
Use the following credentials to log in as an administrator:
Username = `admin`
Password = `admin123`

## 5. Project Source Code
GitHub Repository:
https://github.com/Cheang-Zhi-Lin/Personal-budget-and-expenses-management-system-Assembly/tree/master
