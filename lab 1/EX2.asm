.data

array: .space 20
num0: .asciiz "Please input number 0: "
num1: .asciiz "Please input number 1: "
num2: .asciiz "Please input number 2: "
num3: .asciiz "Please input number 3: "
num4: .asciiz "Please input number 4: "
index: .asciiz "Input index: "
.text
# Print prompt 0
    li $v0, 4
    la $a0, num0
    syscall
    
    # Read input 0
    li $v0, 5
    syscall
    sw $v0, array
    
    # Print prompt 1
    li $v0, 4
    la $a0, num1
    syscall
    
    # Read input 1
    li $v0, 5
    syscall
    sw $v0, array+4
    
    # Print prompt 2
    li $v0, 4
    la $a0, num2
    syscall
    
    # Read input 2
    li $v0, 5
    syscall
    sw $v0, array+8
    
    # Print prompt 3
    li $v0, 4
    la $a0, num3
    syscall
    
    # Read input 3
    li $v0, 5
    syscall
    sw $v0, array+12
    
    # Print prompt 4
    li $v0, 4
    la $a0, num4
    syscall
    
    # Read input 4
    li $v0, 5
    syscall
    sw $v0, array+16
    
    # Input Index
    li $v0, 4
    la $a0, index
    syscall
    
    # Read index
    li $v0, 5
    syscall
    move $t3, $v0
    
    # Load value at index
    la $t1, array
    mul $t2, $t3, 4
    add $t1, $t1, $t2
    lw $t4, 0($t1)
    
    # Print result
    li $v0, 1
    move $a0, $t4
    syscall
    
    # Exit
    li $v0, 10
    syscall
