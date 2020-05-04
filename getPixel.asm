# Student ID = 260777610
##########################get pixel #######################
.data
error:		.asciiz "Error! an invalid row or column was entered\n"
.text
.globl get_pixel
get_pixel:
	# $a0 -> image struct
	# $a1 -> row number
	# $a2 -> column number
	################return##################
	# $v0 -> value of image at (row,column)
	#######################################
	
	#Getting width and height
	lb $t0 ($a0)	#t0<- width
	addi $a0 $a0 4	#increment pointer by 4
	lb $t1 ($a0)	#t0<-height
	addi $a0 $a0 8	#now pointer<-first element of the char array
	
	#Returning the desired output (Bad Input)
	bltz $a1 get_pixel.returnFailure 	#if (a1 < 0 ) return failure
	bltz $a2 get_pixel.returnFailure 	#if (a2 < 0 ) return failure
	bgt $a1 $t0 get_pixel.returnFailure 	#if (a1>width) return failure
	bgt $a2 $t1 get_pixel.returnFailure 	#if (a2>height return failure
	
	#Returning the desired output (Good Input)
	#return the element at (desired row -1)*(elements per row)+(desired column -1)
	
	subi $t2 $a1 1	#t2 <- desired row - 1
	mul $t2 $t2 $t0	#t2 <- (desired row -1)*(elements per row)
	add $t2 $t2 $a2	#t2 <- (desired row -1)*(elements per row)+(desired column)
	subi $t2 $t2 1	#t2 <- (desired row -1)*(elements per row)+(desired column -1)
	
	#now returning the element at (pointer+t2)
	add $t3 $t2 $a0
	lb $v0 ($t3)
	
	jr $ra

get_pixel.returnFailure:
	li $v0 4 #issuing error
	la $a0 error
	syscall
	
	li $v0 0 #returning with v0 <- 0
	jr $ra
