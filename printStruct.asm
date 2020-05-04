
####################################write Image#####################
.data

print_struct_msg: .asciiz "Printing your image struct..."
nL: .asciiz "\n"
p: .ascii "P"
n2: .ascii "2"
n5: .ascii "5"
space: .ascii " "

int_str: .space 10


.macro print_int %x #this macro prints a given integer %x
	push($a0)
	push($v0)
	move      $a0, %x
	li      $v0, 1
	syscall
	pop($v0)
	pop($a0)
.end_macro

.macro print_char %x #this macro prints a given char at lower byte of %x
	push($a0)
	push($v0)
	move $a0, %x
	li $v0, 11
	syscall
	pop($v0)
	pop($a0)
.end_macro

.macro printNewLine
	push($a0)
	push($v0)
	la $a0, nL
	li $v0, 4
	syscall
	pop($v0)
	pop($a0)
.end_macro

.macro push  %reg
	sub $sp, $sp,4
	sw  %reg, ($sp)	# push %reg
  .end_macro
  
.macro pop  %reg
	lw  %reg, ($sp)	# pops %reg
	addi $sp, $sp, 4
  .end_macro

.macro save_regs
	push ($s0)
	push ($s1)
	push ($s2)
	push ($s3)
	push ($s4)
	push ($s5)
	push ($s6)
	push ($s7)
.end_macro

.macro restore_regs
	pop ($s7)
	pop ($s6)
	pop ($s5)
	pop ($s4)
	pop ($s3)
	pop ($s2)
	pop ($s1)
	pop ($s0)
.end_macro

.text
	
# Helper function
# This prints out an image struct to the screen (Run I/O)
# Takes the address of the image struct in $a0
# Takes the content's magic type (p2 or p5). Just input the type integer into $a1
.globl print_img_struct
print_img_struct:

	push($ra)
	push($fp)
	move $fp, $sp
	save_regs 
	
	push($a0)
	push($a1)
	push($v0)
	la $a0, print_struct_msg
	li $v0, 4
	syscall
	printNewLine
	pop($v0)
	pop($a1)
	pop ($a0)
	
	lw $s1, ($a0) # Loads the value of width
	lw $s2, 4($a0) # Loads the value of height
	lw $s3, 8($a0) # Loads the value of max_val
	
	mul $s4, $s1, $s2 # Loads the size of the content
	
	add $a0, $a0, 12
	beq $a1, 2, type_p2
	beq $a1, 5, type_p5
	
type_p2:
	
	li $v0, 4
	syscall
	j end_print
	
type_p5:
	move $t0, $a0 # Gets the address of content
	
	move $t1, $s2 # Gets the height

	move $t3, $s3 # Gets the max_value
	
loop:
	beq $t1, 0, end_print
	move $t2, $s1 # Gets the width
inner_loop:
	beq $t2, 0, end_inner
	li $t7, 0
	lbu $t7, ($t0)

	li $t6, 32
	print_char($t6)
	
	bge $t7, 100, no_extra_sp
	
	
	bge $t7, 10, one_extra_sp
	
	li $t6, 32
	print_char($t6)

one_extra_sp:
	#li $t6, 32
	print_char($t6)
	
no_extra_sp:	
	#addi $t2, $t2, 48
	print_int($t7)

	addi $t0, $t0, 1 
	addi $t2, $t2, -1
	j inner_loop
	
end_inner:
	addi $t1, $t1, -1
	
	#li $t6, 32
	#print_char($t6)
	printNewLine
	j loop
	
	end_print:
	
	restore_regs
	move $sp, $fp
	pop($fp)
	pop($ra)
	
jr $ra
