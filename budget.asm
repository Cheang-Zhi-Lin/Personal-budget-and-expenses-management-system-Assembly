default rel

; ============================================================
; PERSONAL EXPENSE & BUDGET MANAGEMENT SYSTEM
;
;   accounts.txt = list of students (who can log in)
;   budgets.txt  = how much money each person may spend
;   expenses.txt = what each person already spent
; ============================================================

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
; ============================================================

section .bss

input_buffer        resb 128
password_buffer     resb 128
category_buffer     resb 128
current_user        resb 64
current_role        resb 16
encrypted_password  resb 256
decoded_password    resb 256

file_user           resb 64
file_password       resb 256
file_role           resb 16
file_category       resb 64
line_buffer         resb 256

budget_value        resd 1
amount_value        resd 1
total_value         resd 1
remaining_value     resd 1
expense_count       resd 1
account_count       resd 1
budget_count        resd 1
all_expense_count   resd 1
menu_choice         resd 1
report_count        resd 1
file_amount         resd 1
budget_found        resd 1
admin_found         resd 1
display_lines       resd 1
copy_skip           resd 1
block_user          resb 64
wrote_any_block     resd 1

file_ptr            resq 1
report_ptr          resq 1
temp_ptr            resq 1
display_filename    resq 1
display_title       resq 1


; ============================================================
; TEXT SECTION  (the real instructions)
; ============================================================

section .text


; ============================================================
; MAIN
; ============================================================

main:
    push rbp
    mov rbp,rsp

    call initialize_files
    call initialize_admin

main_loop:
    lea rdi,[rel main_title]
    xor eax,eax
    call printf

    lea rdi,[rel main_menu]
    xor eax,eax
    call printf

    call read_choice
    mov [rel menu_choice],eax

    cmp eax,1
    je main_login
    cmp eax,2
    je main_create
    cmp eax,3
    je main_exit

    lea rdi,[rel msg_invalid_choice]
    xor eax,eax
    call printf
    jmp main_loop


main_login:
    call login
    cmp eax,1
    je main_after_login
    jmp main_loop


main_after_login:
    ; is the role "admin" (any mix of upper/lower case)?
    lea rdi,[rel current_role]
    lea rsi,[rel role_admin]
    call strcmp_ci
    cmp eax,0
    je main_admin

    call user_menu_loop
    jmp main_loop


main_admin:
    call admin_menu_loop
    jmp main_loop


main_create:
    call create_account
    jmp main_loop


main_exit:
    lea rdi,[rel msg_goodbye]
    xor eax,eax
    call printf

    mov eax,0
    leave
    ret


; ============================================================
; INITIALIZE FILES  (make sure the 4 txt files exist)
; ============================================================

initialize_files:
    push rbp
    mov rbp,rsp

    lea rdi,[rel file_accounts]
    call touch_file
    lea rdi,[rel file_budgets]
    call touch_file
    lea rdi,[rel file_expenses]
    call touch_file
    lea rdi,[rel file_report]
    call touch_file

    leave
    ret


; RDI = file name.  Opens in append mode (creates it) and closes.
touch_file:
    push rbp
    mov rbp,rsp

    lea rsi,[rel mode_append]
    call fopen

    test rax,rax
    jz .done

    mov rdi,rax
    call fclose

.done:
    leave
    ret


; ============================================================
; INITIALIZE ADMIN  (create admin account if it is missing)
; ============================================================

initialize_admin:
    push rbp
    mov rbp,rsp

    mov dword [rel admin_found],0

    lea rdi,[rel file_accounts]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .create_admin

    mov [rel file_ptr],rax

.check_loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_account]
    lea rdx,[rel file_user]
    lea rcx,[rel file_password]
    lea r8,[rel file_role]
    xor eax,eax
    call fscanf

    cmp eax,3
    jne .close_check

    lea rdi,[rel file_user]
    lea rsi,[rel default_admin_username]
    call strcmp

    cmp eax,0
    jne .check_loop

    mov dword [rel admin_found],1

.close_check:
    mov rdi,[rel file_ptr]
    call fclose

    cmp dword [rel admin_found],1
    je .done

.create_admin:
    lea rdi,[rel file_accounts]
    lea rsi,[rel mode_append]
    call fopen

    test rax,rax
    jz .done

    mov [rel file_ptr],rax

    lea rdi,[rel default_admin_password]
    lea rsi,[rel encrypted_password]
    call encrypt_password_hex

    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_account_write]
    lea rdx,[rel default_admin_username]
    lea rcx,[rel encrypted_password]
    lea r8,[rel role_admin]
    xor eax,eax
    call fprintf

    mov rdi,[rel file_ptr]
    call fclose

.done:
    leave
    ret


; ============================================================
; CREATE ACCOUNT
; ============================================================

create_account:
    push rbp
    mov rbp,rsp

    lea rdi,[rel create_title]
    xor eax,eax
    call printf

    lea rdi,[rel prompt_new_username]
    xor eax,eax
    call printf

    call read_text

    lea rsi,[rel input_buffer]
    lea rdi,[rel current_user]
    call copy_string

    ; username must not be empty
    cmp byte [rel current_user],0
    je .empty

    ; check duplicate username
    lea rdi,[rel file_accounts]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .new_account

    mov [rel file_ptr],rax

.check_existing:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_account]
    lea rdx,[rel file_user]
    lea rcx,[rel file_password]
    lea r8,[rel file_role]
    xor eax,eax
    call fscanf

    cmp eax,3
    jne .close_existing

    lea rdi,[rel current_user]
    lea rsi,[rel file_user]
    call strcmp

    cmp eax,0
    je .duplicate

    jmp .check_existing

.close_existing:
    mov rdi,[rel file_ptr]
    call fclose
    jmp .new_account

