default rel

; ============================================================
; PERSONAL EXPENSE & BUDGET MANAGEMENT SYSTEM
;
;   accounts.txt = list of students (who can log in)
;   budgets.txt  = how much money each person may spend
;   expenses.txt = what each person already spent
; ============================================================

;
; ---------------- REGISTERS (the CPU's tiny boxes) -------------
; A "register" is a tiny storage box built directly into the
; processor chip - the fastest kind of memory there is, but
; there are only a few of them. This program mainly uses:
;
;   RDI, RSI, RDX, RCX, R8, R9
;       When we CALL a function (like printf), these hold the
;       function's inputs, IN THIS ORDER: 1st input goes in RDI,
;       2nd in RSI, 3rd in RDX, 4th in RCX, 5th in R8, 6th in R9.
;       This fixed order is a rule called the "calling convention"
;       - every program on this computer agrees to follow it, so
;       any function can call any other function correctly.
;
;   RAX / EAX / AL
;       RAX is the "accumulator" - by tradition it holds a
;       function's ANSWER (return value) once it finishes, and
;       it's used for general quick maths too.
;       EAX is just the smaller, bottom HALF of RAX (32 bits
;       instead of 64). AL is an even smaller slice - just the
;       bottom 8 bits (1 byte) of RAX. Same box, different "view
;       sizes" - like looking at only the last 2 digits of RM1000.
;
;   RBP and RSP ("base pointer" and "stack pointer")
;       Every time this program runs a function, it needs a
;       little scratch space to work in, called the "stack".
;       RSP always points at the very top (newest item) of that
;       scratch space. RBP marks where THIS function's own
;       scratch space begins, so the function can find its way
;       back no matter how much it pushes/pops while running.
;
;   Letters E, R, D, B at the end of a register name
;       EDI/ESI/EDX/ECX/R8D/R9D are just the 32-bit (whole
;       number) versions of RDI/RSI/RDX/RCX/R8/R9. AL/DL/R8B are
;       the 8-bit (single byte / single letter) versions. Same
;       box, smaller slice - we pick the size that matches what
;       we're working with (a whole number vs. a single letter).
;
; ------------------- INSTRUCTIONS (the verbs) -------------------
;
;   mov DEST,SRC    MOVE - copies SRC into DEST. (Despite the
;                   name, the original SRC is NOT erased - it's
;                   really a copy, like a photocopier.)
;   lea DEST,[...]  LOAD EFFECTIVE ADDRESS - puts the MEMORY
;                   ADDRESS of something into DEST (not its
;                   value). We use this constantly to point at
;                   pieces of text so we can print them.
;   push X          PUSH - saves X onto the stack (puts it on
;                   top of the scratch-space pile).
;   pop X           POP - takes the most recently pushed value
;                   off the stack and puts it back into X.
;   call NAME       CALL - jumps to another function, and
;                   remembers exactly where to come back to
;                   afterwards.
;   ret             RETURN - jumps back to right after wherever
;                   this function was called from.
;   leave           LEAVE - a quick one-word cleanup that undoes
;                   "push rbp / mov rbp,rsp" from the start of a
;                   function, right before RET.
;   cmp A,B         COMPARE - compares A and B (without changing
;                   either one) and remembers the result, ready
;                   for the next jump instruction to check.
;   test A,B        TEST - similar to compare, but checks bits.
;                   "test eax,eax" is a common trick meaning
;                   "is EAX exactly zero?"
;   inc X           INCREMENT - adds 1 to X.
;   dec X           DECREMENT - subtracts 1 from X.
;   add X,Y         ADD - adds Y onto X.
;   sub X,Y         SUBTRACT - subtracts Y from X.
;   neg X           NEGATE - flips X's sign (5 becomes -5, or
;                   -5 becomes 5).
;   imul X,Y        INTEGER MULTIPLY.
;   idiv X          INTEGER DIVIDE - divides a number by X.
;   cdq             CONVERT DOUBLEWORD TO QUADWORD - a required
;                   setup step right before idiv, so negative
;                   numbers divide correctly.
;   xor X,Y         EXCLUSIVE OR - a logic operation. "xor
;                   eax,eax" is a fast shortcut for "set EAX to
;                   0". We also use XOR on purpose to scramble
;                   passwords (see encrypt_password_hex).
;   and X,Y         AND - a logic operation, keeps only the bits
;                   that are "on" in BOTH X and Y.
;   or  X,Y         OR - a logic operation, turns on any bit
;                   that is "on" in EITHER X or Y.
;   shl X,N         SHIFT LEFT - slides X's bits left N times
;                   (like X times 2, repeated N times).
;   shr X,N         SHIFT RIGHT - slides X's bits right N times
;                   (like X divided by 2, repeated N times).
;   movzx DEST,SRC  MOVE WITH ZERO-EXTEND - copies a small value
;                   (like one byte/letter) into a bigger box,
;                   filling the extra space with zeros.
;
; --------- JUMP INSTRUCTIONS (decisions / "if this then...") ----
; A jump instruction looks at the result of the LAST cmp or test
; and decides whether to skip to a different label or not.
;
;   jmp LABEL   JUMP - ALWAYS jump there, no condition.
;   je  LABEL   JUMP IF EQUAL
;   jne LABEL   JUMP IF NOT EQUAL
;   jz  LABEL   JUMP IF ZERO            (same idea as je)
;   jnz LABEL   JUMP IF NOT ZERO        (same idea as jne)
;   jl  LABEL   JUMP IF LESS
;   jle LABEL   JUMP IF LESS OR EQUAL
;   jg  LABEL   JUMP IF GREATER
;   jge LABEL   JUMP IF GREATER OR EQUAL
;   ja  LABEL   JUMP IF ABOVE           (greater, unsigned)
;   jb  LABEL   JUMP IF BELOW           (less, unsigned)
;   jbe LABEL   JUMP IF BELOW OR EQUAL
;
; ---------------- DIRECTIVES (setup lines, not actions) ---------
;
;   section .data    Marks the start of fixed TEXT and messages
;                    that never change while the program runs.
;   section .bss     Marks the start of EMPTY boxes the program
;                    fills in while it's running.
;   section .text    Marks the start of the actual instructions.
;   global NAME      Lets other files (like the C startup code)
;                    find and use our "main" label.
;   extern NAME      Says "this function is defined somewhere
;                    else" (in the C library, like printf).
;   default rel      Tells the assembler to use a safer way of
;                    finding our own data in memory.
;   db ...           DEFINE BYTE(S) - writes out fixed text,
;                    letters, or small numbers.
;   resb N           RESERVE BYTE(S) - reserves N empty 1-byte
;                    boxes (used for pieces of text).
;   resd N           RESERVE DOUBLEWORD(S) - reserves N empty
;                    4-byte boxes (used for whole numbers).
;   resq N           RESERVE QUADWORD(S) - reserves N empty
;                    8-byte boxes (used for memory addresses).
;   equ              Gives a fixed number a friendly name.
;   %define NAME ... Makes a shortcut name for a piece of text
;                    (we use this for our colour codes).
;   %macro / %endmacro
;                    Makes a reusable "mini recipe" we can use
;                    many times with different words plugged in
;                    (we use this for MENUITEM, our own shortcut
;                    for drawing one numbered menu line).
;
; --------------------- OTHER THINGS TO KNOW ----------------------
;
;   [rel something]   Square brackets mean "go to this ADDRESS
;                      and look at what's stored there", like an
;                      arrow pointing at a labelled box.
;   push rbp / mov rbp,rsp
;                      The standard first two lines of almost
;                      every function here - this sets up that
;                      function's own scratch space.
;   xor eax,eax before calling printf/fprintf/fscanf
;                      These are special "variadic" C functions
;                      (they can take a different number of
;                      inputs each time). The rule is: AL must
;                      say how many special floating-point
;                      inputs were used. We never use any, so we
;                      always set EAX to 0 first.
;   %s and %d inside text (used with printf/fprintf)
;                      These are fill-in-the-blank spots.
;                      %s means "put a piece of TEXT here".
;                      %d means "put a WHOLE NUMBER here".
; ================================================================

extern printf
extern fprintf
extern fgets
extern fopen
extern fclose
extern fscanf
extern strcmp
extern atoi
extern stdin
extern rename
extern exit

global main


; ============================================================
; COLOUR NAMES (BRIGHT colours, easy to see on black WSL)
; 27,'[1;9Xm' is a secret message that tells the terminal
; "print the next words in this colour".
; ============================================================

%define RESET    27,'[0m'
%define RED      27,'[1;91m'
%define GREEN    27,'[1;92m'
%define YELLOW   27,'[1;93m'
%define BLUE     27,'[1;94m'
%define MAGENTA  27,'[1;95m'
%define CYAN     27,'[1;96m'
%define WHITE    27,'[1;97m'
%define HILITE   27,'[1;4;95m'

