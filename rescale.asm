# Student ID = 260777610
###############################rescale image######################
.data
.text
.globl rescale_image

rescale_image:
	# $a0 -> image struct
	############return###########
	# $v0 -> rescaled image
	######################
	
	#Step 0: setting v0 <- a0
	move $v0 $a0
	
	#Step 1: get maxValue, width and height
	lb $t0 ($a0)	#t0<- width
	addi $a0 $a0 4	#increment pointer by 4
	lb $t1 ($a0)	#t1<-height
	addi $a0 $a0 4	#increment pointer by 4
	lb $t2 ($a0)	#t2 <- maxValue
	move $t3 $a0	#t3 <- &maxValue (Will be used later to update the new maxValue)
	addi $a0 $a0 4	#now pointer<-first element of the char array

	#Step 2: getting minValue
	li $t4 0 	#t4=i <- 0
	mul $t5 $t1 $t0	#t5 <- width*height
	move $t0 $t2	#t0<-new minValue (initially set to maxValue)
rescale_image.findMinLoop:
	lb $t6 ($a0)	#t6 <- array[i]
	
	#Incrementing
	addi $a0 $a0 1	#increment pointer by 1
	addi $t4 $t4 1	#increment t4 = i
	
	#Updating minValue
	blt $t6 $t0 rescale_image.findMinLoop.updateMinValue	#if t6 > minVal, set minValue <- t6
	j rescale_image.findMinLoop.checkBranch			#else jump to checkBranch (see if end of loop)
rescale_image.findMinLoop.updateMinValue:	
	move $t0 $t6			#minValue <- t7
rescale_image.findMinLoop.checkBranch:
	bne $t4 $t5 rescale_image.findMinLoop
rescale_image.findMinLoop.done:
	#Step 3: Setting each element x_i <- [(x_i-minVal)*255]/(maxVal - minVal)
	#Step 3a: Updating maxVal <- 255
	sub $t6 $t2 $t0 #t6 <- maxVal - minVal
	beqz $t6 rescale_image.return	#if (maxVal - minVal = 0) return original image
	li $t7 255
	sw $t7 ($t3)		#Updating maxValue (address previously stored in t3)
	
     #Now we have:
	#t0 <- minValue
	li $t1 0 #t1 <- increment
	#t2 <- maxValue
	#t5 <- size of array	
	#t6 <- maxVal - minVal

	#Step 3b: Updating the image array
	move $a0 $v0	#Reset pointer
	addi $a0 $a0 12	#a0<-first element in the array
rescale_image.updateImage:
	#Updating Image
	lb $t7 ($a0)
	
	sub $t7 $t7 $t0		#t7 <- (x-minVal)
	mul $t7 $t7 255		#t7 <- 255(x-minVal)
	mtc1 $t7 $f0		#f0 <- 255(x-minVal)
	mtc1 $t6 $f2 		#f2 <- maxVal - minVal
	div.s $f4 $f0 $f2	#f4 <- 255(x-minVal)/(maxVal - minVal)
	round.w.s $f4 $f4	#casting f4 into int
	mfc1 $t7 $f4		#t7 <- f4
	
	sb $t7 ($a0)		#saving updated pixel
	
	#Incrementing
	addi $a0 $a0 1	#increment pointer by 1
	addi $t1 $t1 1	#increment t4 = i
	bne $t1 $t5 rescale_image.updateImage	#t4 = i, t5 = size of array
rescale_image.updateImage.done:

rescale_image.return:	
	jr $ra
	
	
