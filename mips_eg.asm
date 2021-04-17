.data
arr: .byte "61" "62" "63"

.text
main:
L0:
	la $t0, arr
	lb $t0, 0($t0)
	la $t1, arr
	addi $t0, $t0, 1
	lb $t1, 0($t1)
	slt $s0, $t1, $t0