; A small helper to draw one menu line:
; number in yellow, text in white
%macro MENUITEM 2
    db YELLOW,%1,'. ',WHITE,%2,RESET,10
%endmacro


; ============================================================
; DATA SECTION  (all the words the program can say)
;
; Every line below that starts with "db" (DEFINE BYTE) stores
; some exact bytes/letters into the finished program, forever.
; It is how we write out all of our menus, titles and messages.
; A line ending in equ (EQUATE) just gives a fixed number a
; friendly name we can use instead of it everywhere.
; ============================================================

section .data

color_white   db WHITE,0
color_reset   db RESET,0


; ------------------------------------------------------------
; Titles
; ------------------------------------------------------------

main_title:
    db 10,CYAN,'╔══════════════════════════════════════════════╗',10
    db YELLOW,'   💰  PERSONAL EXPENSE & BUDGET SYSTEM  💰   ',10
    db CYAN,'╚══════════════════════════════════════════════╝',RESET,10,0

login_title:
    db 10,MAGENTA,'╔══════════════════ 🔑 LOGIN ══════════════════╗',RESET,10,0

create_title:
    db 10,MAGENTA,'╔═════════════ 🧑 CREATE ACCOUNT ══════════════╗',RESET,10,0

user_title:
    db 10,GREEN,'╔════════════════ 👤 USER MENU ════════════════╗',RESET,10,0

admin_title:
    db 10,RED,'╔═══════════════ 🛡️  ADMIN MENU ═══════════════╗',RESET,10,0

title_stats:
    db 10,CYAN,'╔════════════ 📊 SYSTEM STATISTICS ════════════╗',RESET,10,0


; ------------------------------------------------------------
; Menus
; ------------------------------------------------------------

main_menu:
    MENUITEM '1','🔑 Login'
    MENUITEM '2','🧑 Create an Account'
    MENUITEM '3','🚪 Exit'
    db 0

user_menu:
    MENUITEM '1','💰 Set Monthly Budget'
    MENUITEM '2','🧾 Add Expense'
    MENUITEM '3','📄 View My Expenses'
    MENUITEM '4','🧮 Calculate Total Expense'
    MENUITEM '5','💵 View Remaining Budget'
    MENUITEM '6','📊 Check Budget Status'
    MENUITEM '7','📋 View My Expense Report'
    MENUITEM '8','🔒 Logout'
    MENUITEM '9','🚪 Exit'
    db 0

admin_menu:
    MENUITEM '1','👤 View accounts.txt'
    MENUITEM '2','💰 View budgets.txt'
    MENUITEM '3','🧾 View expenses.txt'
    MENUITEM '4','📋 View expense_report.txt'
    MENUITEM '5','📊 System Statistics'
    MENUITEM '6','🔒 Logout'
    MENUITEM '7','🚪 Exit'
    db 0


; ------------------------------------------------------------
; Prompts (after the prompt, what you type is bright white)
; ------------------------------------------------------------

prompt_choice:
    db CYAN,'Enter your choice: ',WHITE,0

prompt_username:
    db CYAN,'Username: ',WHITE,0

prompt_password:
    db CYAN,'Password: ',WHITE,0

prompt_new_username:
    db CYAN,'Enter new username: ',WHITE,0

prompt_new_password:
    db CYAN,'Enter new password: ',WHITE,0

prompt_budget:
    db CYAN,'Enter monthly budget (RM): ',WHITE,0

prompt_category:
    db CYAN,'Category (example: Food): ',WHITE,0

prompt_amount:
    db CYAN,'Amount (RM): ',WHITE,0


; ------------------------------------------------------------
; Messages  (green = good, red = bad, yellow = warning)
; ------------------------------------------------------------

msg_invalid_choice:
    db RED,'Invalid choice.',RESET,10,0

msg_invalid_number:
    db RED,'Invalid number. Please enter a positive value.',RESET,10,0

msg_empty_input:
    db 10,RED,'Input cannot be empty.',RESET,10,0

msg_account_created:
    db 10,GREEN,'Account created successfully.',RESET,10,0

msg_account_exists:
    db 10,RED,'Username already exists.',RESET,10,0

msg_login_success:
    db 10,GREEN,'Login successful.',RESET,10,0

msg_login_failed:
    db 10,RED,'Invalid username or password.',RESET,10,0

msg_logout:
    db 10,YELLOW,'Logged out successfully.',RESET,10,0

msg_goodbye:
    db 10,CYAN,'Thank you for using the system.',RESET,10,0

msg_budget_saved:
    db 10,GREEN,'Monthly budget updated successfully.',RESET,10,0

msg_expense_saved:
    db 10,GREEN,'Expense saved.',RESET,10,0

msg_no_expenses:
    db 10,YELLOW,'No expenses found for this user.',RESET,10,0

msg_total:
    db 10,GREEN,'Total Expense: RM%d',RESET,10,0

msg_remaining_label:
    db 10,CYAN,'Remaining Budget: ',0

; These two are used by print_rm_signed (see near the bottom of the
; file) to show money amounts: green "RM100" when positive, or red
; "-RM100" when negative, instead of the confusing "RM-100".
fmt_rm_positive:
    db GREEN,'RM%d',RESET,10,0

fmt_rm_negative:
    db RED,'-RM%d',RESET,10,0

msg_no_budget:
    db 10,YELLOW,'No monthly budget has been set.',RESET,10,0

msg_budget_warning:
    db 10,YELLOW,'WARNING: You have used 90%% or more of your budget.',RESET,10,0

msg_budget_exceeded:
    db 10,RED,'WARNING: Your total expense has exceeded your budget.',RESET,10,0

msg_budget_safe:
    db 10,GREEN,'Budget Status: Within budget.',RESET,10,0

msg_file_error:
    db 10,RED,'Unable to open the file.',RESET,10,0

msg_update_error:
    db 10,RED,'Unable to update the budget file.',RESET,10,0

msg_no_data:
    db YELLOW,'(this file is empty)',RESET,10,0


; ------------------------------------------------------------
; File display titles
; ------------------------------------------------------------

title_accounts:
    db 10,BLUE,'╔══════════════ 👤 ACCOUNTS.TXT ═══════════════╗',RESET,10,0

; Asked right after choosing "View accounts.txt"
prompt_view_mode:
    db 10,MAGENTA,'How do you want to view accounts.txt?',RESET,10
    db YELLOW,'1. ',WHITE,'🔒 Encrypted password ',RESET,10
    db YELLOW,'2. ',WHITE,'🔓 Plain text password ',RESET,10,0

title_accounts_plain:
    db 10,BLUE,'╔════════ 🔓 ACCOUNTS.TXT (PLAIN TEXT) ════════╗',RESET,10,0

fmt_account_plain:
    db YELLOW,'%s',WHITE,'  ->  password: ',GREEN,'%s',WHITE,'   role: ',CYAN,'%s',RESET,10,0

title_budgets:
    db 10,BLUE,'╔══ 💰 BUDGETS.TXT ══╗',RESET,10,0

title_expenses:
    db 10,BLUE,'╔══ 🧾 EXPENSES.TXT ══╗',RESET,10,0

title_report:
    db 10,BLUE,'╔════════════ 📋 Expense Report.txt ════════════╗',RESET,10,0

title_my_report:
    db 10,MAGENTA,'╔══════════════ 📋 EXPENSE REPORT ══════════════╗',RESET,10,0

fmt_my_report_user:
    db CYAN,'User: ',WHITE,'%s',RESET,10,0

fmt_my_report_budget:
    db CYAN,'Monthly Budget: ',GREEN,'RM%d',RESET,10,0

fmt_my_report_total:
    db CYAN,'Total Expense: ',GREEN,'RM%d',RESET,10,0

fmt_my_report_remaining_label:
    db CYAN,'Remaining: ',0

line_separator:
    db WHITE,'----------------------------------------',RESET,10,0


; ------------------------------------------------------------
; File names
; ------------------------------------------------------------

file_accounts     db 'accounts.txt',0
file_budgets      db 'budgets.txt',0
file_budgets_temp db 'budgets.tmp',0
file_expenses     db 'expenses.txt',0
file_report       db 'expense_report.txt',0
file_report_temp  db 'expense_report.tmp',0

; Used to spot where each person's block starts inside expense_report.txt
report_prefix     db 'User: ',0

; Used to show each "User: ..." line in a bold, underlined colour so
; it's easy to spot where one person's report ends and the next
; person's begins
fmt_report_user_highlight:
    db HILITE,'%s',RESET,0


; ------------------------------------------------------------
; File modes
; ------------------------------------------------------------