.duplicate:
    mov rdi,[rel file_ptr]
    call fclose

    lea rdi,[rel msg_account_exists]
    xor eax,eax
    call printf
    jmp .done

.new_account:
    lea rdi,[rel prompt_new_password]
    xor eax,eax
    call printf

    call read_password

    ; password must not be empty
    cmp byte [rel password_buffer],0
    je .empty

    lea rdi,[rel password_buffer]
    lea rsi,[rel encrypted_password]
    call encrypt_password_hex

    lea rdi,[rel file_accounts]
    lea rsi,[rel mode_append]
    call fopen

    test rax,rax
    jz .file_error

    mov [rel file_ptr],rax

    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_account_write]
    lea rdx,[rel current_user]
    lea rcx,[rel encrypted_password]
    lea r8,[rel role_user]
    xor eax,eax
    call fprintf

    mov rdi,[rel file_ptr]
    call fclose

    lea rdi,[rel msg_account_created]
    xor eax,eax
    call printf
    jmp .done

.empty:
    lea rdi,[rel msg_empty_input]
    xor eax,eax
    call printf
    jmp .done

.file_error:
    lea rdi,[rel msg_file_error]
    xor eax,eax
    call printf

.done:
    leave
    ret


; ============================================================
; LOGIN  (returns EAX = 1 success, 0 fail)
; ============================================================

login:
    push rbp
    mov rbp,rsp

    lea rdi,[rel login_title]
    xor eax,eax
    call printf

    lea rdi,[rel prompt_username]
    xor eax,eax
    call printf

    call read_text

    lea rsi,[rel input_buffer]
    lea rdi,[rel current_user]
    call copy_string

    lea rdi,[rel prompt_password]
    xor eax,eax
    call printf

    call read_password

    lea rdi,[rel file_accounts]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .failed

    mov [rel file_ptr],rax

.search:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_account]
    lea rdx,[rel file_user]
    lea rcx,[rel file_password]
    lea r8,[rel file_role]
    xor eax,eax
    call fscanf

    cmp eax,3
    jne .not_found

    lea rdi,[rel current_user]
    lea rsi,[rel file_user]
    call strcmp

    cmp eax,0
    jne .search

    ; username found -> encrypt typed password and compare
    lea rdi,[rel password_buffer]
    lea rsi,[rel encrypted_password]
    call encrypt_password_hex

    lea rdi,[rel encrypted_password]
    lea rsi,[rel file_password]
    call strcmp

    ; If the password does not match THIS line, do not give up yet.
    ; Old buggy versions of this program could add more than one
    ; "admin" line to accounts.txt. Keep searching the rest of the
    ; file for another line with the same username that DOES match.
    cmp eax,0
    jne .search

    ; success: remember the role
    lea rsi,[rel file_role]
    lea rdi,[rel current_role]
    call copy_string

    mov rdi,[rel file_ptr]
    call fclose

    lea rdi,[rel msg_login_success]
    xor eax,eax
    call printf

    mov eax,1
    leave
    ret

.not_found:
    mov rdi,[rel file_ptr]
    call fclose

.failed:
    lea rdi,[rel msg_login_failed]
    xor eax,eax
    call printf

    mov eax,0
    leave
    ret


; ============================================================
; USER MENU LOOP
; ============================================================

user_menu_loop:
    push rbp
    mov rbp,rsp

.user_loop:
    lea rdi,[rel user_title]
    xor eax,eax
    call printf

    lea rdi,[rel user_menu]
    xor eax,eax
    call printf

    call read_choice
    mov [rel menu_choice],eax

    cmp eax,1
    je .set_budget
    cmp eax,2
    je .add_expense
    cmp eax,3
    je .view_expenses
    cmp eax,4
    je .total
    cmp eax,5
    je .remaining
    cmp eax,6
    je .status
    cmp eax,7
    je .export
    cmp eax,8
    je .logout
    cmp eax,9
    je .exit

    lea rdi,[rel msg_invalid_choice]
    xor eax,eax
    call printf
    jmp .user_loop

.set_budget:
    call set_monthly_budget
    jmp .user_loop

.add_expense:
    call add_expense
    jmp .user_loop

.view_expenses:
    call view_my_expenses
    jmp .user_loop

.total:
    call calculate_total
    jmp .user_loop

.remaining:
    call show_remaining
    jmp .user_loop

.status:
    call show_status
    jmp .user_loop

.export:
    call export_report
    jmp .user_loop

.logout:
    lea rdi,[rel msg_logout]
    xor eax,eax
    call printf

    leave
    ret

.exit:
    lea rdi,[rel msg_goodbye]
    xor eax,eax
    call printf

    xor edi,edi
    call exit


; ============================================================
; ADMIN MENU LOOP
; ============================================================

admin_menu_loop:
    push rbp
    mov rbp,rsp

.admin_loop:
    lea rdi,[rel admin_title]
    xor eax,eax
    call printf

    lea rdi,[rel admin_menu]
    xor eax,eax
    call printf

    call read_choice
    mov [rel menu_choice],eax

    cmp eax,1
    je .accounts
    cmp eax,2
    je .budgets
    cmp eax,3
    je .expenses
    cmp eax,4
    je .report
    cmp eax,5
    je .statistics
    cmp eax,6
    je .logout
    cmp eax,7
    je .exit

    lea rdi,[rel msg_invalid_choice]
    xor eax,eax
    call printf
    jmp .admin_loop

.accounts:
    call view_accounts
    jmp .admin_loop

.budgets:
    lea rdi,[rel title_budgets]
    lea rsi,[rel file_budgets]
    call display_txt_file
    jmp .admin_loop

