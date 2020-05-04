# Student ID = 260777610
##########################set pixel #######################
.data
error:		.asciiz "Error! an invalid row or column was entered\n"
.text
.globl set_pixel
set_pixel:
	# $a0 -> image struct
	# $a1 -> row number
	# $a2 -> column number
	# $a3 -> new value (clipped at 255)
	###############return################
	#void
	# Add code here
	
	#First checking if a3 > 255
	bgt $a3 255 set_pixel.toMax
	j set_pixel.toMax.done
set_pixel.toMax:
	li $a3 255	#If a3>255 set a3 = 255
set_pixel.toMax.done:	

	#Getting width and height
	lb $t0 ($a0)	#t0<- width
	addi $a0 $a0 4	#increment pointer by 4
	lb $t1 ($a0)	#t0<-height
	addi $a0 $a0 4	#increment pointer by 4
	lb $t7 ($a0)	#t7 <- maxValue
	move $t6 $a0	#t6 <- &maxValue
	addi $a0 $a0 4	#now pointer<-first element of the char array
			
	#checking if maxvalue should be updated
	bgt $a3 $t7 set_pixel.maxValueUpdate	#if a3>maxValue j set_pixel.maxValueUpdate
	j set_pixel.maxValueUpdate.done		#else j done
set_pixel.maxValueUpdate:
	sw $a3 ($t6)				#Update maxValue <- a3
set_pixel.maxValueUpdate.done:
	
	
	#Returning the desired output (Bad Input)
	bltz $a1 set_pixel.returnFailure 	#if (a1 < 0 ) return failure
	bltz $a2 set_pixel.returnFailure 	#if (a2 < 0 ) return failure
	bgt $a1 $t0 set_pixel.returnFailure 	#if (a1>width) return failure
	bgt $a2 $t1 set_pixel.returnFailure 	#if (a2>height return failure
	
	#Returning the desired output (Good Input)
	#return the element at (desired row -1)*(elements per row)+(desired column -1)
	
	subi $t2 $a1 1	#t2 <- desired row - 1
	mul $t2 $t2 $t0	#t2 <- (desired row -1)*(elements per row)
	add $t2 $t2 $a2	#t2 <- (desired row -1)*(elements per row)+(desired column)
	subi $t2 $t2 1	#t2 <- (desired row -1)*(elements per row)+(desired column -1)
	
	#now setting the element at (pointer+t2)
	add $t3 $t2 $a0
	sb $a3 ($t3)
	
	jr $ra

set_pixel.returnFailure:
	li $v0 4 #issuing error
	la $a0 error
	syscall
	
	li $v0 0 #returning failure
	jr $ra
