# By Yuan
# readTester.asm
# depends on printStruct
.data
file1:		.asciiz "copy.pgm"
file2:		.asciiz "feep.pgm"
writefilep2:	.asciiz "writetestp2.pgm"
writefilep5:	.asciiz "writetestp5.pgm"

txt1:		.asciiz "Testing with feep.pgm (P5)...\n"
txt2:		.asciiz "Testing with copy.pgm (P2)...\n"
txt3:		.asciiz "END OF TESTER"
txtwrite:	.asciiz "============\nTest write now...\nCheck writetestp5.pgm == feep.pgm and writetestp2.pgm == copy.pgm\n============\n"

testpixel:	.asciiz "Now testing get_pixel and set_pixel...\nExpected output: -----\n0\nget error\n0\nget error\n0\n15\nset error\nset error\n18\n18\nYour output: ---------\n"
lf:		.asciiz "\n"

testinvert:	.asciiz "Now testing invertImage... Here's inverted feep with the bottom right blackout (You can also view in inverted.pgm). "
inverted:	.asciiz "inverted.pgm"
.text
.globl tester

tester:
	li   $v0, 4
	la   $a0, txt1
	syscall
	
	la   $a0, file1
	jal read_image
	
	move $a0, $v0
	li   $a1, 5
	jal  print_img_struct
	
	li   $v0, 4
	la   $a0, txt2
	syscall
	
	la   $a0, file2
	jal read_image
	
	move $a0, $v0
	li   $a1, 5
	jal  print_img_struct
	
	# write
	li   $v0, 4
	la   $a0, txtwrite
	syscall
	
	la   $a0, file1
	jal read_image
	move $a0, $v0
	la   $a1, writefilep2
	li   $a2, 1
	jal write_image
	
	la   $a0, file1
	jal read_image
	move $a0, $v0
	la   $a1, writefilep5
	li   $a2, 0
	jal write_image
	
	# pixel
	li   $v0, 4
	la   $a0, testpixel
	syscall
	la   $a0, file1
	jal read_image
	move $s0, $v0	# s0 -> image struct
	
	move $a0, $s0
	li   $a1, 2
	li   $a2, 2
	jal get_pixel
	
	move $a0, $v0
	jal print_int
	
	move $a0, $s0
	li   $a1, 0
	li   $a2, 24
	jal get_pixel
	
	move $a0, $v0
	jal print_int
	
	move $a0, $s0
	li   $a1, 7
	li   $a2, 0
	jal get_pixel
	
	move $a0, $v0
	jal print_int
	
	move $a0, $s0
	li   $a1, 5
	li   $a2, 19
	jal get_pixel
	
	move $a0, $v0
	jal print_int
	
	move $a0, $s0
	li   $a1, 0
	li   $a2, 24
	jal set_pixel
	
	move $a0, $s0
	li   $a1, 7
	li   $a2, 0
	jal set_pixel
	
	move $a0, $s0
	li   $a1, 6
	li   $a2, 23
	li   $a3, 18
	jal set_pixel
	
	lw $a0, 8($s0)
	jal print_int
	
	move $a0, $s0
	li   $a1, 6
	li   $a2, 23
	jal get_pixel
	
	move $a0, $v0
	jal print_int
	
	# invert
	li   $v0, 4
	la   $a0, testinvert
	syscall
	
	move $a0, $s0
	jal invert_image
	move $s0, $v0
	
	move $a0, $s0
	li   $a1, 5
	jal print_img_struct
	
	move $a0, $s0
	la   $a1, inverted
	li   $a2, 1
	jal write_image
	
	# end
	li   $v0, 4
	la   $a0, txt3
	syscall
	
	li   $v0, 10
	syscall

print_int:
	li   $v0, 1
	syscall
	li   $v0, 4
	la   $a0, lf
	syscall
	jr   $ra