.data
a: .asciiz "Insert a: "
b: .asciiz "Insert b: "
c: .asciiz "Insert c: "
d: .asciiz "Insert d: "
output_F: .asciiz "F= "
output_remainder: .asciiz ", remainder: "

.text

    #  a
    li $v0, 4
    la $a0, a
    syscall
    li $v0, 5
    syscall
    move $t0, $v0  

    #  b
    li $v0, 4
    la $a0, b
    syscall
    li $v0, 5
    syscall
    move $t1, $v0  

    # c
    li $v0, 4
    la $a0, c
    syscall
    li $v0, 5
    syscall
    move $t2, $v0  

    # d
    li $v0, 4
    la $a0, d
    syscall
    li $v0, 5
    syscall
    move $t3, $v0  # d

    # Tinh F
    addi $t4, $t0, 10    # t4 = a + 10
    sub $t5, $t1, $t3    # t5 = b - d
    mul $t4, $t4, $t5    # t4 = (a + 10) * (b - d)

    mul $t6, $t0, 2      # t6 = 2 * a
    sub $t7, $t2, $t6    # t7 = c - (2 * a)

    mul $t4, $t4, $t7    # t4 = (a+10) * (b-d) * (c-2a)

    add $t8, $t0, $t1    # t8 = a + b
    add $t8, $t8, $t2    # t8 = a + b + c

    # IF
    beq $t8, $zero, exit  # mau = 0 --> exit

    div $t4, $t8         # t4 / t8
    mflo $t6             # Ans
    mfhi $t7             # Du

    # Print F
    li $v0, 4
    la $a0, output_F
    syscall

    li $v0, 1
    move $a0, $t6
    syscall

    li $v0, 4
    la $a0, output_remainder
    syscall

    li $v0, 1
    move $a0, $t7
    syscall

exit:
    li $v0, 10
    syscall
