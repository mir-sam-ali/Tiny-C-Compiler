.data
arr0: .word 0 0 0 0 0
i1: .word 0
j3: .word 0
k4: .word 0
temp5: .word 0
i6: .word 0
prompt0: .asciiz " "
prompt1: .asciiz "\n"

.text
main:
L0:
	li $t4, 0
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	li $t5, 98
	sw $t5, 0($s4)
L1:
	li $t4, 1
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	li $t5, 99
	sw $t5, 0($s4)
L2:
	li $t4, 2
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	li $t5, 100
	sw $t5, 0($s4)
L3:
	li $t4, 3
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	li $t5, 97
	sw $t5, 0($s4)
L4:
	li $t4, 4
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	li $t5, 101
	sw $t5, 0($s4)
L5:
	la $s4, i1
	li $t5, 0
	sw $t5, 0($s4)
L6:
	la $t5, i1
	lw $t5, 0($t5)
	li $t6, 4
	slt $t7, $t5, $t6
	bne $t7, $zero, L11
L7: j L27
L8:
	la $t5, i1
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	addi $t0, $t6, 0
L9:
	la $s4, i1
	sw $t0, 0($s4)
L10: j L6
L11:
	la $s4, j3
	li $t5, 0
	sw $t5, 0($s4)
L12:
	li $t5, 4
	la $t6, i1
	lw $t6, 0($t6)
	sub $t6, $t5, $t6
	addi $t1, $t6, 0
L13:
	la $t5, j3
	lw $t5, 0($t5)
	slt $t7, $t5, $t1
	bne $t7, $zero, L18
L14: j L26
L15:
	la $t5, j3
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	addi $t2, $t6, 0
L16:
	la $s4, j3
	sw $t2, 0($s4)
L17: j L12
L18:
	la $t5, j3
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	addi $t3, $t6, 0
L19:
	la $s4, k4
	sw $t3, 0($s4)
L20:
	la $t4, j3
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr0
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	la $t6, k4
	lw $t6, 0($t6)
	li $t4, 4
	mul $t4, $t4, $t6
	la $t6, arr0
	add $t6, $t6, $t4
	lw $t6, 0($t6)
	slt $t7, $t6, $t5
	bne $t7, $zero, L22
L21: j L25
L22:
	la $s4, temp5
	la $t4, j3
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr0
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	sw $t5, 0($s4)
L23:
	la $t4, j3
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	la $t4, k4
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr0
	add $t5, $t5, $t4
	lw $t5, 0($t5)
	sw $t5, 0($s4)
L24:
	la $t4, k4
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $s4, arr0
	add $s4, $s4, $t4
	la $t5, temp5
	lw $t5, 0($t5)
	sw $t5, 0($s4)
L25: j L15
L26: j L8
L27:
	la $s4, i6
	li $t5, 0
	sw $t5, 0($s4)
L28:
	la $t5, i6
	lw $t5, 0($t5)
	li $t6, 5
	slt $t7, $t5, $t6
	bne $t7, $zero, L32
L29: j L34
L30:
	la $s4, i6
	la $t5, i6
	lw $t5, 0($t5)
	li $t6, 1
	add $t6, $t5, $t6
	sw $t6, 0($s4)
L31: j L28
L32:
	li $v0, 11
	la $t4, i6
	lw $t4, 0($t4)
	li $t5, 4
	mul $t4, $t4, $t5
	la $t5, arr0
	add $t5, $t5, $t4
	lw $a0, 0($t5)
	syscall
	li $v0, 4
	la $a0, prompt0
	syscall
L33: j L30
L34:
	li $v0, 4
	la $a0, prompt1
	syscall
L35: jr $ra