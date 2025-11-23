# Five in a Row (Gomoku/Caro) Game
# MIPS Assembly for MARS 4.5

.data
board:         .space 225     # 15x15 board (225 cells)
player1Turn:   .asciiz "\nPlayer 1, please input your coordinates\n"
player2Turn:   .asciiz "\nPlayer 2, please input your coordinates\n"
coordPrompt:   .asciiz "Enter coordinates (x,y): "
player1Wins:   .asciiz "\nPlayer 1 wins\n"
player2Wins:   .asciiz "\nPlayer 2 wins\n"
tieMessage:    .asciiz "\nTie\n"
invalidInput:  .asciiz "\nInvalid input. Please try again.\n"
occupiedCell:  .asciiz "\nThis cell is already occupied. Please choose another one.\n"
horizontalLine:.asciiz "----------------------------------------------------------------\n"
colNumbers:    .asciiz "     0  1  2  3  4  5  6  7  8  9  10 11 12 13 14\n" 
rowFormat0:    .asciiz "0    "
rowFormat1:    .asciiz "1    "
rowFormat2:    .asciiz "2    "
rowFormat3:    .asciiz "3    "
rowFormat4:    .asciiz "4    "
rowFormat5:    .asciiz "5    "
rowFormat6:    .asciiz "6    "
rowFormat7:    .asciiz "7    "
rowFormat8:    .asciiz "8    "
rowFormat9:    .asciiz "9    "
rowFormat10:   .asciiz "10   "
rowFormat11:   .asciiz "11   "
rowFormat12:   .asciiz "12   "
rowFormat13:   .asciiz "13   "
rowFormat14:   .asciiz "14   "
player1Symbol: .byte 'X'
player2Symbol: .byte 'O'
emptyCell:     .byte '-'      # Empty cell symbol
comma:         .byte ','
space:         .byte ' '
resultFile:    .asciiz "result.txt"
buffer:        .space 10      # Buffer for reading coordinates
lineBuffer:    .space 100     # Buffer for writing to file

.text
.globl main

main:
    # Initialize the board
    jal initializeBoard
    
    # Display initial empty board
    jal displayBoard
    
    # Game loop
    li $s0, 1              # Current player (1 or 2)
    li $s1, 0              # Move counter (max 225)
    
gameLoop:
    # Check if board is full (tie)
    li $t0, 225
    beq $s1, $t0, gameTie
    
    # Prompt current player
    beq $s0, 1, promptPlayer1
    beq $s0, 2, promptPlayer2
    
continueAfterPrompt:
    # Get and validate coordinates
    jal getCoordinates
    
    # Save coordinates to preserved registers
    move $s2, $v0          # Row (x)
    move $s3, $v1          # Column (y)
    
    # Update the board
    move $a0, $s2          # Row
    move $a1, $s3          # Column
    move $a2, $s0          # Current player
    jal updateBoard
    
    # Display updated board
    jal displayBoard
    
    # Check for win
    move $a0, $s2          # Row of last move
    move $a1, $s3          # Column of last move
    move $a2, $s0          # Current player
    jal checkWin
    
    # If win, end game
    beq $v0, 1, gameWin
    
    # Switch player and continue
    beq $s0, 1, switchToPlayer2
    beq $s0, 2, switchToPlayer1
    
    j gameLoop
    
promptPlayer1:
    la $a0, player1Turn
    li $v0, 4
    syscall
    j continueAfterPrompt
    
promptPlayer2:
    la $a0, player2Turn
    li $v0, 4
    syscall
    j continueAfterPrompt
    
switchToPlayer1:
    li $s0, 1
    j gameLoop
    
switchToPlayer2:
    li $s0, 2
    j gameLoop
    
gameWin:
    # Display win message
    beq $s0, 1, player1Win
    beq $s0, 2, player2Win
    
