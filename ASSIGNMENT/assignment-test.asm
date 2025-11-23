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
    
    # Calculate cell index
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

# Check for win using full board scan
# a0 = last move row (kh�ng s? d?ng), a1 = last move column (kh�ng s? d?ng), a2 = player
# Returns 1 in $v0 if win found, 0 otherwise
checkWin:
    # Save return address
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a2, 4($sp)         # Save player
    
    # Get player symbol based on player number
    beq $a2, 1, checkPlayer1Win
    beq $a2, 2, checkPlayer2Win
    
continueCheckWin:
    # Save player symbol in s5
    move $s5, $t0
    
    # First check all horizontal rows
    jal checkHorizontalWin
    beq $v0, 1, winFound
    
    # Next check all vertical columns
    jal checkVerticalWin
    beq $v0, 1, winFound
    
    # Finally check all diagonals
    jal checkDiagonalWin
    beq $v0, 1, winFound
    
    # No win found
    li $v0, 0
    
endCheckWin:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 8
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

# Check for horizontal wins (across rows)
checkHorizontalWin:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $t1, 0                  # Row counter
    
horizontalRowLoop:
    li $t2, 0                  # Column counter
    li $t3, 0                  # Consecutive count
    
horizontalColLoop:
    # Calculate board index
    mul $t4, $t1, 15           # row * 15
    add $t4, $t4, $t2          # row * 15 + col
    la $t5, board
    add $t5, $t5, $t4
    lb $t6, ($t5)              # Get cell content
    
    # Check if cell matches player symbol
    beq $t6, $s5, horizontalMatch
    li $t3, 0                  # Reset counter if no match
    j horizontalNextCol
    
horizontalMatch:
    addi $t3, $t3, 1           # Increment consecutive count
    li $t7, 5
    beq $t3, $t7, horizontalWinFound
    
horizontalNextCol:
    addi $t2, $t2, 1           # Move to next column
    li $t7, 15
    bne $t2, $t7, horizontalColLoop
    
    # Move to next row
    addi $t1, $t1, 1
    li $t7, 15
    bne $t1, $t7, horizontalRowLoop
    
    # No horizontal win found
    li $v0, 0
    j endHorizontalCheck
    
horizontalWinFound:
    li $v0, 1
    
endHorizontalCheck:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Check for vertical wins (down columns)
checkVerticalWin:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $t1, 0                  # Column counter
    
verticalColLoop:
    li $t2, 0                  # Row counter
    li $t3, 0                  # Consecutive count
    
verticalRowLoop:
    # Calculate board index
    mul $t4, $t2, 15           # row * 15
    add $t4, $t4, $t1          # row * 15 + col
    la $t5, board
    add $t5, $t5, $t4
    lb $t6, ($t5)              # Get cell content
    
    # Check if cell matches player symbol
    beq $t6, $s5, verticalMatch
    li $t3, 0                  # Reset counter if no match
    j verticalNextRow
    
verticalMatch:
    addi $t3, $t3, 1           # Increment consecutive count
    li $t7, 5
    beq $t3, $t7, verticalWinFound
    
verticalNextRow:
    addi $t2, $t2, 1           # Move to next row
    li $t7, 15
    bne $t2, $t7, verticalRowLoop
    
    # Move to next column
    addi $t1, $t1, 1
    li $t7, 15
    bne $t1, $t7, verticalColLoop
    
    # No vertical win found
    li $v0, 0
    j endVerticalCheck
    
verticalWinFound:
    li $v0, 1
    
endVerticalCheck:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Check for diagonal wins
checkDiagonalWin:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Check top-left to bottom-right diagonals
    jal checkTopLeftDiagonals
    beq $v0, 1, diagonalWinFound
    
    # Check top-right to bottom-left diagonals
    jal checkTopRightDiagonals
    beq $v0, 1, diagonalWinFound
    
    # No diagonal win found
    li $v0, 0
    j endDiagonalCheck
    
diagonalWinFound:
    li $v0, 1
    
endDiagonalCheck:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Check top-left to bottom-right diagonals
checkTopLeftDiagonals:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Start with diagonals beginning from first column
    li $t1, 0                  # Starting row index
    li $t2, 10                 # Final starting row (15 - 5)
    
topLeftRowStartLoop:
    li $t3, 0                  # Starting column is always 0
    li $t4, 0                  # Consecutive count
    
    # Calculate starting position
    move $t5, $t1              # Current row
    move $t6, $t3              # Current column
    
topLeftRowDiagLoop:
    # Check if out of bounds
    li $t7, 15
    beq $t5, $t7, topLeftRowNextStart
    beq $t6, $t7, topLeftRowNextStart
    
    # Calculate board index
    mul $t8, $t5, 15           # row * 15
    add $t8, $t8, $t6          # row * 15 + col
    la $t9, board
    add $t9, $t9, $t8
    lb $t9, ($t9)              # Get cell content
    
    # Check if cell matches player symbol
    beq $t9, $s5, topLeftRowMatch
    li $t4, 0                  # Reset counter if no match
    j topLeftRowNext
    
topLeftRowMatch:
    addi $t4, $t4, 1           # Increment consecutive count
    li $t7, 5
    beq $t4, $t7, topLeftDiagWinFound
    
