.data
printf: .asciiz "Enter your name: "  # Prompt message
helo:  .asciiz "Hello, "            # Greeting prefix
newline: .asciiz "\n"                # Newline character
length: .space  50                   # Reserve space for input

.text
.globl main
main:
    # Print prompt message
    li $v0, 4
    la $a0, printf
    syscall

    # Read user input (string)
    li $v0, 8          
    la $a0, length     
    li $a1, 50         
    syscall

    # Print "Hello, "
    li $v0, 4
    la $a0, helo
    syscall

    # Print user input (name)
    li $v0, 4
    la $a0, length
    syscall

    # Print newline for better formatting
    li $v0, 4
    la $a0, newline
    syscall
    
    # Exit
    li $v0, 10  # syscall exit
    syscall