mode_read    db 'r',0
mode_append  db 'a',0
mode_write   db 'w',0


; ------------------------------------------------------------
; File formats (how to read / write one line)
; ------------------------------------------------------------

fmt_account        db '%63s %255s %15s',0
fmt_budget         db '%63s %d',0
fmt_expense        db '%63s %63s %d',0

fmt_account_write  db '%s %s %s',10,0
fmt_budget_write   db '%s %d',10,0
fmt_expense_write  db '%s %s %d',10,0

fmt_line           db '%s',0


; ------------------------------------------------------------
; Display formats
; ------------------------------------------------------------

; plain version (goes into the txt report)
fmt_expense_item   db '%d. %s - RM%d',10,0

; coloured version (goes on the screen)
fmt_screen_item    db YELLOW,'%d. ',WHITE,'%s',GREEN,' - RM%d',RESET,10,0

fmt_stat           db CYAN,'%s: ',GREEN,'%d',RESET,10,0

; The first 3 lines of a user's block in expense_report.txt
fmt_report_header_top:
    db 'User: %s',10
    db 'Monthly Budget: RM%d',10
    db 'Total Expense: RM%d',10,0

; The "Remaining" line - two versions, so it reads "-RM500"
; instead of the confusing "RM-500" when the budget is overspent
fmt_report_remaining_positive:
    db 'Remaining: RM%d',10,0

fmt_report_remaining_negative:
    db 'Remaining: -RM%d',10,0

fmt_report_separator:
    db '----------------------------------------',10,0

; Printed between two different users' blocks in expense_report.txt
; so they don't run straight into each other
blank_line_text:
    db 10,0

stat_accounts      db 'Total Accounts',0
stat_budgets       db 'Total Budget Records',0
stat_expenses      db 'Total Expense Records',0

default_category   db 'General',0


; ------------------------------------------------------------
; Password "encryption" = XOR with a secret number + HEX letters
; (this is what a reverse engineer will attack in the demo)
; ------------------------------------------------------------

xor_key equ 0x5A

hex_chars db '0123456789ABCDEF'

; These are written into accounts.txt for every account.
; The program does NOT care about upper/lower case when it
; reads these back (see strcmp_ci below), so "Admin", "admin"
; and "ADMIN" are all treated the same when logging in.
role_admin  db 'Admin',0
role_user   db 'User',0

default_admin_username db 'admin',0
default_admin_password db 'admin123',0


; ============================================================
; BSS SECTION  (empty boxes the program fills while running)
;
; resb RESERVES that many empty BYTES (1 byte each),
; resd RESERVES that many empty DOUBLEWORDS (4 bytes each),
; resq RESERVES that many empty QUADWORDS (8 bytes each).
; Nothing is written here yet - these are just empty boxes,
; ready for the program to fill in while it's running.
; ============================================================

section .bss

; ---- things typed in by the person using the program ----
input_buffer        resb 128   ; raw text just typed (menu choice, username, category...)
password_buffer     resb 128   ; raw password just typed, before scrambling
category_buffer     resb 128   ; the expense category just typed, after cleanup
current_user        resb 64    ; the username of whoever is logged in right now
current_role        resb 16    ; their role: "Admin" or "User"
encrypted_password  resb 256   ; a password AFTER scrambling (what we save to the file)
decoded_password    resb 256   ; a scrambled password turned BACK into real text

; ---- one line just read back out of a .txt file ----
file_user           resb 64    ; username read from a line of a file
file_password       resb 256   ; scrambled password read from accounts.txt
file_role           resb 16    ; role read from a line of accounts.txt
file_category       resb 64    ; category read from a line of expenses.txt
line_buffer         resb 256   ; one whole line of text read from any file

; ---- whole numbers the program needs to remember ----
budget_value        resd 1     ; the current user's monthly budget
amount_value        resd 1     ; the amount just typed for a new expense
total_value         resd 1     ; everything a user has spent, added up
remaining_value     resd 1     ; budget minus total (can go negative!)
expense_count       resd 1     ; how many expenses we've listed so far
account_count       resd 1     ; how many accounts exist (for statistics)
budget_count        resd 1     ; how many budget records exist
all_expense_count   resd 1     ; how many expense records exist (every user)
menu_choice         resd 1     ; the number the person just chose from a menu
report_count        resd 1     ; numbering (1, 2, 3...) for items in a report
file_amount         resd 1     ; an amount just read back out of a file
budget_found        resd 1     ; 1 if we found this user's old budget, else 0
admin_found         resd 1     ; 1 if the admin account already exists, else 0
display_lines       resd 1     ; how many lines we printed while showing a file
copy_skip           resd 1     ; 1 = skip this block while rebuilding the report
block_user          resb 64    ; whose block we're looking at in the report file
wrote_any_block     resd 1     ; 1 once we've written at least one block already

; ---- addresses of open files and other pointers ----
file_ptr            resq 1     ; the file currently open for reading/writing
report_ptr          resq 1     ; the report (or temp) file currently open
temp_ptr            resq 1     ; the temporary .tmp file currently open
display_filename    resq 1     ; which filename display_txt_file should open
display_title       resq 1     ; which title display_txt_file should print first


; ============================================================
; TEXT SECTION  (the real instructions)
; ============================================================

section .text


; ============================================================
; MAIN
; ============================================================

main:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    call initialize_files                     ; CALL - jumps into another function, and remembers how to come back
    call initialize_admin                     ; CALL - jumps into another function, and remembers how to come back

main_loop:
    lea rdi,[rel main_title]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel main_menu]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    call read_choice                          ; CALL - jumps into another function, and remembers how to come back
    mov [rel menu_choice],eax                 ; MOV = MOVE - copies a value from the right side into the left side

    cmp eax,1                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je main_login                             ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,2                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je main_create                            ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je main_exit                              ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    lea rdi,[rel msg_invalid_choice]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp main_loop                             ; JMP = JUMP - always jumps to this label, no condition needed


main_login:
    call login                                ; CALL - jumps into another function, and remembers how to come back
    cmp eax,1                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je main_after_login                       ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    jmp main_loop                             ; JMP = JUMP - always jumps to this label, no condition needed


main_after_login:
    ; is the role "admin" (any mix of upper/lower case)?
    lea rdi,[rel current_role]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel role_admin]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp_ci                            ; CALL - jumps into another function, and remembers how to come back
    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je main_admin                             ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    call user_menu_loop                       ; CALL - jumps into another function, and remembers how to come back
    jmp main_loop                             ; JMP = JUMP - always jumps to this label, no condition needed


main_admin:
    call admin_menu_loop                      ; CALL - jumps into another function, and remembers how to come back
    jmp main_loop                             ; JMP = JUMP - always jumps to this label, no condition needed


main_create:
    call create_account                       ; CALL - jumps into another function, and remembers how to come back
    jmp main_loop                             ; JMP = JUMP - always jumps to this label, no condition needed


main_exit:
    lea rdi,[rel msg_goodbye]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    mov eax,0                                 ; MOV = MOVE - copies a value from the right side into the left side
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; INITIALIZE FILES  (make sure the 4 txt files exist)
; ============================================================

initialize_files:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel file_accounts]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call touch_file                           ; CALL - jumps into another function, and remembers how to come back
    lea rdi,[rel file_budgets]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call touch_file                           ; CALL - jumps into another function, and remembers how to come back
    lea rdi,[rel file_expenses]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call touch_file                           ; CALL - jumps into another function, and remembers how to come back
    lea rdi,[rel file_report]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call touch_file                           ; CALL - jumps into another function, and remembers how to come back

    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; RDI = file name.  Opens in append mode (creates it) and closes.
touch_file:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rsi,[rel mode_append]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .done                                  ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov rdi,rax                               ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; INITIALIZE ADMIN  (create admin account if it is missing)
; ============================================================

initialize_admin:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    mov dword [rel admin_found],0             ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel file_accounts]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .create_admin                          ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.check_loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_account]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_password]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel file_role]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .close_check                          ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel default_admin_username]      ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .check_loop                           ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    mov dword [rel admin_found],1             ; MOV = MOVE - copies a value from the right side into the left side

.close_check:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    cmp dword [rel admin_found],1             ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .done                                  ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

.create_admin:
    lea rdi,[rel file_accounts]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_append]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .done                                  ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel default_admin_password]      ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel encrypted_password]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call encrypt_password_hex                 ; CALL - jumps into another function, and remembers how to come back

    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_account_write]           ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel default_admin_username]      ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel encrypted_password]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel role_admin]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back

    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; CREATE ACCOUNT
; ============================================================