player1Win:
    la $a0, player1Wins
    li $v0, 4
    syscall
    
    # Write board and result to file
    jal writeBoardToFile
    
    la $a0, player1Wins
    jal writeResultToFile
    
    j endGame
    
player2Win:
    la $a0, player2Wins
    li $v0, 4
    syscall
    
    # Write board and result to file
    jal writeBoardToFile
    
    la $a0, player2Wins
    jal writeResultToFile
    
    j endGame
    
gameTie:
    la $a0, tieMessage
    li $v0, 4
    syscall
    
    # Write board and result to file
    jal writeBoardToFile
    
    la $a0, tieMessage
    jal writeResultToFile
    
    j endGame
    
endGame:
    # Exit program
    li $v0, 10
    syscall

# Initialize the board with empty cells
initializeBoard:
    la $t0, board          # Load board address
    li $t1, 0              # Counter
    lb $t2, emptyCell      # Empty cell character
    
initLoop:
    beq $t1, 225, initDone
    sb $t2, ($t0)          # Store empty cell
    addi $t0, $t0, 1       # Next cell
    addi $t1, $t1, 1       # Increment counter
    j initLoop
    
initDone:
    jr $ra

# Display the current state of the board
displayBoard:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Print horizontal line
    la $a0, horizontalLine
    li $v0, 4
    syscall
    
    # Print column numbers
    la $a0, colNumbers
    li $v0, 4
    syscall
    
    la $t0, board          # Load board address
    li $t1, 0              # Row counter
    
displayRowLoop:
    # Choose appropriate row format string based on row number
    beq $t1, 0, printRow0
    beq $t1, 1, printRow1
    beq $t1, 2, printRow2
    beq $t1, 3, printRow3
    beq $t1, 4, printRow4
    beq $t1, 5, printRow5
    beq $t1, 6, printRow6
    beq $t1, 7, printRow7
    beq $t1, 8, printRow8
    beq $t1, 9, printRow9
    beq $t1, 10, printRow10
    beq $t1, 11, printRow11
    beq $t1, 12, printRow12
    beq $t1, 13, printRow13
    beq $t1, 14, printRow14
    
continueAfterRowNumber:
    li $t2, 0              # Column counter
    
displayColLoop:
    # Calculate the index in board array
    mul $t3, $t1, 15       # row * 15
    add $t3, $t3, $t2      # row * 15 + col
    la $t4, board
    add $t4, $t4, $t3
    
    # Print cell content
    lb $a0, ($t4)
    li $v0, 11
    syscall
    
    # Print consistent spacing for all columns
    li $a0, ' '
    li $v0, 11
    syscall
    li $a0, ' '
    li $v0, 11
    syscall
    
    # Move to next cell
    addi $t2, $t2, 1
    
    # Check if end of row
    li $t3, 15
    bne $t2, $t3, displayColLoop
    
    # Print newline
    li $a0, '\n'
    li $v0, 11
    syscall
    
    # Increment row counter
    addi $t1, $t1, 1
    
    # Check if all rows displayed
    li $t3, 15
    bne $t1, $t3, displayRowLoop
    
    # Print horizontal line
    la $a0, horizontalLine
    li $v0, 4
    syscall
    
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Row number printing handlers
printRow0:
    la $a0, rowFormat0
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow1:
    la $a0, rowFormat1
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow2:
    la $a0, rowFormat2
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow3:
    la $a0, rowFormat3
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow4:
    la $a0, rowFormat4
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow5:
    la $a0, rowFormat5
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow6:
    la $a0, rowFormat6
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow7:
    la $a0, rowFormat7
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow8:
    la $a0, rowFormat8
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow9:
    la $a0, rowFormat9
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow10:
    la $a0, rowFormat10
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow11:
    la $a0, rowFormat11
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow12:
    la $a0, rowFormat12
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow13:
    la $a0, rowFormat13
    li $v0, 4
    syscall
    j continueAfterRowNumber
    
