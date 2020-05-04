#Student ID = 260777610
#################################invert Image######################
.data
.text
.globl invert_image
invert_image:
	# $a0 -> image struct
	#############return###############
	# $v0 -> new inverted image
	############################
	# Add Code
	
	#Step 0: setting v0 <- a0
	move $v0 $a0
	
	#step 1: get maxValue, width and height
	lb $t0 ($a0)	#t0<- width
	addi $a0 $a0 4	#increment pointer by 4
	lb $t1 ($a0)	#t1<-height
	addi $a0 $a0 4	#increment pointer by 4
	lb $t2 ($a0)	#t2 <- maxValue
	move $t3 $a0	#t3 <- &maxValue (Will be used later to update the new maxValue
	addi $a0 $a0 4	#now pointer<-first element of the char array
	
	#step 2: set each pixel p[i] <- maxValue-p[i] and update maxValue
	li $t4 0 	#t4=i <- 0
	mul $t5 $t1 $t0	#t5 <- width*height
	addi $t5 $t5 1	#so that the last pixel is included
	li $t0 0	#t0<-new maxValue
invert_image.loop:
	#Updating array[i]
	lb $t6 ($a0)	#t6 <- array[i]
	sub $t7 $t2 $t6	#t7 <- inverted value
	sb $t7 ($a0)	#array[i] <- t7
	
	#Incrementing
	addi $a0 $a0 1	#increment pointer by 1
	addi $t4 $t4 1	#increment t4 = i
	
	#Updating maxValue
	bgt $t7 $t0 invert_image.loop.updateMaxValue	#if t7 > maxVal set maxValue <- t7
	j invert_image.loop.checkBranch			#else jump to checkBranch (see if end of loop)
invert_image.loop.updateMaxValue:	
	move $t0 $t7			#maxValue <- t7
invert_image.loop.checkBranch:
	bne $t4 $t5 invert_image.loop
invert_image.loop.done:

	#setting maxValue <- t0
	sw $t0 ($t3)			#saving maxValue <- t0
	
	jr $ra