topLeftRowNext:
    # Move to next diagonal position
    addi $t5, $t5, 1           # row++
    addi $t6, $t6, 1           # col++
    j topLeftRowDiagLoop
    
topLeftRowNextStart:
    # Try next starting position
    addi $t1, $t1, 1
    ble $t1, $t2, topLeftRowStartLoop
    
    # Now check diagonals starting from first row
    li $t1, 0                  # Starting row is always 0
    li $t2, 1                  # Starting column index
    li $t3, 10                 # Final starting column (15 - 5)
    
topLeftColStartLoop:
    li $t4, 0                  # Consecutive count
    
    # Calculate starting position
    move $t5, $t1              # Current row
    move $t6, $t2              # Current column
    
topLeftColDiagLoop:
    # Check if out of bounds
    li $t7, 15
    beq $t5, $t7, topLeftColNextStart
    beq $t6, $t7, topLeftColNextStart
    
    # Calculate board index
    mul $t8, $t5, 15           # row * 15
    add $t8, $t8, $t6          # row * 15 + col
    la $t9, board
    add $t9, $t9, $t8
    lb $t9, ($t9)              # Get cell content
    
    # Check if cell matches player symbol
    beq $t9, $s5, topLeftColMatch
    li $t4, 0                  # Reset counter if no match
    j topLeftColNext
    
topLeftColMatch:
    addi $t4, $t4, 1           # Increment consecutive count
    li $t7, 5
    beq $t4, $t7, topLeftDiagWinFound
    
topLeftColNext:
    # Move to next diagonal position
    addi $t5, $t5, 1           # row++
    addi $t6, $t6, 1           # col++
    j topLeftColDiagLoop
    
topLeftColNextStart:
    # Try next starting position
    addi $t2, $t2, 1
    ble $t2, $t3, topLeftColStartLoop
    
    # No diagonal win found
    li $v0, 0
    j endTopLeftCheck
    
topLeftDiagWinFound:
    li $v0, 1
    
endTopLeftCheck:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Check top-right to bottom-left diagonals
checkTopRightDiagonals:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Start with diagonals beginning from last column
    li $t1, 0                  # Starting row index
    li $t2, 10                 # Final starting row (15 - 5)
    
topRightRowStartLoop:
    li $t3, 14                 # Starting column is always 14 (last column)
    li $t4, 0                  # Consecutive count
    
    # Calculate starting position
    move $t5, $t1              # Current row
    move $t6, $t3              # Current column
    
topRightRowDiagLoop:
    # Check if out of bounds
    li $t7, 15
    beq $t5, $t7, topRightRowNextStart
    li $t7, -1
    beq $t6, $t7, topRightRowNextStart
    
    # Calculate board index
    mul $t8, $t5, 15           # row * 15
    add $t8, $t8, $t6          # row * 15 + col
    la $t9, board
    add $t9, $t9, $t8
    lb $t9, ($t9)              # Get cell content
    
    # Check if cell matches player symbol
    beq $t9, $s5, topRightRowMatch
    li $t4, 0                  # Reset counter if no match
    j topRightRowNext
    
topRightRowMatch:
    addi $t4, $t4, 1           # Increment consecutive count
    li $t7, 5
    beq $t4, $t7, topRightDiagWinFound
    
topRightRowNext:
    # Move to next diagonal position
    addi $t5, $t5, 1           # row++
    addi $t6, $t6, -1          # col--
    j topRightRowDiagLoop
    
topRightRowNextStart:
    # Try next starting position
    addi $t1, $t1, 1
    ble $t1, $t2, topRightRowStartLoop
    
    # Now check diagonals starting from top row, moving left
    li $t1, 0                  # Starting row is always 0
    li $t2, 13                 # Starting column index (second-to-last column)
    li $t3, 4                  # Final starting column (to ensure at least 5 cells)
    
topRightColStartLoop:
    li $t4, 0                  # Consecutive count
    
    # Calculate starting position
    move $t5, $t1              # Current row
    move $t6, $t2              # Current column
    
topRightColDiagLoop:
    # Check if out of bounds
    li $t7, 15
    beq $t5, $t7, topRightColNextStart
    li $t7, -1
    beq $t6, $t7, topRightColNextStart
    
    # Calculate board index
    mul $t8, $t5, 15           # row * 15
    add $t8, $t8, $t6          # row * 15 + col
    la $t9, board
    add $t9, $t9, $t8
    lb $t9, ($t9)              # Get cell content
    
    # Check if cell matches player symbol
    beq $t9, $s5, topRightColMatch
    li $t4, 0                  # Reset counter if no match
    j topRightColNext
    
topRightColMatch:
    addi $t4, $t4, 1           # Increment consecutive count
    li $t7, 5
    beq $t4, $t7, topRightDiagWinFound
    
topRightColNext:
    # Move to next diagonal position
    addi $t5, $t5, 1           # row++
    addi $t6, $t6, -1          # col--
    j topRightColDiagLoop
    
topRightColNextStart:
    # Try next starting position
    addi $t2, $t2, -1
    bge $t2, $t3, topRightColStartLoop
    
    # No diagonal win found
    li $v0, 0
    j endTopRightCheck
    
topRightDiagWinFound:
    li $v0, 1
    
endTopRightCheck:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
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