printRow14:
    la $a0, rowFormat14
    li $v0, 4
    syscall
    j continueAfterRowNumber

# Get and validate coordinates from user input
getCoordinates:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
inputLoop:
    # Prompt for coordinates
    la $a0, coordPrompt
    li $v0, 4
    syscall
    
    # Read input string
    la $a0, buffer
    li $a1, 10
    li $v0, 8
    syscall
    
    # Parse coordinates (x,y)
    la $t0, buffer
    li $t1, 0              # x value
    li $t2, 0              # y value
    li $t3, 0              # parsing state (0=x, 1=y)
    
parseLoop:
    lb $t4, ($t0)          # Load character
    
    # Check for end of string or newline
    beq $t4, 0, parseEnd
    beq $t4, 10, parseEnd
    
    # Check for comma
    lb $t5, comma
    beq $t4, $t5, parseComma
    
    # Check if digit
    li $t5, '0'
    blt $t4, $t5, invalidCoord
    li $t5, '9'
    bgt $t4, $t5, invalidCoord
    
    # Convert to digit and update value
    addi $t4, $t4, -48     # ASCII to integer
    
    beq $t3, 0, parseX
    beq $t3, 1, parseY
    
parseX:
    # Update x value
    mul $t1, $t1, 10
    add $t1, $t1, $t4
    j parseNext
    
parseY:
    # Update y value
    mul $t2, $t2, 10
    add $t2, $t2, $t4
    j parseNext
    
parseComma:
    # Switch to parsing y
    li $t3, 1
    j parseNext
    
parseNext:
    # Move to next character
    addi $t0, $t0, 1
    j parseLoop
    
parseEnd:
    # Check if comma was found
    li $t4, 1
    bne $t3, $t4, invalidCoord   # If state is not 1, comma was not found
    
    # Validate coordinates
    li $t5, 0
    blt $t1, $t5, invalidCoord   # x < 0
    li $t5, 14
    bgt $t1, $t5, invalidCoord   # x > 14
    
    li $t5, 0
    blt $t2, $t5, invalidCoord   # y < 0
    li $t5, 14
    bgt $t2, $t5, invalidCoord   # y > 14
    
    # Check if cell is already occupied
    mul $t5, $t1, 15       # x * 15
    add $t5, $t5, $t2      # x * 15 + y
    la $t6, board
    add $t6, $t6, $t5
    lb $t7, ($t6)
    lb $t8, emptyCell
    bne $t7, $t8, occupiedCoord
    
    # Valid coordinates, return them
    move $v0, $t1          # x
    move $v1, $t2          # y
    
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
invalidCoord:
    # Display invalid input message
    la $a0, invalidInput
    li $v0, 4
    syscall
    j inputLoop
    
occupiedCoord:
    # Display occupied cell message
    la $a0, occupiedCell
    li $v0, 4
    syscall
    j inputLoop

# Update the board with player's move
updateBoard:
    # a0 = row (x), a1 = column (y), a2 = player
    
    # Calculate cell index - FIXED HERE
    mul $t0, $a0, 15       # row * 15
    add $t0, $t0, $a1      # row * 15 + col
    
    # Get player symbol
    beq $a2, 1, usePlayer1Symbol
    beq $a2, 2, usePlayer2Symbol
    
continueUpdate:
    # Update board
    la $t2, board
    add $t2, $t2, $t0      # Board address + cell index
    sb $t1, ($t2)          # Store symbol
    
    # Increment move counter
    addi $s1, $s1, 1
    
    # Return
    jr $ra
    
usePlayer1Symbol:
    lb $t1, player1Symbol
    j continueUpdate
    
usePlayer2Symbol:
    lb $t1, player2Symbol
    j continueUpdate

# Check for win condition - improved version using all 8 directions
checkWin:
    # a0 = last move row (x), a1 = last move column (y), a2 = player
    
    # Save return address and coordinates
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $a0, 4($sp)   # Save row
    sw $a1, 8($sp)   # Save column
    sw $a2, 12($sp)  # Save player
    
    # Get player symbol
    beq $a2, 1, checkPlayer1Win
    beq $a2, 2, checkPlayer2Win
    