.expenses:
    lea rdi,[rel title_expenses]
    lea rsi,[rel file_expenses]
    call display_txt_file
    jmp .admin_loop

.report:
    call display_report_file
    jmp .admin_loop

.statistics:
    call system_statistics
    jmp .admin_loop

.logout:
    lea rdi,[rel msg_logout]
    xor eax,eax
    call printf

    leave
    ret

.exit:
    lea rdi,[rel msg_goodbye]
    xor eax,eax
    call printf

    xor edi,edi
    call exit


; ============================================================
; SET MONTHLY BUDGET
; Replaces the current user's old budget. Others stay the same.
; ============================================================

set_monthly_budget:
    push rbp
    mov rbp,rsp

    lea rdi,[rel prompt_budget]
    xor eax,eax
    call printf

    call read_integer

    cmp eax,1
    jl .invalid

    mov [rel budget_value],eax
    mov dword [rel budget_found],0

    lea rdi,[rel file_budgets]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .create_new_file

    mov [rel file_ptr],rax

    lea rdi,[rel file_budgets_temp]
    lea rsi,[rel mode_write]
    call fopen

    test rax,rax
    jz .close_original_error

    mov [rel temp_ptr],rax

.copy_loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_budget]
    lea rdx,[rel file_user]
    lea rcx,[rel file_amount]
    xor eax,eax
    call fscanf

    cmp eax,2
    jne .copy_finished

    lea rdi,[rel file_user]
    lea rsi,[rel current_user]
    call strcmp

    cmp eax,0
    je .replace_record

    ; different user -> copy the old line
    mov rdi,[rel temp_ptr]
    lea rsi,[rel fmt_budget_write]
    lea rdx,[rel file_user]
    mov ecx,[rel file_amount]
    xor eax,eax
    call fprintf
    jmp .copy_loop

.replace_record:
    mov dword [rel budget_found],1

    mov rdi,[rel temp_ptr]
    lea rsi,[rel fmt_budget_write]
    lea rdx,[rel current_user]
    mov ecx,[rel budget_value]
    xor eax,eax
    call fprintf
    jmp .copy_loop

.copy_finished:
    cmp dword [rel budget_found],0
    jne .close_files

    mov rdi,[rel temp_ptr]
    lea rsi,[rel fmt_budget_write]
    lea rdx,[rel current_user]
    mov ecx,[rel budget_value]
    xor eax,eax
    call fprintf

.close_files:
    mov rdi,[rel file_ptr]
    call fclose

    mov rdi,[rel temp_ptr]
    call fclose

    lea rdi,[rel file_budgets_temp]
    lea rsi,[rel file_budgets]
    call rename

    cmp eax,0
    jne .update_error

    lea rdi,[rel msg_budget_saved]
    xor eax,eax
    call printf
    jmp .done

.close_original_error:
    mov rdi,[rel file_ptr]
    call fclose
    jmp .update_error

.create_new_file:
    lea rdi,[rel file_budgets]
    lea rsi,[rel mode_write]
    call fopen

    test rax,rax
    jz .update_error

    mov [rel file_ptr],rax

    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_budget_write]
    lea rdx,[rel current_user]
    mov ecx,[rel budget_value]
    xor eax,eax
    call fprintf

    mov rdi,[rel file_ptr]
    call fclose

    lea rdi,[rel msg_budget_saved]
    xor eax,eax
    call printf
    jmp .done

.invalid:
    lea rdi,[rel msg_invalid_number]
    xor eax,eax
    call printf
    jmp .done

.update_error:
    lea rdi,[rel msg_update_error]
    xor eax,eax
    call printf

.done:
    leave
    ret


; ============================================================
; ADD EXPENSE
; ============================================================

add_expense:
    push rbp
    mov rbp,rsp

    lea rdi,[rel prompt_category]
    xor eax,eax
    call printf

    call read_text

    ; empty category -> use "General"
    lea rsi,[rel input_buffer]
    cmp byte [rsi],0
    jne .copy_category
    lea rsi,[rel default_category]

.copy_category:
    lea rdi,[rel category_buffer]
    call copy_string

    lea rdi,[rel prompt_amount]
    xor eax,eax
    call printf

    call read_integer

    cmp eax,1
    jl .invalid

    mov [rel amount_value],eax

    lea rdi,[rel file_expenses]
    lea rsi,[rel mode_append]
    call fopen

    test rax,rax
    jz .file_error

    mov [rel file_ptr],rax

    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_expense_write]
    lea rdx,[rel current_user]
    lea rcx,[rel category_buffer]
    mov r8d,[rel amount_value]
    xor eax,eax
    call fprintf

    mov rdi,[rel file_ptr]
    call fclose

    lea rdi,[rel msg_expense_saved]
    xor eax,eax
    call printf
    jmp .done

.invalid:
    lea rdi,[rel msg_invalid_number]
    xor eax,eax
    call printf
    jmp .done

.file_error:
    lea rdi,[rel msg_file_error]
    xor eax,eax
    call printf

.done:
    leave
    ret


; ============================================================
; VIEW MY EXPENSES
; ============================================================

view_my_expenses:
    push rbp
    mov rbp,rsp

    mov dword [rel expense_count],0

    lea rdi,[rel file_expenses]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .no_expenses

    mov [rel file_ptr],rax

    ; small blank line before the list
    lea rdi,[rel color_reset]
    xor eax,eax
    call printf

.view_loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_expense]
    lea rdx,[rel file_user]
    lea rcx,[rel file_category]
    lea r8,[rel file_amount]
    xor eax,eax
    call fscanf

    cmp eax,3
    jne .finished

    lea rdi,[rel file_user]
    lea rsi,[rel current_user]
    call strcmp

    cmp eax,0
    jne .view_loop

    inc dword [rel expense_count]

    ; printf(format, number, category, amount)
    lea rdi,[rel fmt_screen_item]
    mov esi,[rel expense_count]
    lea rdx,[rel file_category]
    mov ecx,[rel file_amount]
    xor eax,eax
    call printf

    jmp .view_loop

