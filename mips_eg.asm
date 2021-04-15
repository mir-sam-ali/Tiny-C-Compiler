.data
prompt2: .word 100

.text
main:
L0:
	li $v0, 1
	la $t1, prompt2
	lw $t1, 0($t1)
	move $a0, $t1 
	syscall 
	