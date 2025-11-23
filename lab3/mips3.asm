.data
raw:               .asciiz "D:\\BACHKHOA\\KTMT\\lab3\\raw_input.txt"
output:            .asciiz "D:\\BACHKHOA\\KTMT\\lab3\\formated_result.txt"

header:            .asciiz "---Student personal information---\n"
nameLabel:         .asciiz "Name: "
idLabel:           .asciiz "ID: "
addressLabel:      .asciiz "Address: "
ageLabel:          .asciiz "Age: "
religionLabel:     .asciiz "Religion: "
newline:           .asciiz "\n"

content:           .space 500

.text
main:
    # Open raw_input.txt for reading
    li $v0, 13
    la $a0, raw
    li $a1, 0              # read
    li $a2, 0
    syscall
    move $s6, $v0          #luu tep dau vao

    # Open for writing
    li $v0, 13
    la $a0, output
    li $a1, 1              # write 
    li $a2, 0
    syscall
    move $s1, $v0          #luu dau ra

    # cap phat bo nho cho viec doc
    li $v0, 9
    li $a0, 256
    syscall
    move $s0, $v0          # luu con tro bo nho cho du lieu dau vao

    # Read
    li $v0, 14
    move $a0, $s6
    move $a1, $s0
    li $a2, 256
    syscall

    # Printf
    li $v0, 4
    la $a0, header
    syscall

    li $v0, 15
    move $a0, $s1
    la $a1, header
    li $a2, 35           #header length
    syscall

    # Process the five fields: 0=Name, 1=ID, 2=Address, 3=Age, 4=Religion
    li $t2, 0  # field index

process_field:
    li $t3, 5
    beq $t2, $t3, close_files

    # Select the proper label based on the field index
    li $t3, 0
    beq $t2, $t3, do_name
    li $t3, 1
    beq $t2, $t3, do_id
    li $t3, 2
    beq $t2, $t3, do_address
    li $t3, 3
    beq $t2, $t3, do_age
    li $t3, 4
    beq $t2, $t3, do_religion

do_name:
    li $v0, 4
    la $a0, nameLabel
    syscall
    li $v0, 15 #ghi vao tep
    move $a0, $s1
    la $a1, nameLabel
    li $a2, 6         # "Name: " 6 characters
    syscall
    j parse_field

do_id:
    li $v0, 4
    la $a0, idLabel
    syscall
    li $v0, 15
    move $a0, $s1
    la $a1, idLabel
    li $a2, 4         # "ID: " is 4 characters
    syscall
    j parse_field

do_address:
    li $v0, 4
    la $a0, addressLabel
    syscall
    li $v0, 15
    move $a0, $s1
    la $a1, addressLabel
    li $a2, 9         # "Address: " is 9 characters
    syscall
    j parse_field

do_age:
    li $v0, 4
    la $a0, ageLabel
    syscall
    li $v0, 15
    move $a0, $s1
    la $a1, ageLabel
    li $a2, 5         # "Age: " is 5 characters
    syscall
    j parse_field

do_religion:
    li $v0, 4
    la $a0, religionLabel
    syscall
    li $v0, 15
    move $a0, $s1
    la $a1, religionLabel
    li $a2, 10        # "Religion: " must be 10 characters (including the trailing space)
    syscall
    j parse_field

# Parse one field's content: print character by character (to console) and store in "content"
parse_field:
    li $t9, 0         # Reset chi so
parse_loop:
    lb $t0, 0($s0)
    #gap dau phay thi xuong dong hoac ket thuc chuoi
    beq $t0, ',', field_done
    beqz $t0, field_done
    li $t5, 10        # ASCII newline = 10
    beq $t0, $t5, field_done
	#in ra man hinh
    move $a0, $t0
    li $v0, 11
    syscall

    # luu ki tu vao bo dem
    sb $t0, content($t9)
    addi $t9, $t9, 1
    addi $s0, $s0, 1
    j parse_loop

field_done:
    #ket thuc truong in ki tu null
    sb $zero, content($t9)

    # ghi truong vao tep write
    li $v0, 15
    move $a0, $s1
    la $a1, content
    move $a2, $t9
    syscall

    # in dau xuong dong sau moi tep
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 15
    move $a0, $s1
    la $a1, newline
    li $a2, 1
    syscall

    #bo qua dau cach xuong dong ne co
    lb $t0, 0($s0)
    li $t5, 10
    beq $t0, $t5, skip_sep
    beq $t0, ',', skip_sep
    j next_field
skip_sep:
    addi $s0, $s0, 1

next_field:
    addi $t2, $t2, 1  
    j process_field

close_files:
    # Close input file
    li $v0, 16
    move $a0, $s6
    syscall

    # Close output file
    li $v0, 16
    move $a0, $s1
    syscall
	#exit
    li $v0, 10       
    syscall

