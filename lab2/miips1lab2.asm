.data
buffer: .space 100        
prompt: .asciiz "Enter a string: "
space: .asciiz "; "
counts: .space 26          

.text
   #printf
    li $v0, 4
    la $a0, prompt
    syscall
    
   
    li $v0, 8
    la $a0, buffer
    li $a1, 100
    syscall

#Creat counts
    la $t0, counts
    li $t1, 26  
    li $t2, 0
init_loop:
    beqz $t1, read_done
    sb $t2, 0($t0)  
    addi $t0, $t0, 1
    subi $t1, $t1, 1
    j init_loop

#count
read_done:
    la $t3, buffer         
count_loop:
    lb $t4, 0($t3)  
    #conditions       
    beqz $t4, print_counts 
    blt $t4, 'a', skip_char 
    bgt $t4, 'z', skip_char 
    
   
    la $t5, counts
    sub $t6, $t4, 'a'  #97 đến 122 (0-25) chỉ số kí tự
    add $t5, $t5, $t6 #move con trỏ t5 --> vị trí cần counts
    lb $t7, 0($t5)
    addi $t7, $t7, 1 #+1
    sb $t7, 0($t5)
    
skip_char:
    addi $t3, $t3, 1
    j count_loop

#Prints
print_counts:
    la $t0, counts
    li $t1, 0      #chỉ số kí tự        
    li $t4, 0               

print_loop:
    li $t2, 26  
    beq $t1, $t2, exit  #duyệt all
    
    lb $t3, 0($t0)  
    beqz $t3, skip_print 
    #check space if first letter
    beqz $t4, no_space
    li $v0, 4
    la $a0, space
    syscall
no_space:
    li $t4, 1  
#printf kí tự
    li $v0, 11
    addi $a0, $t1, 'a'
    syscall
    #printf , and space
    li $v0, 11
    li $a0, ','
    syscall
    li $a0, ' '
    syscall
    #printf count
    li $v0, 1
    move $a0, $t3
    syscall

skip_print:
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j print_loop

exit:
    li $v0, 10
    syscall
