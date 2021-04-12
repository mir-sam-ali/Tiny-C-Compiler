.data
arr: .word 1 2 3 4 5

.text
main:
la $t1, arr

lw $t2, 4($t1)

lw $t0, 8($t1)

mul $s0, $t0, $t2

jr $ra