.finished:
    mov rdi,[rel file_ptr]
    call fclose

    cmp dword [rel expense_count],0
    jne .done

.no_expenses:
    lea rdi,[rel msg_no_expenses]
    xor eax,eax
    call printf

.done:
    leave
    ret


; ============================================================
; COMPUTE TOTAL  (silent: only fills total_value)
; ============================================================

compute_total:
    push rbp
    mov rbp,rsp

    mov dword [rel total_value],0

    lea rdi,[rel file_expenses]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .done

    mov [rel file_ptr],rax

.loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_expense]
    lea rdx,[rel file_user]
    lea rcx,[rel file_category]
    lea r8,[rel file_amount]
    xor eax,eax
    call fscanf

    cmp eax,3
    jne .close

    lea rdi,[rel file_user]
    lea rsi,[rel current_user]
    call strcmp

    cmp eax,0
    jne .loop

    mov eax,[rel total_value]
    add eax,[rel file_amount]
    mov [rel total_value],eax
    jmp .loop

.close:
    mov rdi,[rel file_ptr]
    call fclose

.done:
    leave
    ret


; ============================================================
; CALCULATE TOTAL EXPENSE  (compute + print)
; ============================================================

calculate_total:
    push rbp
    mov rbp,rsp

    mov dword [rel expense_count],0
    mov dword [rel total_value],0

    lea rdi,[rel file_expenses]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .no_expenses

    mov [rel file_ptr],rax

    ; blank line before the list
    lea rdi,[rel color_reset]
    xor eax,eax
    call printf

.loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_expense]
    lea rdx,[rel file_user]
    lea rcx,[rel file_category]
    lea r8,[rel file_amount]
    xor eax,eax
    call fscanf

    cmp eax,3
    jne .finished

    lea rdi,[rel file_user]
    lea rsi,[rel current_user]
    call strcmp

    cmp eax,0
    jne .loop

    inc dword [rel expense_count]

    ; print this one expense line on screen
    lea rdi,[rel fmt_screen_item]
    mov esi,[rel expense_count]
    lea rdx,[rel file_category]
    mov ecx,[rel file_amount]
    xor eax,eax
    call printf

    ; add this expense onto the running total
    mov eax,[rel total_value]
    add eax,[rel file_amount]
    mov [rel total_value],eax

    jmp .loop

.finished:
    mov rdi,[rel file_ptr]
    call fclose

    cmp dword [rel expense_count],0
    jne .show_total

.no_expenses:
    lea rdi,[rel msg_no_expenses]
    xor eax,eax
    call printf
    jmp .done

.show_total:
    ; print the grand total after the list, same as expense_report.txt
    lea rdi,[rel msg_total]
    mov esi,[rel total_value]
    xor eax,eax
    call printf

.done:
    leave
    ret


; ============================================================
; LOAD CURRENT BUDGET
; ============================================================

load_current_budget:
    push rbp
    mov rbp,rsp

    mov dword [rel budget_value],0

    lea rdi,[rel file_budgets]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .done

    mov [rel file_ptr],rax

.loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_budget]
    lea rdx,[rel file_user]
    lea rcx,[rel file_amount]
    xor eax,eax
    call fscanf

    cmp eax,2
    jne .close

    lea rdi,[rel file_user]
    lea rsi,[rel current_user]
    call strcmp

    cmp eax,0
    jne .loop

    mov eax,[rel file_amount]
    mov [rel budget_value],eax
    jmp .loop

.close:
    mov rdi,[rel file_ptr]
    call fclose

.done:
    leave
    ret


; ============================================================
; SHOW REMAINING BUDGET
; ============================================================

show_remaining:
    push rbp
    mov rbp,rsp

    call load_current_budget

    cmp dword [rel budget_value],0
    jle .no_budget

    call compute_total

    mov eax,[rel budget_value]
    sub eax,[rel total_value]
    mov [rel remaining_value],eax

    lea rdi,[rel msg_remaining_label]
    xor eax,eax
    call printf

    mov eax,[rel remaining_value]
    call print_rm_signed
    jmp .done

.no_budget:
    lea rdi,[rel msg_no_budget]
    xor eax,eax
    call printf

.done:
    leave
    ret


; ============================================================
; CHECK BUDGET STATUS
; ============================================================

show_status:
    push rbp
    mov rbp,rsp

    call load_current_budget

    cmp dword [rel budget_value],0
    jle .no_budget

    call compute_total

    ; spent more than budget ?
    mov eax,[rel total_value]
    cmp eax,[rel budget_value]
    jg .exceeded

    ; percentage = total * 100 / budget
    imul eax,100
    cdq
    mov ecx,[rel budget_value]
    idiv ecx

    cmp eax,90
    jge .warning

    lea rdi,[rel msg_budget_safe]
    xor eax,eax
    call printf
    jmp .done

.warning:
    lea rdi,[rel msg_budget_warning]
    xor eax,eax
    call printf
    jmp .done

.exceeded:
    lea rdi,[rel msg_budget_exceeded]
    xor eax,eax
    call printf
    jmp .done

.no_budget:
    lea rdi,[rel msg_no_budget]
    xor eax,eax
    call printf

