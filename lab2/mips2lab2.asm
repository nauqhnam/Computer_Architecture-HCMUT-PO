.data
promptA: .asciiz "Enter a positive number for a: "
promptB: .asciiz "Enter a positive number for b: "
fail_out: .asciiz "Please enter a positive number!"
GCD_out: .asciiz "GCD= "
LCM_out: .asciiz "LCM= "
newline: .asciiz "\n"

.text
#hien thi va nhap
main:
	li $v0, 4
	la $a0, promptA
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0
	
	blez $t0, fail #<=0?
	
	li $v0, 4
	la $a0, promptB
	syscall
	
	li $v0, 5
	syscall
	move $t1, $v0
	
	blez $t1, fail
	
	move $a0, $t0
	move $a1, $t1
	jal gcd
	move $t2, $v0  
	
	mul $t3, $t0, $t1
	div $t3, $t2        
	mflo $t4            
    	
	li $v0, 4
    	la $a0, GCD_out
    	syscall 
    	
	li $v0, 1
 	move $a0, $t2
	syscall   
	
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 4
	la $a0, LCM_out
	syscall
    
	li $v0, 1
	move $a0, $t4
	syscall     
	
exit:
	li $v0, 10
	syscall
	
fail:
	li $v0, 4
	la $a0, fail_out
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	j main

#euclid
gcd: 		
    	beq $a1, $zero, gcd_base  
    
    	move $t5, $a1
    	div $a0, $a1
    	mfhi $a1  
	move $a0, $t5  
    	j gcd

gcd_base:
    	move $v0, $a0  
    	jr $ra  
