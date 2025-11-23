.data
promptA: .asciiz "Enter a: "
promptB: .asciiz "Enter b: "
promptC: .asciiz "Enter c: "
No_solution_prompt: .asciiz "There is no real solution"
One_solution_prompt: .asciiz "There is one solution, x= "
Solution_x1: .asciiz "x1 = "
Solution_x2: .asciiz "x2 = "
infinite_solution_prompt: .asciiz "There are infinite solutions!"
const_four: .float 4.0
const_two: .float 2.0
const_zero: .float 0.0
newline: .asciiz "\n"
.text
	
	li $v0, 4
	la $a0, promptA
	syscall

	li $v0, 6
	syscall
	mov.s $f1, $f0
	
	li $v0, 4
	la $a0, promptB
	syscall
	
	li $v0, 6
	syscall
	mov.s $f2, $f0
	
	li $v0, 4
	la $a0, promptC
	syscall
	
	li $v0, 6
	syscall
	mov.s $f3, $f0
	
	l.s $f6, const_zero
	c.eq.s $f1, $f6
	bc1t a_equal_zero
	bc1f not_eq_0
not_eq_0:
	mul.s $f9, $f2, $f2
	mul.s $f10, $f1, $f3
	l.s $f6, const_four      #b^2-4ac
	mul.s $f10, $f10, $f6
	sub.s $f11, $f9, $f10
	
	l.s $f6, const_zero
	c.lt.s $f11, $f6
	bc1t vo_nghiem
	
	c.eq.s $f11, $f6
	bc1t one_solution
	bc1f two_solution
vo_nghiem:
	li $v0, 4
	la $a0, No_solution_prompt
	syscall
	j exit
one_solution:
	l.s $f6, const_two  #2a
	mul.s $f1, $f1, $f6
	div.s $f2, $f2, $f1
	neg.s $f12, $f2      #-b/2a
	
	 li $v0, 4
	 la $a0, One_solution_prompt
	 syscall
	 
	  li $v0, 2
	  syscall
	  j exit
two_solution:
	sqrt.s $f11, $f11
	neg.s $f2, $f2
	l.s $f6, const_two
	mul.s $f1, $f1, $f6
	
	add.s $f4, $f2, $f11   #x1=(-b+sqrt(delta))/2a
	div.s $f4, $f4, $f1
	
	sub.s $f5, $f2, $f11       #X2=(-b-sqrt(delta))/2a
	div.s $f5, $f5, $f1
	
	li $v0, 4
	la $a0, Solution_x1
	syscall
	
	li $v0, 2
	mov.s $f12, $f4
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 4
	la $a0, Solution_x2
	syscall
	
	
	li $v0, 2
	mov.s $f12, $f5
	syscall
	j exit
a_equal_zero:
	l.s $f6, const_zero
	c.eq.s $f2, $f6      #compare b to 0
	bc1t b_equal_zero
	bc1f b_not_equal_0
b_not_equal_0:
	 neg.s $f3, $f3         
    	 div.s $f2, $f3, $f2    #-c / b
	#printf
  	 li $v0, 4
  	 la $a0, One_solution_prompt
    	 syscall

    	 li $v0, 2
   	 mov.s $f12, $f2        # In nghiệm x
   	 syscall
   	 j exit
	
b_equal_zero:
	l.s $f6, const_zero
	c.eq.s $f3, $f6		#compare c
	bc1t infinite_solution
	bc1f vo_nghiem
infinite_solution:
	li $v0, 4
	la $a0, infinite_solution_prompt
	syscall
	j exit
	
exit:	
	li $v0, 10
	syscall
	