.done:
    leave
    ret



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
    push rbp
    mov rbp,rsp

    ; Try to open the OLD report. It's fine if it doesn't exist yet
    ; (first time ever exporting) - file_ptr will just be 0/NULL.
    lea rdi,[rel file_report]
    lea rsi,[rel mode_read]
    call fopen
    mov [rel file_ptr],rax

    ; Open a brand new TEMP file to build the tidy version in
    lea rdi,[rel file_report_temp]
    lea rsi,[rel mode_write]
    call fopen

    test rax,rax
    jz .temp_fail

    mov [rel report_ptr],rax
    mov dword [rel wrote_any_block],0   ; nothing written to the temp file yet

    cmp qword [rel file_ptr],0
    je .skip_copy

    mov dword [rel copy_skip],0     ; 0 = keep copying, 1 = skip this block

.read_line:
    lea rdi,[rel line_buffer]
    mov esi,256
    mov rdx,[rel file_ptr]
    call fgets

    test rax,rax
    jz .copy_done                   ; reached the end of the old file

    ; does this line start a NEW person's block ("User: ...")?
    lea rdi,[rel line_buffer]
    lea rsi,[rel report_prefix]
    call starts_with

    cmp eax,1
    jne .body_line

    ; -------- yes, a new block is starting --------
    ; grab the username written on this line
    lea rsi,[rel line_buffer+6]     ; +6 skips past "User: "
    lea rdi,[rel block_user]
    call copy_string

    lea rdi,[rel block_user]
    call remove_newline

    ; is this block the SAME person who is exporting right now?
    lea rdi,[rel block_user]
    lea rsi,[rel current_user]
    call strcmp

    cmp eax,0
    jne .keep_this_block

    mov dword [rel copy_skip],1     ; same person -> skip their old block
    jmp .read_line

.keep_this_block:
    mov dword [rel copy_skip],0     ; a different person -> keep copying

    ; put a blank line before this block, UNLESS it's the very
    ; first block being written (nothing to separate it from yet)
    cmp dword [rel wrote_any_block],0
    je .no_blank_before_copy

    mov rdi,[rel report_ptr]
    lea rsi,[rel blank_line_text]
    xor eax,eax
    call fprintf

.no_blank_before_copy:
    mov dword [rel wrote_any_block],1

    mov rdi,[rel report_ptr]
    lea rsi,[rel fmt_line]
    lea rdx,[rel line_buffer]
    xor eax,eax
    call fprintf
    jmp .read_line

.body_line:
    ; one of the detail lines belonging to whichever block we're in
    cmp dword [rel copy_skip],1
    je .read_line                   ; skipping this block -> throw it away

    mov rdi,[rel report_ptr]
    lea rsi,[rel fmt_line]
    lea rdx,[rel line_buffer]
    xor eax,eax
    call fprintf
    jmp .read_line

.copy_done:
    mov rdi,[rel file_ptr]
    call fclose

.skip_copy:
    ; -------- now add ONE fresh block for the current user --------

    ; put a blank line first, UNLESS this is the very first block
    ; being written into the whole file
    cmp dword [rel wrote_any_block],0
    je .no_blank_before_new

    mov rdi,[rel report_ptr]
    lea rsi,[rel blank_line_text]
    xor eax,eax
    call fprintf

.no_blank_before_new:
    mov dword [rel wrote_any_block],1

    ; User / Monthly Budget / Total Expense lines
    mov rdi,[rel report_ptr]
    lea rsi,[rel fmt_report_header_top]
    lea rdx,[rel current_user]
    mov ecx,[rel budget_value]
    mov r8d,[rel total_value]
    xor eax,eax
    call fprintf

    ; Remaining line - pick the format that keeps the minus sign
    ; right in front of "RM", e.g. "-RM500" instead of "RM-500"
    mov eax,[rel budget_value]
    sub eax,[rel total_value]
    mov [rel remaining_value],eax

    cmp eax,0
    jl .file_remaining_negative

    mov rdi,[rel report_ptr]
    lea rsi,[rel fmt_report_remaining_positive]
    mov edx,eax
    xor eax,eax
    call fprintf
    jmp .file_remaining_done

.file_remaining_negative:
    neg eax
    mov rdi,[rel report_ptr]
    lea rsi,[rel fmt_report_remaining_negative]
    mov edx,eax
    xor eax,eax
    call fprintf

.file_remaining_done:
    mov rdi,[rel report_ptr]
    lea rsi,[rel fmt_report_separator]
    xor eax,eax
    call fprintf

    mov dword [rel report_count],0

    lea rdi,[rel file_expenses]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .close_temp

    mov [rel file_ptr],rax

.expense_loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_expense]
    lea rdx,[rel file_user]
    lea rcx,[rel file_category]
    lea r8,[rel file_amount]
    xor eax,eax
    call fscanf

    cmp eax,3
    jne .close_expenses

    lea rdi,[rel file_user]
    lea rsi,[rel current_user]
    call strcmp

    cmp eax,0
    jne .expense_loop

    inc dword [rel report_count]

    mov rdi,[rel report_ptr]
    lea rsi,[rel fmt_expense_item]
    mov edx,[rel report_count]
    lea rcx,[rel file_category]
    mov r8d,[rel file_amount]
    xor eax,eax
    call fprintf
    jmp .expense_loop

.close_expenses:
    mov rdi,[rel file_ptr]
    call fclose

.close_temp:
    mov rdi,[rel report_ptr]
    call fclose

    ; swap the tidy temp file in to become the real report file
    lea rdi,[rel file_report_temp]
    lea rsi,[rel file_report]
    call rename

    mov eax,1
    leave
    ret

.temp_fail:
    cmp qword [rel file_ptr],0
    je .temp_fail_done

    mov rdi,[rel file_ptr]
    call fclose

.temp_fail_done:
    xor eax,eax
    leave
    ret


; ============================================================
; EXPORT EXPENSE REPORT
; 1) update expense_report.txt (one tidy block per user)
; 2) write a copy into Windows Downloads
; ============================================================