continueCheckWin:
    # Save player symbol in s5
    move $s5, $t0
    
    # Check all directions for a win
    li $t9, 0           # Direction counter (0-7)
    
checkDirectionLoop:
    # Load arguments each time
    lw $a0, 4($sp)       # Row
    lw $a1, 8($sp)       # Column
    move $a2, $s5        # Player symbol
    move $a3, $t9        # Direction
    
    jal checkDirection
    beq $v0, 1, winFound
    
    # Try next direction
    addi $t9, $t9, 1
    li $t8, 8
    bne $t9, $t8, checkDirectionLoop
    
    # No win found in any direction
    li $v0, 0
    
endCheckWin:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    jr $ra
    
checkPlayer1Win:
    lb $t0, player1Symbol
    j continueCheckWin
    
checkPlayer2Win:
    lb $t0, player2Symbol
    j continueCheckWin
    
winFound:
    # Win found, set return value
    li $v0, 1
    j endCheckWin

# Check for a win in any of 8 directions
# a0 = row, a1 = column, a2 = player symbol, a3 = direction (0-7)
# Returns 1 in $v0 if win found, 0 otherwise
checkDirection:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Initialize counters
    li $t0, 1              # Counter for consecutive pieces (start with 1 for current position)
    
    # Set direction increments based on a3 (direction)
    li $t1, 0              # Row increment
    li $t2, 0              # Column increment
    
    beq $a3, 0, dirRight      # ?
    beq $a3, 1, dirDown       # ?
    beq $a3, 2, dirDownRight  # ?
    beq $a3, 3, dirDownLeft   # ?
    beq $a3, 4, dirLeft       # ?
    beq $a3, 5, dirUp         # ?
    beq $a3, 6, dirUpRight    # ?
    beq $a3, 7, dirUpLeft     # ?
    
continueDirection:
    # Save original position
    move $t3, $a0          # Original row
    move $t4, $a1          # Original column
    
    # Check in positive direction
    jal checkLine
    move $t5, $v0          # Save count in positive direction
    
    # Restore original position
    move $a0, $t3
    move $a1, $t4
    
    # Negate increments to check opposite direction
    neg $t1, $t1
    neg $t2, $t2
    
    # Check in negative direction
    jal checkLine
    add $t0, $t0, $v0      # Add count in negative direction
    
    # Check if total count is at least 5
    li $t6, 5
    bge $t0, $t6, directionWin
    
    # No win in this direction
    li $v0, 0
    j endDirection
    
directionWin:
    li $v0, 1
    
endDirection:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
# Direction setup routines
dirRight:
    li $t1, 0              # Row increment = 0
    li $t2, 1              # Column increment = 1
    j continueDirection
    
dirDown:
    li $t1, 1              # Row increment = 1
    li $t2, 0              # Column increment = 0
    j continueDirection
    
dirDownRight:
    li $t1, 1              # Row increment = 1
    li $t2, 1              # Column increment = 1
    j continueDirection
    
dirDownLeft:
    li $t1, 1              # Row increment = 1
    li $t2, -1             # Column increment = -1
    j continueDirection
    
dirLeft:
    li $t1, 0              # Row increment = 0
    li $t2, -1             # Column increment = -1
    j continueDirection
    
dirUp:
    li $t1, -1             # Row increment = -1
    li $t2, 0              # Column increment = 0
    j continueDirection
    
dirUpRight:
    li $t1, -1             # Row increment = -1
    li $t2, 1              # Column increment = 1
    j continueDirection
    
dirUpLeft:
    li $t1, -1             # Row increment = -1
    li $t2, -1             # Column increment = -1
    j continueDirection
    
