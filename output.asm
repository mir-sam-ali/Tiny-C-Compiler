.data
arr0: .word 0 0 0 0 0
i1: .word 0
i3: .word 0
j5: .word 0
k6: .word 0
temp7: .word 0
i8: .word 0
prompt0: .asciiz "Sorted Array\n"
prompt1: .asciiz ", "
prompt2: .asciiz "\n"

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
	bne $t6, $zero, L5
L2: j L8
L3:
	la $s4, i1
	la $t5, i1
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	sw $t6, 0($s4)
L4: j L1
L5:
	li $t5, 5
	la $t6, i1
	lw $t6, 0($t6)
	sub $t6, $t5, $t6
	addi $t0, $t6, 0
L6:
	la $t4, i1
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	sw $t0, 0($s4)
L7: j L3
L8:
	la $s4, i3
	li $t5, 0
	sw $t5, 0($s4)
L9:
	la $t5, i3
	lw $t5, 0($t5)
	li $t6, 4
	slt $t6, $t5, $t6
	bne $t6, $zero, L14
L10: j L29
L11:
	la $t5, i3
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	addi $t1, $t6, 0
L12:
	la $s4, i3
	sw $t1, 0($s4)
L13: j L9
L14:
	la $s4, j5
	li $t5, 0
	sw $t5, 0($s4)
L15:
	li $t5, 5
	la $t6, i3
	lw $t6, 0($t6)
	sub $t6, $t5, $t6
	addi $t2, $t6, 0
L16:
	la $t5, j5
	lw $t5, 0($t5)
	slt $t6, $t5, $t2
	bne $t6, $zero, L20
L17: j L28
L18:
	la $s4, j5
	la $t5, j5
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	sw $t6, 0($s4)
L19: j L15
L20:
	la $t5, j5
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	addi $t3, $t6, 0
L21:
	la $s4, k6
	sw $t3, 0($s4)
L22:
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
	bne $t6, $zero, L24
L23: j L27
L24:
	la $s4, temp7
	la $t4, j5
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr0
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	sw $t5, 0($s4)
L25:
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
L26:
	la $t4, k6
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	la $t5, temp7
	lw $t5, 0($t5)
	sw $t5, 0($s4)
L27: j L18
L28: j L11
L29:
	li $v0, 4
	la $a0, prompt0
	syscall
L30:
	la $s4, i8
	li $t5, 0
	sw $t5, 0($s4)
L31:
	la $t5, i8
	lw $t5, 0($t5)
	li $t6, 4
	slt $t6, $t5, $t6
	bne $t6, $zero, L35
L32: j L37
L33:
	la $s4, i8
	la $t5, i8
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	sw $t6, 0($s4)
L34: j L31
L35:
	li $v0, 1
	la $t4, i8
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr0
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	move $a0, $t5
	syscall
	li $v0, 4
	la $a0, prompt1
	syscall
L36: j L33
L37:
	li $v0, 1
	li $t4, 5
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr0
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	move $a0, $t5
	syscall
	li $v0, 4
	la $a0, prompt2
	syscall
L38: jr $ra