export_report:
    push rbp
    mov rbp,rsp

    call load_current_budget
    call compute_total

    ; keep expense_report.txt tidy: exactly one block per user
    call update_local_report

    test eax,eax
    jz .file_error

    ; -------- show the report right here on screen --------
    lea rdi,[rel title_my_report]
    xor eax,eax
    call printf

    lea rdi,[rel fmt_my_report_user]
    lea rsi,[rel current_user]
    xor eax,eax
    call printf

    lea rdi,[rel fmt_my_report_budget]
    mov esi,[rel budget_value]
    xor eax,eax
    call printf

    lea rdi,[rel fmt_my_report_total]
    mov esi,[rel total_value]
    xor eax,eax
    call printf

    mov eax,[rel budget_value]
    sub eax,[rel total_value]
    mov [rel remaining_value],eax

    lea rdi,[rel fmt_my_report_remaining_label]
    xor eax,eax
    call printf

    mov eax,[rel remaining_value]
    call print_rm_signed

    lea rdi,[rel line_separator]
    xor eax,eax
    call printf

    ; -------- list this user's expenses underneath --------
    mov dword [rel expense_count],0

    lea rdi,[rel file_expenses]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .no_expenses

    mov [rel file_ptr],rax

.list_loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_expense]
    lea rdx,[rel file_user]
    lea rcx,[rel file_category]
    lea r8,[rel file_amount]
    xor eax,eax
    call fscanf

    cmp eax,3
    jne .list_done

    lea rdi,[rel file_user]
    lea rsi,[rel current_user]
    call strcmp

    cmp eax,0
    jne .list_loop

    inc dword [rel expense_count]

    lea rdi,[rel fmt_screen_item]
    mov esi,[rel expense_count]
    lea rdx,[rel file_category]
    mov ecx,[rel file_amount]
    xor eax,eax
    call printf

    jmp .list_loop

.list_done:
    mov rdi,[rel file_ptr]
    call fclose

    cmp dword [rel expense_count],0
    jne .done

.no_expenses:
    lea rdi,[rel msg_no_expenses]
    xor eax,eax
    call printf
    jmp .done

.file_error:
    lea rdi,[rel msg_file_error]
    xor eax,eax
    call printf

.done:
    leave
    ret


; ============================================================
; ADMIN: DISPLAY TXT FILE
; RDI = title, RSI = file name
;
; BUG FIXED HERE: fgets wants (buffer, size, FILE*).
; The old code gave (FILE*, buffer, size) -> Segmentation fault.
; ============================================================

display_txt_file:
    push rbp
    mov rbp,rsp

    mov [rel display_title],rdi
    mov [rel display_filename],rsi

    mov rdi,[rel display_title]
    xor eax,eax
    call printf

    mov rdi,[rel display_filename]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .file_error

    mov [rel file_ptr],rax
    mov dword [rel display_lines],0

    ; switch to bright white text
    lea rdi,[rel color_white]
    xor eax,eax
    call printf

.read_loop:
    lea rdi,[rel line_buffer]       ; 1st: where to store the text
    mov esi,256                     ; 2nd: how many characters max
    mov rdx,[rel file_ptr]          ; 3rd: which file
    call fgets

    test rax,rax
    jz .finished

    inc dword [rel display_lines]

    ; print with "%s" (safe way: file text is never used as a format)
    lea rdi,[rel fmt_line]
    lea rsi,[rel line_buffer]
    xor eax,eax
    call printf
    jmp .read_loop

.finished:
    mov rdi,[rel file_ptr]
    call fclose

    lea rdi,[rel color_reset]
    xor eax,eax
    call printf

    cmp dword [rel display_lines],0
    jne .done

    lea rdi,[rel msg_no_data]
    xor eax,eax
    call printf
    jmp .done

.file_error:
    lea rdi,[rel msg_file_error]
    xor eax,eax
    call printf

.done:
    leave
    ret


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
    push rbp
    mov rbp,rsp

    lea rdi,[rel title_report]
    xor eax,eax
    call printf

    lea rdi,[rel file_report]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .file_error

    mov [rel file_ptr],rax
    mov dword [rel display_lines],0

    lea rdi,[rel color_white]
    xor eax,eax
    call printf

.read_loop:
    lea rdi,[rel line_buffer]
    mov esi,256
    mov rdx,[rel file_ptr]
    call fgets

    test rax,rax
    jz .finished

    inc dword [rel display_lines]

    ; does this line start with "User: " ?
    lea rdi,[rel line_buffer]
    lea rsi,[rel report_prefix]
    call starts_with

    cmp eax,1
    jne .plain_line

    ; yes - print it highlighted
    lea rdi,[rel fmt_report_user_highlight]
    lea rsi,[rel line_buffer]
    xor eax,eax
    call printf
    jmp .read_loop

.plain_line:
    ; an ordinary line (budget, total, expense item, blank line...)
    lea rdi,[rel fmt_line]
    lea rsi,[rel line_buffer]
    xor eax,eax
    call printf
    jmp .read_loop

.finished:
    mov rdi,[rel file_ptr]
    call fclose

    lea rdi,[rel color_reset]
    xor eax,eax
    call printf

    cmp dword [rel display_lines],0
    jne .done

    lea rdi,[rel msg_no_data]
    xor eax,eax
    call printf
    jmp .done

.file_error:
    lea rdi,[rel msg_file_error]
    xor eax,eax
    call printf

.done:
    leave
    ret


; ============================================================
; SYSTEM STATISTICS
; ============================================================

system_statistics:
    push rbp
    mov rbp,rsp

    mov dword [rel account_count],0
    mov dword [rel budget_count],0
    mov dword [rel all_expense_count],0

    ; ---- count accounts ----
    lea rdi,[rel file_accounts]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .count_budgets

    mov [rel file_ptr],rax