create_account:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel create_title]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel prompt_new_username]         ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    call read_text                            ; CALL - jumps into another function, and remembers how to come back

    lea rsi,[rel input_buffer]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call copy_string                          ; CALL - jumps into another function, and remembers how to come back

    ; username must not be empty
    cmp byte [rel current_user],0             ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .empty                                 ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    ; check duplicate username
    lea rdi,[rel file_accounts]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .new_account                           ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.check_existing:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_account]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_password]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel file_role]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .close_existing                       ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .duplicate                             ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    jmp .check_existing                       ; JMP = JUMP - always jumps to this label, no condition needed

.close_existing:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back
    jmp .new_account                          ; JMP = JUMP - always jumps to this label, no condition needed

.duplicate:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel msg_account_exists]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.new_account:
    lea rdi,[rel prompt_new_password]         ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    call read_password                        ; CALL - jumps into another function, and remembers how to come back

    ; password must not be empty
    cmp byte [rel password_buffer],0          ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .empty                                 ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    lea rdi,[rel password_buffer]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel encrypted_password]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call encrypt_password_hex                 ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel file_accounts]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_append]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .file_error                            ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_account_write]           ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel encrypted_password]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel role_user]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back

    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel msg_account_created]         ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.empty:
    lea rdi,[rel msg_empty_input]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.file_error:
    lea rdi,[rel msg_file_error]              ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; LOGIN  (returns EAX = 1 success, 0 fail)
; ============================================================

login:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel login_title]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel prompt_username]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    call read_text                            ; CALL - jumps into another function, and remembers how to come back

    lea rsi,[rel input_buffer]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call copy_string                          ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel prompt_password]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    call read_password                        ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel file_accounts]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .failed                                ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.search:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_account]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_password]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel file_role]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .not_found                            ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .search                               ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    ; username found -> encrypt typed password and compare
    lea rdi,[rel password_buffer]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel encrypted_password]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call encrypt_password_hex                 ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel encrypted_password]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel file_password]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    ; If the password does not match THIS line, do not give up yet.
    ; Old buggy versions of this program could add more than one
    ; "admin" line to accounts.txt. Keep searching the rest of the
    ; file for another line with the same username that DOES match.
    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .search                               ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    ; success: remember the role
    lea rsi,[rel file_role]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdi,[rel current_role]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call copy_string                          ; CALL - jumps into another function, and remembers how to come back

    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel msg_login_success]           ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    mov eax,1                                 ; MOV = MOVE - copies a value from the right side into the left side
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from

.not_found:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

.failed:
    lea rdi,[rel msg_login_failed]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    mov eax,0                                 ; MOV = MOVE - copies a value from the right side into the left side
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; USER MENU LOOP
; ============================================================

user_menu_loop:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

.user_loop:
    lea rdi,[rel user_title]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel user_menu]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    call read_choice                          ; CALL - jumps into another function, and remembers how to come back
    mov [rel menu_choice],eax                 ; MOV = MOVE - copies a value from the right side into the left side

    cmp eax,1                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .set_budget                            ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,2                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .add_expense                           ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .view_expenses                         ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,4                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .total                                 ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,5                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .remaining                             ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,6                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .status                                ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,7                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .export                                ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,8                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .logout                                ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,9                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .exit                                  ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    lea rdi,[rel msg_invalid_choice]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .user_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.set_budget:
    call set_monthly_budget                   ; CALL - jumps into another function, and remembers how to come back
    jmp .user_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.add_expense:
    call add_expense                          ; CALL - jumps into another function, and remembers how to come back
    jmp .user_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.view_expenses:
    call view_my_expenses                     ; CALL - jumps into another function, and remembers how to come back
    jmp .user_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.total:
    call calculate_total                      ; CALL - jumps into another function, and remembers how to come back
    jmp .user_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.remaining:
    call show_remaining                       ; CALL - jumps into another function, and remembers how to come back
    jmp .user_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.status:
    call show_status                          ; CALL - jumps into another function, and remembers how to come back
    jmp .user_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.export:
    call export_report                        ; CALL - jumps into another function, and remembers how to come back
    jmp .user_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.logout:
    lea rdi,[rel msg_logout]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from

.exit:
    lea rdi,[rel msg_goodbye]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    xor edi,edi                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call exit                                 ; CALL - jumps into another function, and remembers how to come back


; ============================================================
; ADMIN MENU LOOP
; ============================================================

admin_menu_loop:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

.admin_loop:
    lea rdi,[rel admin_title]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel admin_menu]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    call read_choice                          ; CALL - jumps into another function, and remembers how to come back
    mov [rel menu_choice],eax                 ; MOV = MOVE - copies a value from the right side into the left side

    cmp eax,1                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .accounts                              ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,2                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .budgets                               ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .expenses                              ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,4                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .report                                ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,5                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .statistics                            ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,6                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .logout                                ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp eax,7                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .exit                                  ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    lea rdi,[rel msg_invalid_choice]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .admin_loop                           ; JMP = JUMP - always jumps to this label, no condition needed

.accounts:
    call view_accounts                        ; CALL - jumps into another function, and remembers how to come back
    jmp .admin_loop                           ; JMP = JUMP - always jumps to this label, no condition needed

.budgets:
    lea rdi,[rel title_budgets]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel file_budgets]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call display_txt_file                     ; CALL - jumps into another function, and remembers how to come back
    jmp .admin_loop                           ; JMP = JUMP - always jumps to this label, no condition needed

.expenses:
    lea rdi,[rel title_expenses]              ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel file_expenses]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call display_txt_file                     ; CALL - jumps into another function, and remembers how to come back
    jmp .admin_loop                           ; JMP = JUMP - always jumps to this label, no condition needed

.report:
    call display_report_file                  ; CALL - jumps into another function, and remembers how to come back
    jmp .admin_loop                           ; JMP = JUMP - always jumps to this label, no condition needed

.statistics:
    call system_statistics                    ; CALL - jumps into another function, and remembers how to come back
    jmp .admin_loop                           ; JMP = JUMP - always jumps to this label, no condition needed

.logout:
    lea rdi,[rel msg_logout]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from

.exit:
    lea rdi,[rel msg_goodbye]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    xor edi,edi                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call exit                                 ; CALL - jumps into another function, and remembers how to come back


; ============================================================
; SET MONTHLY BUDGET
; Replaces the current user's old budget. Others stay the same.
; ============================================================

set_monthly_budget:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel prompt_budget]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    call read_integer                         ; CALL - jumps into another function, and remembers how to come back

    cmp eax,1                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jl .invalid                               ; JL = JUMP IF LESS - jumps if the first value was smaller

    mov [rel budget_value],eax                ; MOV = MOVE - copies a value from the right side into the left side
    mov dword [rel budget_found],0            ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel file_budgets]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .create_new_file                       ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel file_budgets_temp]           ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_write]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .close_original_error                  ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel temp_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.copy_loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_budget]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_amount]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,2                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .copy_finished                        ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .replace_record                        ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    ; different user -> copy the old line
    mov rdi,[rel temp_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_budget_write]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov ecx,[rel file_amount]                 ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back
    jmp .copy_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.replace_record:
    mov dword [rel budget_found],1            ; MOV = MOVE - copies a value from the right side into the left side

    mov rdi,[rel temp_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_budget_write]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov ecx,[rel budget_value]                ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back
    jmp .copy_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.copy_finished:
    cmp dword [rel budget_found],0            ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .close_files                          ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    mov rdi,[rel temp_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_budget_write]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov ecx,[rel budget_value]                ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back

.close_files:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    mov rdi,[rel temp_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel file_budgets_temp]           ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel file_budgets]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call rename                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .update_error                         ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel msg_budget_saved]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.close_original_error:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back
    jmp .update_error                         ; JMP = JUMP - always jumps to this label, no condition needed

.create_new_file:
    lea rdi,[rel file_budgets]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_write]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .update_error                          ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_budget_write]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov ecx,[rel budget_value]                ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back

    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel msg_budget_saved]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.invalid:
    lea rdi,[rel msg_invalid_number]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.update_error:
    lea rdi,[rel msg_update_error]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; ADD EXPENSE
; ============================================================

add_expense:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel prompt_category]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    call read_text                            ; CALL - jumps into another function, and remembers how to come back

    ; empty category -> use "General"
    lea rsi,[rel input_buffer]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    cmp byte [rsi],0                          ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .copy_category                        ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different
    lea rsi,[rel default_category]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)

.copy_category:
    lea rdi,[rel category_buffer]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call copy_string                          ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel prompt_amount]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    call read_integer                         ; CALL - jumps into another function, and remembers how to come back

    cmp eax,1                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jl .invalid                               ; JL = JUMP IF LESS - jumps if the first value was smaller

    mov [rel amount_value],eax                ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel file_expenses]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_append]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .file_error                            ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_expense_write]           ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel category_buffer]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov r8d,[rel amount_value]                ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back

    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel msg_expense_saved]           ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.invalid:
    lea rdi,[rel msg_invalid_number]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.file_error:
    lea rdi,[rel msg_file_error]              ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; VIEW MY EXPENSES