# Helper function to check consecutive pieces in a specific direction
# a0 = row, a1 = column, a2 = player symbol, t1 = row increment, t2 = column increment
# Returns count of consecutive matching pieces (excluding starting position) in $v0
checkLine:
    # Move to next position in the given direction
    add $a0, $a0, $t1
    add $a1, $a1, $t2
    
    # Initialize count
    li $v0, 0
    
checkLoop:
    # Check if out of bounds
    li $t7, 0
    blt $a0, $t7, endCheck
    li $t7, 14
    bgt $a0, $t7, endCheck
    
    li $t7, 0
    blt $a1, $t7, endCheck
    li $t7, 14
    bgt $a1, $t7, endCheck
    
    # Calculate position in board
    mul $t7, $a0, 15       # row * 15
    add $t7, $t7, $a1      # row * 15 + col
    la $t8, board
    add $t8, $t8, $t7
    lb $t7, ($t8)          # Cell content
    
    # Compare with player symbol
    bne $t7, $a2, endCheck
    
    # Increment count and move to next position
    addi $v0, $v0, 1
    add $a0, $a0, $t1
    add $a1, $a1, $t2
    j checkLoop
    
endCheck:
    jr $ra

# Write board to file
writeBoardToFile:
    # Open file for writing
    la $a0, resultFile     # Filename
    li $a1, 1              # Write mode
    li $v0, 13             # Open file syscall
    syscall
    
    # Save file descriptor
    move $s7, $v0
    
    # Write board to file
    la $t0, board          # Load board address
    li $t1, 0              # Row counter
    
writeBoardRowLoop:
    li $t2, 0              # Column counter
    la $t9, lineBuffer     # Reset buffer pointer
    
writeBoardColLoop:
    # Get cell content
    mul $t3, $t1, 15       # row * 15
    add $t3, $t3, $t2      # row * 15 + col
    la $t4, board
    add $t4, $t4, $t3
    lb $t5, ($t4)          # Cell content
    
    # Write cell to buffer
    sb $t5, ($t9)
    addi $t9, $t9, 1
    
    # Add space
    li $t5, ' '
    sb $t5, ($t9)
    addi $t9, $t9, 1
    
    # Move to next column
    addi $t2, $t2, 1
    
    # Check if end of row
    li $t3, 15
    bne $t2, $t3, writeBoardColLoop
    
    # Add newline
    li $t5, '\n'
    sb $t5, ($t9)
    addi $t9, $t9, 1
    
    # Calculate buffer length (t9 - lineBuffer)
    la $t8, lineBuffer
    sub $a2, $t9, $t8
    
    # Write line to file
    move $a0, $s7          # File descriptor
    la $a1, lineBuffer     # Buffer
    li $v0, 15             # Write to file syscall
    syscall
    
    # Increment row counter
    addi $t1, $t1, 1
    
    # Check if all rows written
    li $t3, 15
    bne $t1, $t3, writeBoardRowLoop
    
    # Close file
    move $a0, $s7
    li $v0, 16             # Close file syscall
    syscall
    
    jr $ra

# Write result message to file
writeResultToFile:
    # a0 = result message
    
    # Save the message address
    move $t9, $a0          # Save result message temporarily
    
    # Open file for appending
    la $a0, resultFile     # Filename
    li $a1, 9              # Append mode (1 for write + 8 for append)
    li $v0, 13             # Open file syscall
    syscall
    
    # Save file descriptor
    move $s7, $v0
    
    # Write result message
    move $a0, $s7          # File descriptor
    move $a1, $t9          # Result message address
    
    # Calculate message length
    move $t0, $a1
    li $t1, 0
lengthLoop:
    lb $t2, ($t0)
    beqz $t2, endLengthLoop
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j lengthLoop
endLengthLoop:
    move $a2, $t1          # Message length
    
    li $v0, 15             # Write to file syscall
    syscall
    
    # Close file
    move $a0, $s7
    li $v0, 16             # Close file syscall
    syscall
    
    jr $ra