.data
prompt: .asciiz "Please enter a positive integer less than 16: "
output: .asciiz " It's binary form is: "
newline: .asciiz "\n" 

.text
.globl main
main:
	# Printf
	li $v0, 4
	la $a0, prompt
	syscall
	
	# input
	li $v0, 5
	syscall
	move $t0, $v0 
	
	# IF
	li $t2, 16
	bge $t0, $t2, exit  # >16 --> exit
	
	#printf
	li $v0, 4
	la $a0, output
	syscall
	
	# In 
	srl $t1, $t0, 3     # MSB 
	andi $t1, $t1, 1    
	addi $a0, $t1, 48   # ASCII 
	li $v0, 11
	syscall
	
	srl $t1, $t0, 2     
	andi $t1, $t1, 1
	addi $a0, $t1, 48
	li $v0, 11
	syscall
	
	srl $t1, $t0, 1 
	andi $t1, $t1, 1
	addi $a0, $t1, 48
	li $v0, 11
	syscall
	
	andi $t1, $t0, 1    # LSB 
	addi $a0, $t1, 48
	li $v0, 11
	syscall

	# \n
	li $v0, 4
	la $a0, newline
	syscall

exit:
	# Exit
	li $v0, 10
	syscall
