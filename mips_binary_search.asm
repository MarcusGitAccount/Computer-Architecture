# Given an element, an array size n and n elements
# stored contiguously one after another write a
# a binary search algorithm given these input values

# Data is stored in the RAM memory starting at the zero address
# Store the result in M[0]
# Register $0 will always be zero

lw $1, $0, 0      # load size stored as first element in the memory
lw $7, $0, 1      # load element to be searched

and $2, $2, $0    # left index
addi $3, $1, -1   # right index

addi $4, $0, 1    # memory address for the array (base)

add $5, $2, $3    # mid = left + right
sra $5, $5, 1     # mid = mid >> 1 <=> mid = mid / 2

add $6, $5, $4    # calculating array element offset for mid(base + index <=> $4 + $5)
lw $6, $6, 0      # get array[mid]

beq $2, $3, 7     # if (left == right) => element found, done
bgt $2, $3, 8     # if (left > right) => element not found, done

blt $6, $7, 1     # if (array[mid] < searched) then right = mid -1 (jump next instr + 1)
bgt $6, $7, 2     # if (array[mid] > searched) then left = mid + 1 (jump next instr + 1)

addi $3, $5, -1   # right = mid -1 
beq $0, $0, -10   # loop again

addi $2, $5, 1    # left = mid + 1 
beq $0, $0, -12   # loop again

sw $0, $0, 1      # element found
beq $0, $0, 1     # ignore the next instruction

sw $0, $0, 0      # element not found