; ============================================================

view_my_expenses:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    mov dword [rel expense_count],0           ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel file_expenses]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .no_expenses                           ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

    ; small blank line before the list
    lea rdi,[rel color_reset]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.view_loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_expense]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_category]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel file_amount]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .finished                             ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .view_loop                            ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    inc dword [rel expense_count]             ; INC = INCREMENT - adds 1

    ; printf(format, number, category, amount)
    lea rdi,[rel fmt_screen_item]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,[rel expense_count]               ; MOV = MOVE - copies a value from the right side into the left side
    lea rdx,[rel file_category]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov ecx,[rel file_amount]                 ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    jmp .view_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.finished:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    cmp dword [rel expense_count],0           ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .done                                 ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

.no_expenses:
    lea rdi,[rel msg_no_expenses]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; COMPUTE TOTAL  (silent: only fills total_value)
; ============================================================

compute_total:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    mov dword [rel total_value],0             ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel file_expenses]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .done                                  ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_expense]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_category]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel file_amount]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .close                                ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .loop                                 ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    mov eax,[rel total_value]                 ; MOV = MOVE - copies a value from the right side into the left side
    add eax,[rel file_amount]                 ; ADD - adds the right value onto the left value
    mov [rel total_value],eax                 ; MOV = MOVE - copies a value from the right side into the left side
    jmp .loop                                 ; JMP = JUMP - always jumps to this label, no condition needed

.close:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; CALCULATE TOTAL EXPENSE  (compute + print)
; ============================================================

calculate_total:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    mov dword [rel expense_count],0           ; MOV = MOVE - copies a value from the right side into the left side
    mov dword [rel total_value],0             ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel file_expenses]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .no_expenses                           ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

    ; blank line before the list
    lea rdi,[rel color_reset]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_expense]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_category]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel file_amount]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .finished                             ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .loop                                 ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    inc dword [rel expense_count]             ; INC = INCREMENT - adds 1

    ; print this one expense line on screen
    lea rdi,[rel fmt_screen_item]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,[rel expense_count]               ; MOV = MOVE - copies a value from the right side into the left side
    lea rdx,[rel file_category]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov ecx,[rel file_amount]                 ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    ; add this expense onto the running total
    mov eax,[rel total_value]                 ; MOV = MOVE - copies a value from the right side into the left side
    add eax,[rel file_amount]                 ; ADD - adds the right value onto the left value
    mov [rel total_value],eax                 ; MOV = MOVE - copies a value from the right side into the left side

    jmp .loop                                 ; JMP = JUMP - always jumps to this label, no condition needed

.finished:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    cmp dword [rel expense_count],0           ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .show_total                           ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

.no_expenses:
    lea rdi,[rel msg_no_expenses]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.show_total:
    ; print the grand total after the list, same as expense_report.txt
    lea rdi,[rel msg_total]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,[rel total_value]                 ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; LOAD CURRENT BUDGET
; ============================================================

load_current_budget:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    mov dword [rel budget_value],0            ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel file_budgets]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .done                                  ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_budget]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_amount]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,2                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .close                                ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .loop                                 ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    mov eax,[rel file_amount]                 ; MOV = MOVE - copies a value from the right side into the left side
    mov [rel budget_value],eax                ; MOV = MOVE - copies a value from the right side into the left side
    jmp .loop                                 ; JMP = JUMP - always jumps to this label, no condition needed

.close:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; SHOW REMAINING BUDGET
; ============================================================

show_remaining:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    call load_current_budget                  ; CALL - jumps into another function, and remembers how to come back

    cmp dword [rel budget_value],0            ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jle .no_budget                            ; JLE = JUMP IF LESS OR EQUAL - jumps if the first value was smaller or the same

    call compute_total                        ; CALL - jumps into another function, and remembers how to come back

    mov eax,[rel budget_value]                ; MOV = MOVE - copies a value from the right side into the left side
    sub eax,[rel total_value]                 ; SUB = SUBTRACT - subtracts the right value from the left value
    mov [rel remaining_value],eax             ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel msg_remaining_label]         ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    mov eax,[rel remaining_value]             ; MOV = MOVE - copies a value from the right side into the left side
    call print_rm_signed                      ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.no_budget:
    lea rdi,[rel msg_no_budget]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; CHECK BUDGET STATUS
; ============================================================

show_status:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    call load_current_budget                  ; CALL - jumps into another function, and remembers how to come back

    cmp dword [rel budget_value],0            ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jle .no_budget                            ; JLE = JUMP IF LESS OR EQUAL - jumps if the first value was smaller or the same

    call compute_total                        ; CALL - jumps into another function, and remembers how to come back

    ; spent more than budget ?
    mov eax,[rel total_value]                 ; MOV = MOVE - copies a value from the right side into the left side
    cmp eax,[rel budget_value]                ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jg .exceeded                              ; JG = JUMP IF GREATER - jumps if the first value was bigger

    ; percentage = total * 100 / budget
    imul eax,100                              ; IMUL = INTEGER MULTIPLY - multiplies two whole numbers
    cdq                                       ; CDQ = CONVERT DOUBLEWORD TO QUADWORD - gets EAX ready for IDIV by copying its sign into EDX
    mov ecx,[rel budget_value]                ; MOV = MOVE - copies a value from the right side into the left side
    idiv ecx                                  ; IDIV = INTEGER DIVIDE - divides EDX:EAX by this value (needs CDQ run first)

    cmp eax,90                                ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jge .warning                              ; JGE = JUMP IF GREATER OR EQUAL - jumps if the first value was bigger or the same

    lea rdi,[rel msg_budget_safe]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.warning:
    lea rdi,[rel msg_budget_warning]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.exceeded:
    lea rdi,[rel msg_budget_exceeded]         ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.no_budget:
    lea rdi,[rel msg_no_budget]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from



; ============================================================
; UPDATE LOCAL REPORT
;
; This keeps expense_report.txt tidy: ONE block per user, always
; showing their newest numbers, instead of a new block being
; piled on every single time someone exports.
;
; How it works (like rebuilding a photo album page by page):
;   1. Open the OLD expense_report.txt (if one exists) and a
;      brand-new empty TEMP file.
;   2. Read the old file one line at a time. Whenever a line
;      starts with "User: ", that's the start of somebody's
;      block. If it's a DIFFERENT person, copy their whole
;      block into the temp file untouched. If it's the SAME
;      person as the one exporting right now, skip that whole
;      old block completely (their old numbers are thrown away).
;   3. After going through the whole old file, write a FRESH
;      block for the current user at the very end of the temp
;      file, using today's numbers.
;   4. Rename the temp file so it becomes the real
;      expense_report.txt.
;
; Returns EAX = 1 on success, 0 if something went wrong.
; ============================================================

update_local_report:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    ; Try to open the OLD report. It's fine if it doesn't exist yet
    ; (first time ever exporting) - file_ptr will just be 0/NULL.
    lea rdi,[rel file_report]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back
    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

    ; Open a brand new TEMP file to build the tidy version in
    lea rdi,[rel file_report_temp]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_write]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .temp_fail                             ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel report_ptr],rax                  ; MOV = MOVE - copies a value from the right side into the left side
    mov dword [rel wrote_any_block],0   ; nothing written to the temp file yet ; MOV = MOVE - copies a value from the right side into the left side

    cmp qword [rel file_ptr],0                ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .skip_copy                             ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    mov dword [rel copy_skip],0     ; 0 = keep copying, 1 = skip this block ; MOV = MOVE - copies a value from the right side into the left side

.read_line:
    lea rdi,[rel line_buffer]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,256                               ; MOV = MOVE - copies a value from the right side into the left side
    mov rdx,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fgets                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .copy_done                   ; reached the end of the old file ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    ; does this line start a NEW person's block ("User: ...")?
    lea rdi,[rel line_buffer]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel report_prefix]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call starts_with                          ; CALL - jumps into another function, and remembers how to come back

    cmp eax,1                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .body_line                            ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    ; -------- yes, a new block is starting --------
    ; grab the username written on this line
    lea rsi,[rel line_buffer+6]     ; +6 skips past "User: " ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdi,[rel block_user]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call copy_string                          ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel block_user]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call remove_newline                       ; CALL - jumps into another function, and remembers how to come back

    ; is this block the SAME person who is exporting right now?
    lea rdi,[rel block_user]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .keep_this_block                      ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    mov dword [rel copy_skip],1     ; same person -> skip their old block ; MOV = MOVE - copies a value from the right side into the left side
    jmp .read_line                            ; JMP = JUMP - always jumps to this label, no condition needed

.keep_this_block:
    mov dword [rel copy_skip],0     ; a different person -> keep copying ; MOV = MOVE - copies a value from the right side into the left side

    ; put a blank line before this block, UNLESS it's the very
    ; first block being written (nothing to separate it from yet)
    cmp dword [rel wrote_any_block],0         ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .no_blank_before_copy                  ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    mov rdi,[rel report_ptr]                  ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel blank_line_text]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back

