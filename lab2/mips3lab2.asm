.data
    array: .space 40          
    prompt: .asciiz "Please insert an element: "  
    result: .asciiz "Second largest value is "  
    found: .asciiz ", found in index "  
    comma: .asciiz ", "        
    newline: .asciiz "\n"      

.text
    li $t0, 0                
    la $t1, array            

read_value_loop:
    li $v0, 4                
    la $a0, prompt
    syscall
    
    li $v0, 5                
    syscall
    sw $v0, 0($t1)           
    
    addi $t1, $t1, 4         
    addi $t0, $t0, 1         
    
    bne $t0, 10, read_value_loop   

    la $t1, array            
    lw $t2, 0($t1)          #GTLN 

    li $t3, -2147483648      #dat t3 la so lon t2
    
    li $t0, 1           #t0 là vị trí thứ n     
find_loop:
    lw $t4, 0($t1)           
    
    bgt $t4, $t2, update_largestValue   
    
    beq $t4, $t2, nextElement    
    bgt $t4, $t3, update_second   
    j nextElement
    
update_largestValue:
    move $t3, $t2            
    move $t2, $t4            
    j nextElement

update_second:
    move $t3, $t4            

nextElement:
    addi $t1, $t1, 4         
    addi $t0, $t0, 1         
    bne $t0, 10, find_loop   
#hien thi
    li $v0, 4
    la $a0, result
    syscall
    
    li $v0, 1                
    move $a0, $t3
    syscall   
    
    li $v0, 4
    la $a0, found
    syscall
    
    la $t1, array            
    li $t0, 0                
    li $t5, 0                

find_indexes:
    lw $t4, 0($t1)           
    bne $t4, $t3, skip_index  
    
    beqz $t5, first_index    
    li $v0, 4
    la $a0, comma
    syscall

first_index:
    li $t5, 1                
    
    li $v0, 1                
    move $a0, $t0
    syscall

skip_index:
    addi $t1, $t1, 4         
    addi $t0, $t0, 1         
    bne $t0, 10, find_indexes 

    li $v0, 4 
    la $a0, newline
    syscall
#exit
    li $v0, 10               
    syscall
