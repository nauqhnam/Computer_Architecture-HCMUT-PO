.data
promptU: .asciiz "Please insert u: "
promptV: .asciiz "Please insert v: "
promptA: .asciiz "Please insert a: " 
promptB: .asciiz "Please insert b: "
promptC: .asciiz "Please insert c: "
promptD: .asciiz "Please insert d: "
promptE: .asciiz "Please insert e: "
constant_seven: .float 7.0
constant_six: .float 6.0
constant_two: .float 2.0

.text

    li $v0, 4
    la $a0, promptU
    syscall
    li $v0, 6
    syscall
    mov.s $f1, $f0  
    
    li $v0, 4
    la $a0, promptV
    syscall
    li $v0, 6
    syscall
    mov.s $f2, $f0  
    
    li $v0, 4
    la $a0, promptA
    syscall
    li $v0, 6
    syscall
    mov.s $f3, $f0  
    
    li $v0, 4
    la $a0, promptB
    syscall
    li $v0, 6
    syscall
    mov.s $f4, $f0  
    
    li $v0, 4
    la $a0, promptC
    syscall
    li $v0, 6
    syscall
    mov.s $f5, $f0  
    
    li $v0, 4
    la $a0, promptD
    syscall
    li $v0, 6
    syscall
    mov.s $f6, $f0  
    
    li $v0, 4
    la $a0, promptE
    syscall
    li $v0, 6
    syscall
    mov.s $f7, $f0  

    # d^4 + e^3
    # d^4
    mul.s $f8, $f6, $f6      
    mul.s $f8, $f8, $f8      

    # e^3
    mul.s $f9, $f7, $f7      
    mul.s $f9, $f9, $f7      

    # d^4 + e^3
    add.s $f10, $f8, $f9    

    #F(u) 
    # u^2
    mul.s $f11, $f1, $f1

    # u^6
    mul.s $f12, $f11, $f11   
    mul.s $f12, $f12, $f11   

    # u^7 = u^6 * u
    mul.s $f13, $f12, $f1

    # a*u^7 / 7
    l.s $f20, constant_seven
    mul.s $f14, $f3, $f13
    div.s $f14, $f14, $f20

    # b*u^6 / 6
    l.s $f21, constant_six
    mul.s $f15, $f4, $f12
    div.s $f15, $f15, $f21

    # c*u^2 / 2
    l.s $f22, constant_two
    mul.s $f16, $f5, $f11
    div.s $f16, $f16, $f22

    # F(u)
    add.s $f17, $f14, $f15
    add.s $f17, $f17, $f16

    # F(v)
    # v^2
    mul.s $f11, $f2, $f2

    # v^6
    mul.s $f12, $f11, $f11
    mul.s $f12, $f12, $f11

    # v^7 = v^6 * v
    mul.s $f13, $f12, $f2

    # a*v^7 / 7
    mul.s $f14, $f3, $f13
    div.s $f14, $f14, $f20

    # b*v^6 / 6
    mul.s $f15, $f4, $f12
    div.s $f15, $f15, $f21

    # c*v^2 / 2
    mul.s $f16, $f5, $f11
    div.s $f16, $f16, $f22

    # F(v)
    add.s $f18, $f14, $f15
    add.s $f18, $f18, $f16

   #(F(u) - F(v)) / (d^4 + e^3)
    sub.s $f19, $f17, $f18
    div.s $f12, $f19, $f10

    # Printf
    li $v0, 2
    mov.s $f12, $f12
    syscall

    # Exit
    li $v0, 10
    syscall