.no_blank_before_copy:
    mov dword [rel wrote_any_block],1         ; MOV = MOVE - copies a value from the right side into the left side

    mov rdi,[rel report_ptr]                  ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_line]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel line_buffer]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back
    jmp .read_line                            ; JMP = JUMP - always jumps to this label, no condition needed

.body_line:
    ; one of the detail lines belonging to whichever block we're in
    cmp dword [rel copy_skip],1               ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .read_line                   ; skipping this block -> throw it away ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    mov rdi,[rel report_ptr]                  ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_line]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel line_buffer]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back
    jmp .read_line                            ; JMP = JUMP - always jumps to this label, no condition needed

.copy_done:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

.skip_copy:
    ; -------- now add ONE fresh block for the current user --------

    ; put a blank line first, UNLESS this is the very first block
    ; being written into the whole file
    cmp dword [rel wrote_any_block],0         ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .no_blank_before_new                   ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    mov rdi,[rel report_ptr]                  ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel blank_line_text]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back

.no_blank_before_new:
    mov dword [rel wrote_any_block],1         ; MOV = MOVE - copies a value from the right side into the left side

    ; User / Monthly Budget / Total Expense lines
    mov rdi,[rel report_ptr]                  ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_report_header_top]       ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov ecx,[rel budget_value]                ; MOV = MOVE - copies a value from the right side into the left side
    mov r8d,[rel total_value]                 ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back

    ; Remaining line - pick the format that keeps the minus sign
    ; right in front of "RM", e.g. "-RM500" instead of "RM-500"
    mov eax,[rel budget_value]                ; MOV = MOVE - copies a value from the right side into the left side
    sub eax,[rel total_value]                 ; SUB = SUBTRACT - subtracts the right value from the left value
    mov [rel remaining_value],eax             ; MOV = MOVE - copies a value from the right side into the left side

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jl .file_remaining_negative               ; JL = JUMP IF LESS - jumps if the first value was smaller

    mov rdi,[rel report_ptr]                  ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_report_remaining_positive] ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov edx,eax                               ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back
    jmp .file_remaining_done                  ; JMP = JUMP - always jumps to this label, no condition needed

.file_remaining_negative:
    neg eax                                   ; NEG = NEGATE - flips the sign - positive becomes negative and back
    mov rdi,[rel report_ptr]                  ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_report_remaining_negative] ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov edx,eax                               ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back

.file_remaining_done:
    mov rdi,[rel report_ptr]                  ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_report_separator]        ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back

    mov dword [rel report_count],0            ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel file_expenses]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .close_temp                            ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.expense_loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_expense]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_category]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel file_amount]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .close_expenses                       ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .expense_loop                         ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    inc dword [rel report_count]              ; INC = INCREMENT - adds 1

    mov rdi,[rel report_ptr]                  ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_expense_item]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov edx,[rel report_count]                ; MOV = MOVE - copies a value from the right side into the left side
    lea rcx,[rel file_category]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov r8d,[rel file_amount]                 ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fprintf                              ; CALL - jumps into another function, and remembers how to come back
    jmp .expense_loop                         ; JMP = JUMP - always jumps to this label, no condition needed

.close_expenses:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

.close_temp:
    mov rdi,[rel report_ptr]                  ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    ; swap the tidy temp file in to become the real report file
    lea rdi,[rel file_report_temp]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel file_report]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call rename                               ; CALL - jumps into another function, and remembers how to come back

    mov eax,1                                 ; MOV = MOVE - copies a value from the right side into the left side
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from

.temp_fail:
    cmp qword [rel file_ptr],0                ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .temp_fail_done                        ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

.temp_fail_done:
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; EXPORT EXPENSE REPORT
; 1) update expense_report.txt (one tidy block per user)
; 2) write a copy into Windows Downloads
; ============================================================

export_report:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    call load_current_budget                  ; CALL - jumps into another function, and remembers how to come back
    call compute_total                        ; CALL - jumps into another function, and remembers how to come back

    ; keep expense_report.txt tidy: exactly one block per user
    call update_local_report                  ; CALL - jumps into another function, and remembers how to come back

    test eax,eax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .file_error                            ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    ; -------- show the report right here on screen --------
    lea rdi,[rel title_my_report]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel fmt_my_report_user]          ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel fmt_my_report_budget]        ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,[rel budget_value]                ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel fmt_my_report_total]         ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,[rel total_value]                 ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    mov eax,[rel budget_value]                ; MOV = MOVE - copies a value from the right side into the left side
    sub eax,[rel total_value]                 ; SUB = SUBTRACT - subtracts the right value from the left value
    mov [rel remaining_value],eax             ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel fmt_my_report_remaining_label] ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    mov eax,[rel remaining_value]             ; MOV = MOVE - copies a value from the right side into the left side
    call print_rm_signed                      ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel line_separator]              ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    ; -------- list this user's expenses underneath --------
    mov dword [rel expense_count],0           ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel file_expenses]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .no_expenses                           ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.list_loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_expense]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_category]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel file_amount]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .list_done                            ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel current_user]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call strcmp                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .list_loop                            ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    inc dword [rel expense_count]             ; INC = INCREMENT - adds 1

    lea rdi,[rel fmt_screen_item]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,[rel expense_count]               ; MOV = MOVE - copies a value from the right side into the left side
    lea rdx,[rel file_category]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov ecx,[rel file_amount]                 ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    jmp .list_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.list_done:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    cmp dword [rel expense_count],0           ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .done                                 ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

.no_expenses:
    lea rdi,[rel msg_no_expenses]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.file_error:
    lea rdi,[rel msg_file_error]              ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; ADMIN: DISPLAY TXT FILE
; RDI = title, RSI = file name
;
; BUG FIXED HERE: fgets wants (buffer, size, FILE*).
; The old code gave (FILE*, buffer, size) -> Segmentation fault.
; ============================================================

display_txt_file:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    mov [rel display_title],rdi               ; MOV = MOVE - copies a value from the right side into the left side
    mov [rel display_filename],rsi            ; MOV = MOVE - copies a value from the right side into the left side

    mov rdi,[rel display_title]               ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    mov rdi,[rel display_filename]            ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .file_error                            ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side
    mov dword [rel display_lines],0           ; MOV = MOVE - copies a value from the right side into the left side

    ; switch to bright white text
    lea rdi,[rel color_white]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.read_loop:
    lea rdi,[rel line_buffer]       ; 1st: where to store the text ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,256                     ; 2nd: how many characters max ; MOV = MOVE - copies a value from the right side into the left side
    mov rdx,[rel file_ptr]          ; 3rd: which file ; MOV = MOVE - copies a value from the right side into the left side
    call fgets                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .finished                              ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    inc dword [rel display_lines]             ; INC = INCREMENT - adds 1

    ; print with "%s" (safe way: file text is never used as a format)
    lea rdi,[rel fmt_line]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel line_buffer]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .read_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.finished:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel color_reset]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    cmp dword [rel display_lines],0           ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .done                                 ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel msg_no_data]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.file_error:
    lea rdi,[rel msg_file_error]              ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; ADMIN: DISPLAY expense_report.txt WITH HIGHLIGHTED USERNAMES
;
; This works just like display_txt_file above, but it watches
; for lines that start with "User: " and prints THOSE lines in
; a bold, underlined colour, so it's easy to see where one
; person's report ends and the next person's begins, even when
; the file has lots of people in it.
; ============================================================

display_report_file:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel title_report]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel file_report]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .file_error                            ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side
    mov dword [rel display_lines],0           ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel color_white]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.read_loop:
    lea rdi,[rel line_buffer]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,256                               ; MOV = MOVE - copies a value from the right side into the left side
    mov rdx,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fgets                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .finished                              ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    inc dword [rel display_lines]             ; INC = INCREMENT - adds 1

    ; does this line start with "User: " ?
    lea rdi,[rel line_buffer]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel report_prefix]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call starts_with                          ; CALL - jumps into another function, and remembers how to come back

    cmp eax,1                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .plain_line                           ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    ; yes - print it highlighted
    lea rdi,[rel fmt_report_user_highlight]   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel line_buffer]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .read_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.plain_line:
    ; an ordinary line (budget, total, expense item, blank line...)
    lea rdi,[rel fmt_line]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel line_buffer]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .read_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.finished:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel color_reset]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    cmp dword [rel display_lines],0           ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .done                                 ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    lea rdi,[rel msg_no_data]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.file_error:
    lea rdi,[rel msg_file_error]              ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; SYSTEM STATISTICS
; ============================================================

