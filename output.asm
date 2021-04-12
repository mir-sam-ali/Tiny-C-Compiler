.data
i: .word 0
arr: .word 0 0 0 0 0
j: .word 0
k: .word 0
temp: .word 0

.text
main:
0:
	la $t4, i
	lw $t5, 0
	sw $t5, 0($t4)
1:
	la $t4, i
	lw $t4, 0($t4)
	lw $t5, 5
	slt $t6, $t4, $t5
	bne $t6, $zero, 5
2: j 8
3:
	la $t4, i
	la $t5, i
	lw $t5, 0($t5)
	lw $t6, 1
	add $t6, $t5, $t6
	sw $t6, 0($t4)
4: j 1
5:
	lw $t5, 5
	la $t6, i
	lw $t6, 0($t6)
	sub $t6, $t5, $t6
	addi $t0, $t6, 0
6:
	lw $t4, i
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr
	add $s4, $s4, $t4
	sw $t0, 0($s4)
7: j 3
8:
	la $t4, i
	lw $t5, 0
	sw $t5, 0($t4)
9:
	la $t4, i
	lw $t4, 0($t4)
	lw $t5, 4
	slt $t6, $t4, $t5
	bne $t6, $zero, 13
10: j 28
11:
	la $t4, i
	la $t5, i
	lw $t5, 0($t5)
	lw $t6, 1
	add $t6, $t5, $t6
	sw $t6, 0($t4)
12: j 9
13:
	la $t4, j
	lw $t5, 1
	sw $t5, 0($t4)
14:
	lw $t5, 5
	la $t6, i
	lw $t6, 0($t6)
	sub $t6, $t5, $t6
	addi $t1, $t6, 0
15:
	la $t4, j
	lw $t4, 0($t4)
	slt $t6, $t4, $t1
	bne $t6, $zero, 19
16: j 27
17:
	la $t4, j
	la $t5, j
	lw $t5, 0($t5)
	lw $t6, 1
	add $t6, $t5, $t6
	sw $t6, 0($t4)
18: j 14
19:
	la $t5, j
	lw $t5, 0($t5)
	lw $t6, 1
	add $t6, $t5, $t6
	addi $t2, $t6, 0
20:
	la $t4, k
	sw $t2, 0($t4)
21:
	lw $t4, j]
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	addi $t1, $t5, 0
22:
	lw $t4, k]
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	addi $t2, $t5, 0
23:
	slt $t6, $t2, $t1
	bne $t6, $zero, 23
24: j 26
25:
	lw $t4, j]
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	sw $t5, 0($temp)
26:
	lw $t4, j
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr
	add $s4, $s4, $t4
	lw $t4, k]
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	sw $t5, 0($s4)
27:
	lw $t4, k
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr
	add $s4, $s4, $t4
	sw $temp, 0($s4)
28: j 17
29: j 11
30: jr $ra