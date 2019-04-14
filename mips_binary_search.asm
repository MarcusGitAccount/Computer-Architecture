# Given an element, an array size n and n elements
# stored contiguously one after another write a
# a binary search algorithm given these input values

# Data is stored in the RAM memory starting at the zero address
# Store the result in RF[0]
# => index of the element if present in the array
# => -1 if not present in the array
# Register $0 will always be zero

0 lw $1, $0, 1      # load size stored as second element in the memory
1 lw $7, $0, 0      # load element to be searched

2 and $2, $2, $0    # left index
3 addi $3, $1, -1   # right index

4 addi $4, $0, 2    # memory address for the array (base)

5 add $5, $2, $3    # mid = left + right
6 sra $5, $5, 1     # mid = mid >> 1 <=> mid = mid / 2

7 add $6, $5, $4    # calculating array element offset for mid(base + index <=> $4 + $5)
8 lw $6, $6, 0      # get array[mid]

9 bgt $2, $3, 8     # if (left > right) => element not found, done

10 beq $6, $7, 6     # if (array[mid] == searched) then done
11 bgt $6, $7, 1     # if (array[mid] > searched) then right = mid -1 (jump next instr + 1)
12 blt $6, $7, 2     # if (array[mid] < searched) then left = mid + 1 (jump next instr + 1)

13 addi $3, $5, -1   # right = mid -1 
14 beq $0, $0, -10   # loop again

15 addi $2, $5, 1    # left = mid + 1 
16 beq $0, $0, -12   # loop again

17 add $1, $5, $0      # element found
18 beq $0, $0, 1     # ignore the next instruction

19 addi $1, $0, -1     # element not found