system_statistics:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    mov dword [rel account_count],0           ; MOV = MOVE - copies a value from the right side into the left side
    mov dword [rel budget_count],0            ; MOV = MOVE - copies a value from the right side into the left side
    mov dword [rel all_expense_count],0       ; MOV = MOVE - copies a value from the right side into the left side

    ; ---- count accounts ----
    lea rdi,[rel file_accounts]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .count_budgets                         ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.account_loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_account]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_password]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel file_role]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .close_accounts                       ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    inc dword [rel account_count]             ; INC = INCREMENT - adds 1
    jmp .account_loop                         ; JMP = JUMP - always jumps to this label, no condition needed

.close_accounts:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    ; ---- count budgets ----
.count_budgets:
    lea rdi,[rel file_budgets]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .count_expenses                        ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.budget_loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_budget]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_amount]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,2                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .close_budgets                        ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    inc dword [rel budget_count]              ; INC = INCREMENT - adds 1
    jmp .budget_loop                          ; JMP = JUMP - always jumps to this label, no condition needed

.close_budgets:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

    ; ---- count expenses ----
.count_expenses:
    lea rdi,[rel file_expenses]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .display                               ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.expense_loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_expense]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_category]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel file_amount]                  ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .close_expenses                       ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    inc dword [rel all_expense_count]         ; INC = INCREMENT - adds 1
    jmp .expense_loop                         ; JMP = JUMP - always jumps to this label, no condition needed

.close_expenses:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back

.display:
    lea rdi,[rel title_stats]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel fmt_stat]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel stat_accounts]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov edx,[rel account_count]               ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel fmt_stat]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel stat_budgets]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov edx,[rel budget_count]                ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel fmt_stat]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel stat_expenses]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov edx,[rel all_expense_count]           ; MOV = MOVE - copies a value from the right side into the left side
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; READ CHOICE  (menu number)
; ============================================================

read_choice:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel prompt_choice]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel input_buffer]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,128                               ; MOV = MOVE - copies a value from the right side into the left side
    mov rdx,[rel stdin]                       ; MOV = MOVE - copies a value from the right side into the left side
    call fgets                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .end_of_input                          ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    lea rdi,[rel input_buffer]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call atoi                                 ; CALL - jumps into another function, and remembers how to come back

    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from

.end_of_input:
    ; Ctrl+D pressed -> leave the program politely
    xor edi,edi                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call exit                                 ; CALL - jumps into another function, and remembers how to come back


; ============================================================
; READ INTEGER
; ============================================================

read_integer:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel input_buffer]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,128                               ; MOV = MOVE - copies a value from the right side into the left side
    mov rdx,[rel stdin]                       ; MOV = MOVE - copies a value from the right side into the left side
    call fgets                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .zero                                  ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    lea rdi,[rel input_buffer]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call atoi                                 ; CALL - jumps into another function, and remembers how to come back

    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from

.zero:
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; READ TEXT  (username / category)
; Spaces become "_" so the txt file format never breaks.
; ============================================================

read_text:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel input_buffer]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,128                               ; MOV = MOVE - copies a value from the right side into the left side
    mov rdx,[rel stdin]                       ; MOV = MOVE - copies a value from the right side into the left side
    call fgets                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .empty                                 ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    lea rdi,[rel input_buffer]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call remove_newline                       ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel input_buffer]                ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call replace_spaces                       ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.empty:
    mov byte [rel input_buffer],0             ; MOV = MOVE - copies a value from the right side into the left side

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; READ PASSWORD
; ============================================================

read_password:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel password_buffer]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    mov esi,128                               ; MOV = MOVE - copies a value from the right side into the left side
    mov rdx,[rel stdin]                       ; MOV = MOVE - copies a value from the right side into the left side
    call fgets                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .empty                                 ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    lea rdi,[rel password_buffer]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call remove_newline                       ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.empty:
    mov byte [rel password_buffer],0          ; MOV = MOVE - copies a value from the right side into the left side

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; REMOVE NEWLINE  (RDI = text)
; ============================================================

remove_newline:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    mov rsi,rdi                               ; MOV = MOVE - copies a value from the right side into the left side

.loop:
    mov al,[rsi]                              ; MOV = MOVE - copies a value from the right side into the left side

    cmp al,0                                  ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .done                                  ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp al,10                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .replace                               ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal
    cmp al,13                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .replace                               ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    inc rsi                                   ; INC = INCREMENT - adds 1
    jmp .loop                                 ; JMP = JUMP - always jumps to this label, no condition needed

.replace:
    mov byte [rsi],0                          ; MOV = MOVE - copies a value from the right side into the left side

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; REPLACE SPACES WITH "_"  (RDI = text)
; ============================================================

replace_spaces:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

.loop:
    mov al,[rdi]                              ; MOV = MOVE - copies a value from the right side into the left side

    cmp al,0                                  ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .done                                  ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    cmp al,' '                                ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .next                                 ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different
    mov byte [rdi],'_'                        ; MOV = MOVE - copies a value from the right side into the left side

.next:
    inc rdi                                   ; INC = INCREMENT - adds 1
    jmp .loop                                 ; JMP = JUMP - always jumps to this label, no condition needed

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; COPY STRING  (RDI = destination, RSI = source)
; Copies at most 63 letters, so it can never overflow a
; 64-byte box.
; ============================================================

copy_string:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    mov rdx,rsi                               ; MOV = MOVE - copies a value from the right side into the left side
    mov ecx,63                                ; MOV = MOVE - copies a value from the right side into the left side

.copy_loop:
    mov al,[rdx]                              ; MOV = MOVE - copies a value from the right side into the left side
    mov [rdi],al                              ; MOV = MOVE - copies a value from the right side into the left side

    cmp al,0                                  ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .done                                  ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    inc rdx                                   ; INC = INCREMENT - adds 1
    inc rdi                                   ; INC = INCREMENT - adds 1

    dec ecx                                   ; DEC = DECREMENT - subtracts 1
    jnz .copy_loop                            ; JNZ = JUMP IF NOT ZERO - jumps only if the last result was NOT zero

    mov byte [rdi],0                          ; MOV = MOVE - copies a value from the right side into the left side

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; STRCMP_CI  ("compare text, ignore UPPER/lower case")
;
; RDI = first piece of text, RSI = second piece of text.
; Returns EAX = 0 if they are the same word (ignoring case),
; or EAX = 1 if they are different.
;
; Used ONLY for comparing the ROLE ("Admin"/"admin"/"User"...).
; Usernames and passwords still use the normal, exact strcmp,
; because those SHOULD be case-sensitive.
; ============================================================

strcmp_ci:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

.loop:
    movzx eax,byte [rdi]     ; one letter from the first word ; MOVZX = MOVE WITH ZERO-EXTEND - copies a small value into a bigger box, filling the rest with 0s
    movzx edx,byte [rsi]     ; the matching letter from the second word ; MOVZX = MOVE WITH ZERO-EXTEND - copies a small value into a bigger box, filling the rest with 0s

    ; If the letter from word 1 is A-Z, turn it into a-z
    cmp al,'A'                                ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jb .skip_lower_al                         ; JB = JUMP IF BELOW - like JL, but for unsigned (always-positive) numbers
    cmp al,'Z'                                ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    ja .skip_lower_al                         ; JA = JUMP IF ABOVE - like JG, but for unsigned (always-positive) numbers
    add al,32                                 ; ADD - adds the right value onto the left value
.skip_lower_al:

    ; Do the same for the letter from word 2
    cmp dl,'A'                                ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jb .skip_lower_dl                         ; JB = JUMP IF BELOW - like JL, but for unsigned (always-positive) numbers
    cmp dl,'Z'                                ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    ja .skip_lower_dl                         ; JA = JUMP IF ABOVE - like JG, but for unsigned (always-positive) numbers
    add dl,32                                 ; ADD - adds the right value onto the left value
.skip_lower_dl:

    cmp al,dl                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .different                            ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    ; both letters are 0 (end of both words) -> they matched all the way
    test al,al                                ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .same                                  ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    inc rdi                                   ; INC = INCREMENT - adds 1
    inc rsi                                   ; INC = INCREMENT - adds 1
    jmp .loop                                 ; JMP = JUMP - always jumps to this label, no condition needed

.same:
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from

.different:
    mov eax,1                                 ; MOV = MOVE - copies a value from the right side into the left side
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; STARTS_WITH  ("does this line begin with these words?")
;
; RDI = a full line of text, RSI = the words to look for at
; the very beginning (like "User: ").
; Returns EAX = 1 if it matches, 0 if it does not.
; ============================================================

starts_with:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

