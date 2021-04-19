.data
arr: .word 97 98 99

.text
main:
L0:
	li $v0, 11
	la $t0, arr
	lw $a0, 0($t0)
	syscall