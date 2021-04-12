.data
arr0: .word 0 0 0 0 0
i1: .word 0
i3: .word 0
j5: .word 0
k6: .word 0
temp7: .word 0

.text
main:
L0:
	la $s4, i1
	li $t5, 0
	sw $t5, 0($s4)
L1:
	la $t5, i1
	lw $t5, 0($t5)
	li $t6, 5
	slt $t6, $t5, $t6
	bne $t6, $zero, L6
L2: j L9
L3:
	la $t5, i1
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	addi $t0, $t6, 0
L4:
	la $s4, i1
	sw $t0, 0($s4)
L5: j L1
L6:
	li $t5, 5
	la $t6, i1
	lw $t6, 0($t6)
	sub $t6, $t5, $t6
	addi $t1, $t6, 0
L7:
	la $t4, i1
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	sw $t1, 0($s4)
L8: j L3
L9:
	la $s4, i3
	li $t5, 0
	sw $t5, 0($s4)
L10:
	la $t5, i3
	lw $t5, 0($t5)
	li $t6, 4
	slt $t6, $t5, $t6
	bne $t6, $zero, L15
L11: j L31
L12:
	la $t5, i3
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	addi $t2, $t6, 0
L13:
	la $s4, i3
	sw $t2, 0($s4)
L14: j L10
L15:
	la $s4, j5
	li $t5, 0
	sw $t5, 0($s4)
L16:
	li $t5, 5
	la $t6, i3
	lw $t6, 0($t6)
	sub $t6, $t5, $t6
	addi $t3, $t6, 0
L17:
	la $t5, j5
	lw $t5, 0($t5)
	slt $t6, $t5, $t3
	bne $t6, $zero, L22
L18: j L30
L19:
	la $t5, j5
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	addi $t4, $t6, 0
L20:
	la $s4, j5
	sw $t4, 0($s4)
L21: j L16
L22:
	la $t5, j5
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	addi $t5, $t6, 0
L23:
	la $s4, k6
	sw $t5, 0($s4)
L24:
	la $t4, j5
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr0
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	la $t6, k6
	lw $t6, 0($t6)
	li $t4, 4
	mul $t4, $t4, $t6
	la $t6, arr0
	add $t6, $t6, $t4
	lw $t6, 0($t6)
	slt $t6, $t6, $t5
	bne $t6, $zero, L26
L25: j L29
L26:
	la $s4, temp7
	la $t4, j5
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr0
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	sw $t5, 0($s4)
L27:
	la $t4, j5
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	la $t4, k6
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr0
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	sw $t5, 0($s4)
L28:
	la $t4, k6
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	la $t5, temp7
	lw $t5, 0($t5)
	sw $t5, 0($s4)
L29: j L19
L30: j L12
L31: jr $ra