.account_loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_account]
    lea rdx,[rel file_user]
    lea rcx,[rel file_password]
    lea r8,[rel file_role]
    xor eax,eax
    call fscanf

    cmp eax,3
    jne .close_accounts

    inc dword [rel account_count]
    jmp .account_loop

.close_accounts:
    mov rdi,[rel file_ptr]
    call fclose

    ; ---- count budgets ----
.count_budgets:
    lea rdi,[rel file_budgets]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .count_expenses

    mov [rel file_ptr],rax

.budget_loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_budget]
    lea rdx,[rel file_user]
    lea rcx,[rel file_amount]
    xor eax,eax
    call fscanf

    cmp eax,2
    jne .close_budgets

    inc dword [rel budget_count]
    jmp .budget_loop

.close_budgets:
    mov rdi,[rel file_ptr]
    call fclose

    ; ---- count expenses ----
.count_expenses:
    lea rdi,[rel file_expenses]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .display

    mov [rel file_ptr],rax

.expense_loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_expense]
    lea rdx,[rel file_user]
    lea rcx,[rel file_category]
    lea r8,[rel file_amount]
    xor eax,eax
    call fscanf

    cmp eax,3
    jne .close_expenses

    inc dword [rel all_expense_count]
    jmp .expense_loop

.close_expenses:
    mov rdi,[rel file_ptr]
    call fclose

.display:
    lea rdi,[rel title_stats]
    xor eax,eax
    call printf

    lea rdi,[rel fmt_stat]
    lea rsi,[rel stat_accounts]
    mov edx,[rel account_count]
    xor eax,eax
    call printf

    lea rdi,[rel fmt_stat]
    lea rsi,[rel stat_budgets]
    mov edx,[rel budget_count]
    xor eax,eax
    call printf

    lea rdi,[rel fmt_stat]
    lea rsi,[rel stat_expenses]
    mov edx,[rel all_expense_count]
    xor eax,eax
    call printf

    leave
    ret


; ============================================================
; READ CHOICE  (menu number)
; ============================================================

read_choice:
    push rbp
    mov rbp,rsp

    lea rdi,[rel prompt_choice]
    xor eax,eax
    call printf

    lea rdi,[rel input_buffer]
    mov esi,128
    mov rdx,[rel stdin]
    call fgets

    test rax,rax
    jz .end_of_input

    lea rdi,[rel input_buffer]
    call atoi

    leave
    ret

.end_of_input:
    ; Ctrl+D pressed -> leave the program politely
    xor edi,edi
    call exit


; ============================================================
; READ INTEGER
; ============================================================

read_integer:
    push rbp
    mov rbp,rsp

    lea rdi,[rel input_buffer]
    mov esi,128
    mov rdx,[rel stdin]
    call fgets

    test rax,rax
    jz .zero

    lea rdi,[rel input_buffer]
    call atoi

    leave
    ret

.zero:
    xor eax,eax
    leave
    ret


; ============================================================
; READ TEXT  (username / category)
; Spaces become "_" so the txt file format never breaks.
; ============================================================

read_text:
    push rbp
    mov rbp,rsp

    lea rdi,[rel input_buffer]
    mov esi,128
    mov rdx,[rel stdin]
    call fgets

    test rax,rax
    jz .empty

    lea rdi,[rel input_buffer]
    call remove_newline

    lea rdi,[rel input_buffer]
    call replace_spaces
    jmp .done

.empty:
    mov byte [rel input_buffer],0

.done:
    leave
    ret


; ============================================================
; READ PASSWORD
; ============================================================

read_password:
    push rbp
    mov rbp,rsp

    lea rdi,[rel password_buffer]
    mov esi,128
    mov rdx,[rel stdin]
    call fgets

    test rax,rax
    jz .empty

    lea rdi,[rel password_buffer]
    call remove_newline
    jmp .done

.empty:
    mov byte [rel password_buffer],0

.done:
    leave
    ret


; ============================================================
; REMOVE NEWLINE  (RDI = text)
; ============================================================

remove_newline:
    push rbp
    mov rbp,rsp

    mov rsi,rdi

.loop:
    mov al,[rsi]

    cmp al,0
    je .done
    cmp al,10
    je .replace
    cmp al,13
    je .replace

    inc rsi
    jmp .loop

.replace:
    mov byte [rsi],0

.done:
    leave
    ret


; ============================================================
; REPLACE SPACES WITH "_"  (RDI = text)
; ============================================================

replace_spaces:
    push rbp
    mov rbp,rsp

.loop:
    mov al,[rdi]

    cmp al,0
    je .done

    cmp al,' '
    jne .next
    mov byte [rdi],'_'

.next:
    inc rdi
    jmp .loop

.done:
    leave
    ret


; ============================================================
; COPY STRING  (RDI = destination, RSI = source)
; Copies at most 63 letters, so it can never overflow a
; 64-byte box.
; ============================================================

copy_string:
    push rbp
    mov rbp,rsp

    mov rdx,rsi
    mov ecx,63

.copy_loop:
    mov al,[rdx]
    mov [rdi],al

    cmp al,0
    je .done

    inc rdx
    inc rdi

    dec ecx
    jnz .copy_loop

    mov byte [rdi],0

.done:
    leave
    ret


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
    push rbp
    mov rbp,rsp

.loop:
    movzx eax,byte [rdi]     ; one letter from the first word
    movzx edx,byte [rsi]     ; the matching letter from the second word

    ; If the letter from word 1 is A-Z, turn it into a-z
    cmp al,'A'
    jb .skip_lower_al
    cmp al,'Z'
    ja .skip_lower_al
    add al,32