.loop:
    movzx eax,byte [rsi]     ; next letter we're looking for ; MOVZX = MOVE WITH ZERO-EXTEND - copies a small value into a bigger box, filling the rest with 0s
    test al,al                                ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .yes                  ; we checked every letter we needed - match! ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    movzx edx,byte [rdi]     ; the matching letter in the line ; MOVZX = MOVE WITH ZERO-EXTEND - copies a small value into a bigger box, filling the rest with 0s
    cmp al,dl                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .no                                   ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    inc rdi                                   ; INC = INCREMENT - adds 1
    inc rsi                                   ; INC = INCREMENT - adds 1
    jmp .loop                                 ; JMP = JUMP - always jumps to this label, no condition needed

.yes:
    mov eax,1                                 ; MOV = MOVE - copies a value from the right side into the left side
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from

.no:
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; PRINT_RM_SIGNED
;
; Prints a money amount the friendly way: "RM100" in green if
; it's zero or positive, or "-RM100" in red if it's negative
; (instead of the confusing "RM-100"). Also prints a newline.
;
; EAX = the amount to print. Does NOT print any label text -
; the caller prints the label (like "Remaining: ") first.
; ============================================================

print_rm_signed:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    cmp eax,0                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jl .negative                              ; JL = JUMP IF LESS - jumps if the first value was smaller

    ; zero or positive -> green "RM<number>"
    mov esi,eax                               ; MOV = MOVE - copies a value from the right side into the left side
    lea rdi,[rel fmt_rm_positive]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.negative:
    neg eax                      ; flip -500 into 500 so we can print it ; NEG = NEGATE - flips the sign - positive becomes negative and back
    mov esi,eax                               ; MOV = MOVE - copies a value from the right side into the left side
    lea rdi,[rel fmt_rm_negative]             ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; ENCRYPT PASSWORD USING XOR + HEX
; RDI = plain password, RSI = output
; Example: 'a' (0x61) XOR 0x5A = 0x3B  ->  "3B"
; ============================================================

encrypt_password_hex:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rcx,[rel hex_chars]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)

.loop:
    movzx eax,byte [rdi]                      ; MOVZX = MOVE WITH ZERO-EXTEND - copies a small value into a bigger box, filling the rest with 0s
    test al,al                                ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .finish                                ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    xor al,xor_key                            ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0

    movzx edx,al                              ; MOVZX = MOVE WITH ZERO-EXTEND - copies a small value into a bigger box, filling the rest with 0s
    shr edx,4                   ; high half   ; SHR = SHIFT RIGHT - slides the bits right - the same as dividing by 2 each time
    mov r8b,[rcx+rdx]                         ; MOV = MOVE - copies a value from the right side into the left side
    mov [rsi],r8b                             ; MOV = MOVE - copies a value from the right side into the left side

    and eax,0x0F                ; low half    ; AND = BITWISE AND - keeps only the bits that are 1 in both values
    mov r8b,[rcx+rax]                         ; MOV = MOVE - copies a value from the right side into the left side
    mov [rsi+1],r8b                           ; MOV = MOVE - copies a value from the right side into the left side

    add rsi,2                                 ; ADD - adds the right value onto the left value
    inc rdi                                   ; INC = INCREMENT - adds 1
    jmp .loop                                 ; JMP = JUMP - always jumps to this label, no condition needed

.finish:
    mov byte [rsi],0                          ; MOV = MOVE - copies a value from the right side into the left side

    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; DECRYPT PASSWORD USING HEX + XOR
; This is the exact OPPOSITE of encrypt_password_hex above -
; it turns the stored HEX text back into the real password.
;
; RDI = HEX text (like "3B3E3733346B6869")
; RSI = output buffer for the real password (like "admin123")
; ============================================================

decrypt_password_hex:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

.loop:
    movzx eax,byte [rdi]                      ; MOVZX = MOVE WITH ZERO-EXTEND - copies a small value into a bigger box, filling the rest with 0s
    test al,al                                ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .finish                                ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    ; turn the FIRST hex letter into a number 0-15
    cmp al,'9'                                ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jbe .hi_digit                             ; JBE = JUMP IF BELOW OR EQUAL - like JLE, but for unsigned (always-positive) numbers
    sub al,55                   ; 'A' is 65, and 65-55=10 ; SUB = SUBTRACT - subtracts the right value from the left value
    jmp .hi_done                              ; JMP = JUMP - always jumps to this label, no condition needed
.hi_digit:
    sub al,'0'                                ; SUB = SUBTRACT - subtracts the right value from the left value
.hi_done:
    shl al,4                    ; this number goes in the top half ; SHL = SHIFT LEFT - slides the bits left - the same as multiplying by 2 each time
    mov dl,al                                 ; MOV = MOVE - copies a value from the right side into the left side

    ; turn the SECOND hex letter into a number 0-15
    movzx eax,byte [rdi+1]                    ; MOVZX = MOVE WITH ZERO-EXTEND - copies a small value into a bigger box, filling the rest with 0s
    cmp al,'9'                                ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jbe .lo_digit                             ; JBE = JUMP IF BELOW OR EQUAL - like JLE, but for unsigned (always-positive) numbers
    sub al,55                                 ; SUB = SUBTRACT - subtracts the right value from the left value
    jmp .lo_done                              ; JMP = JUMP - always jumps to this label, no condition needed
.lo_digit:
    sub al,'0'                                ; SUB = SUBTRACT - subtracts the right value from the left value
.lo_done:
    or al,dl                    ; combine both halves into one byte ; OR = BITWISE OR - keeps bits that are 1 in either value
    xor al,xor_key               ; undo the XOR scrambling ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    mov [rsi],al                              ; MOV = MOVE - copies a value from the right side into the left side

    inc rsi                                   ; INC = INCREMENT - adds 1
    add rdi,2                   ; move 2 letters forward (one hex pair) ; ADD - adds the right value onto the left value
    jmp .loop                                 ; JMP = JUMP - always jumps to this label, no condition needed

.finish:
    mov byte [rsi],0                          ; MOV = MOVE - copies a value from the right side into the left side

    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


; ============================================================
; VIEW ACCOUNTS  (admin menu option 1)
;
; Asks the admin whether they want to see accounts.txt exactly
; as it's stored (scrambled passwords), or decoded into plain,
; readable passwords.
; ============================================================

view_accounts:
    push rbp                                  ; PUSH - puts this value on top of the stack, for safekeeping
    mov rbp,rsp                               ; MOV = MOVE - copies a value from the right side into the left side

    lea rdi,[rel prompt_view_mode]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    call read_choice                          ; CALL - jumps into another function, and remembers how to come back

    cmp eax,2                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    je .plain_mode                            ; JE = JUMP IF EQUAL - jumps only if the last CMP/TEST found the values equal

    ; choice 1 (or anything else) -> show the file exactly as stored
    lea rdi,[rel title_accounts]              ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel file_accounts]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call display_txt_file                     ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.plain_mode:
    lea rdi,[rel title_accounts_plain]        ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel file_accounts]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel mode_read]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call fopen                                ; CALL - jumps into another function, and remembers how to come back

    test rax,rax                              ; TEST - checks bits using AND, without changing the values - often used to test for zero
    jz .file_error                            ; JZ = JUMP IF ZERO - jumps only if the last result was zero (same idea as JE)

    mov [rel file_ptr],rax                    ; MOV = MOVE - copies a value from the right side into the left side

.read_loop:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    lea rsi,[rel fmt_account]                 ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_password]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea r8,[rel file_role]                    ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call fscanf                               ; CALL - jumps into another function, and remembers how to come back

    cmp eax,3                                 ; CMP = COMPARE - compares two values (doesn't change them) for the next jump
    jne .close                                ; JNE = JUMP IF NOT EQUAL - jumps only if the last CMP/TEST found the values different

    ; turn the scrambled password back into the real one
    lea rdi,[rel file_password]               ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel decoded_password]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    call decrypt_password_hex                 ; CALL - jumps into another function, and remembers how to come back

    lea rdi,[rel fmt_account_plain]           ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rsi,[rel file_user]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rdx,[rel decoded_password]            ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    lea rcx,[rel file_role]                   ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

    jmp .read_loop                            ; JMP = JUMP - always jumps to this label, no condition needed

.close:
    mov rdi,[rel file_ptr]                    ; MOV = MOVE - copies a value from the right side into the left side
    call fclose                               ; CALL - jumps into another function, and remembers how to come back
    jmp .done                                 ; JMP = JUMP - always jumps to this label, no condition needed

.file_error:
    lea rdi,[rel msg_file_error]              ; LEA = LOAD EFFECTIVE ADDRESS - calculates an address and stores it (doesn't read memory)
    xor eax,eax                               ; XOR = EXCLUSIVE OR - flips bits that differ; "xor eax,eax" is a fast way to set it to 0
    call printf                               ; CALL - jumps into another function, and remembers how to come back

.done:
    leave                                     ; LEAVE - undoes 'push rbp / mov rbp,rsp' from the top of the function
    ret                                       ; RET = RETURN - goes back to wherever this function was called from


section .note.GNU-stack noexec