.skip_lower_al:

    ; Do the same for the letter from word 2
    cmp dl,'A'
    jb .skip_lower_dl
    cmp dl,'Z'
    ja .skip_lower_dl
    add dl,32
.skip_lower_dl:

    cmp al,dl
    jne .different

    ; both letters are 0 (end of both words) -> they matched all the way
    test al,al
    jz .same

    inc rdi
    inc rsi
    jmp .loop

.same:
    xor eax,eax
    leave
    ret

.different:
    mov eax,1
    leave
    ret


; ============================================================
; STARTS_WITH  ("does this line begin with these words?")
;
; RDI = a full line of text, RSI = the words to look for at
; the very beginning (like "User: ").
; Returns EAX = 1 if it matches, 0 if it does not.
; ============================================================

starts_with:
    push rbp
    mov rbp,rsp

.loop:
    movzx eax,byte [rsi]     ; next letter we're looking for
    test al,al
    jz .yes                  ; we checked every letter we needed - match!

    movzx edx,byte [rdi]     ; the matching letter in the line
    cmp al,dl
    jne .no

    inc rdi
    inc rsi
    jmp .loop

.yes:
    mov eax,1
    leave
    ret

.no:
    xor eax,eax
    leave
    ret


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
    push rbp
    mov rbp,rsp

    cmp eax,0
    jl .negative

    ; zero or positive -> green "RM<number>"
    mov esi,eax
    lea rdi,[rel fmt_rm_positive]
    xor eax,eax
    call printf
    jmp .done

.negative:
    neg eax                      ; flip -500 into 500 so we can print it
    mov esi,eax
    lea rdi,[rel fmt_rm_negative]
    xor eax,eax
    call printf

.done:
    leave
    ret


; ============================================================
; ENCRYPT PASSWORD USING XOR + HEX
; RDI = plain password, RSI = output
; Example: 'a' (0x61) XOR 0x5A = 0x3B  ->  "3B"
; ============================================================

encrypt_password_hex:
    push rbp
    mov rbp,rsp

    lea rcx,[rel hex_chars]

.loop:
    movzx eax,byte [rdi]
    test al,al
    jz .finish

    xor al,xor_key

    movzx edx,al
    shr edx,4                   ; high half
    mov r8b,[rcx+rdx]
    mov [rsi],r8b

    and eax,0x0F                ; low half
    mov r8b,[rcx+rax]
    mov [rsi+1],r8b

    add rsi,2
    inc rdi
    jmp .loop

.finish:
    mov byte [rsi],0

    leave
    ret


; ============================================================
; DECRYPT PASSWORD USING HEX + XOR
; This is the exact OPPOSITE of encrypt_password_hex above -
; it turns the stored HEX text back into the real password.
;
; RDI = HEX text (like "3B3E3733346B6869")
; RSI = output buffer for the real password (like "admin123")
; ============================================================

decrypt_password_hex:
    push rbp
    mov rbp,rsp

.loop:
    movzx eax,byte [rdi]
    test al,al
    jz .finish

    ; turn the FIRST hex letter into a number 0-15
    cmp al,'9'
    jbe .hi_digit
    sub al,55                   ; 'A' is 65, and 65-55=10
    jmp .hi_done
.hi_digit:
    sub al,'0'
.hi_done:
    shl al,4                    ; this number goes in the top half
    mov dl,al

    ; turn the SECOND hex letter into a number 0-15
    movzx eax,byte [rdi+1]
    cmp al,'9'
    jbe .lo_digit
    sub al,55
    jmp .lo_done
.lo_digit:
    sub al,'0'
.lo_done:
    or al,dl                    ; combine both halves into one byte
    xor al,xor_key               ; undo the XOR scrambling
    mov [rsi],al

    inc rsi
    add rdi,2                   ; move 2 letters forward (one hex pair)
    jmp .loop

.finish:
    mov byte [rsi],0

    leave
    ret


; ============================================================
; VIEW ACCOUNTS  (admin menu option 1)
;
; Asks the admin whether they want to see accounts.txt exactly
; as it's stored (scrambled passwords), or decoded into plain,
; readable passwords.
; ============================================================

view_accounts:
    push rbp
    mov rbp,rsp

    lea rdi,[rel prompt_view_mode]
    xor eax,eax
    call printf

    call read_choice

    cmp eax,2
    je .plain_mode

    ; choice 1 (or anything else) -> show the file exactly as stored
    lea rdi,[rel title_accounts]
    lea rsi,[rel file_accounts]
    call display_txt_file
    jmp .done

.plain_mode:
    lea rdi,[rel title_accounts_plain]
    xor eax,eax
    call printf

    lea rdi,[rel file_accounts]
    lea rsi,[rel mode_read]
    call fopen

    test rax,rax
    jz .file_error

    mov [rel file_ptr],rax

.read_loop:
    mov rdi,[rel file_ptr]
    lea rsi,[rel fmt_account]
    lea rdx,[rel file_user]
    lea rcx,[rel file_password]
    lea r8,[rel file_role]
    xor eax,eax
    call fscanf

    cmp eax,3
    jne .close

    ; turn the scrambled password back into the real one
    lea rdi,[rel file_password]
    lea rsi,[rel decoded_password]
    call decrypt_password_hex

    lea rdi,[rel fmt_account_plain]
    lea rsi,[rel file_user]
    lea rdx,[rel decoded_password]
    lea rcx,[rel file_role]
    xor eax,eax
    call printf

    jmp .read_loop

.close:
    mov rdi,[rel file_ptr]
    call fclose
    jmp .done

.file_error:
    lea rdi,[rel msg_file_error]
    xor eax,eax
    call printf

.done:
    leave
    ret


section .note.GNU-stack noexec
