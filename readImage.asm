#Student ID = 260777610
#########################Read Image#########################
.data
buffer:		.space 1024

.text
		.globl read_image
read_image:
	# $a0 -> input file name
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	#	int width;
	#       int height;
	#	int max_value;
	#	char contents[width*height];
	#	}
	##############################################
	# Add code here

	#Getting File Descriptor
	addi $v0 $zero 13 # function 13 -> Read from file
	#a0 <- address of file
	addi $a1 $zero 0 #Set a1=0, this adds the flag for read only. 
	addi $a2 $zero 0 #set a2=0, This sets mode = 0. This mode is ignored for function 13
	syscall #The file file descriptor is now saved in v0
	
	#Reading contents of the file
	#Setting a0<-file descriptor, a1<-Address of input buffer, a2<-maximum number of charecters to read, v0=14
	addi $a0 $v0 0 #a0<-file descriptor
	la $a1 buffer #a1<-address of buffer
	addi $a2 $zero 1024 #Set maximum read size = buffer size
	addi $v0 $zero 14 #Mode for read from file
	syscall #now buffer<-contents of file
	
	#Now Making Struct
	#t3<-width, t4<-height, t5<-maxValue
	
	la $t2 buffer
	addi $t2 $t2 3 #Skip past the first 3 bytes, this will consist of 'P*\n'
	
	#Finding Width
find_width.begin:
	lb $t7 ($t2)
	sub $t7 $t7 48
	move $t0 $t2 #t0 <- temporary pointer to buffer[i]
find_width.loopStart: 		#finding the total number by looping until -16 (whitespace) is reached
	addi $t0 $t0 1
	lb $t1 ($t0)			#t1<-buffer[t7+1]
	subi $t1 $t1 48 		#decrement by 48 to get the proper result
	bltz $t1 find_width.loopEnd	#if t1<0 exit
	mul $t7 $t7 10			#else adjust t7 by t7<-t7*10+t1
	add $t7 $t7 $t1
	j find_width.loopStart 	#return and loop for next number in sequence
find_width.loopEnd: 
	move $t2 $t0 		#Now set the pointer to t0+1
	addi $t2 $t2 1
	move $t3 $t7		#now t3<-width
find_width.end:
	
	#Finding Height
find_height.begin:
	lb $t7 ($t2)
	sub $t7 $t7 48
	move $t0 $t2 #t0 <- temporary pointer to buffer[i]
find_height.loopStart: 		#finding the total number by looping until -16 (whitespace) is reached
	addi $t0 $t0 1
	lb $t1 ($t0)			#t1<-buffer[t7+1]
	subi $t1 $t1 48 		#decrement by 48 to get the proper result
	bltz $t1 find_heigth.loopEnd	#if t1<0 exit
	mul $t7 $t7 10			#else adjust t7 by t7<-t7*10+t1
	add $t7 $t7 $t1
	j find_height.loopStart 	#return and loop for next number in sequence
find_heigth.loopEnd: 
	move $t2 $t0 		#Now set the pointer to t0+1
	addi $t2 $t2 1
	move $t4 $t7		#now t4<-height
find_height.end:
				
	#Finding MaxValue
find_maxValue.begin:
	lb $t7 ($t2)
	sub $t7 $t7 48
	move $t0 $t2 #t0 <- temporary pointer to buffer[i]
find_maxValue.loopStart: 		#finding the total number by looping until -16 (whitespace) is reached
	addi $t0 $t0 1
	lb $t1 ($t0)			#t1<-buffer[t7+1]
	subi $t1 $t1 48 		#decrement by 48 to get the proper result
	bltz $t1 find_maxValue.loopEnd	#if t1<0 exit
	mul $t7 $t7 10			#else adjust t7 by t7<-t7*10+t1
	add $t7 $t7 $t1
	j find_maxValue.loopStart 	#return and loop for next number in sequence
find_maxValue.loopEnd: 
	move $t2 $t0 		#Now set the pointer to t0+1
	addi $t2 $t2 1
	move $t5 $t7		#now t5<-maxValue
find_maxValue.end:
	
					#Creating Struct, t3<-width, t4<-height, t5<-maxValue
	#Finding space required = width*height+12 bytes (since each of width, height, maxValue requires a word of space)
	mul $a0 $t3 $t4
	addi $a0 $a0 12
	#asking for a0 space
	li $v0 9
	syscall
	#Adding height,width,maxValue
	move $t6 $v0 	#making a copy of v0 in t6
	sw $t3 ($t6)	#storing width in v0
	addi $t6 $t6 4	#increment t6 by 4
	sw $t4 ($t6)	#storing width in v0+4
	addi $t6 $t6 4	#increment t6 by 4
	sw $t5 ($t6)	#storing max in v0+8
	addi $t6 $t6 4	#increment t5 by 4
	
	#Populating the Array	
loop:	
	#Now populating the struct
	lb $t7 ($t2)
	sub $t7 $t7 48
	#Now, $t7 = contents of buffer[i]. 4 Cases
	#1) t7 = -16 -> whiteSpace
	#2) t7 = -38 -> newLine
	#3) t7 = -48 -> null. This is the last char in buffer
	#4) t7 is a number char
	
	beq $t7 -16 loop.case123 #case 1, goto loop.case16
	beq $t7 -38 loop.case123 #case 2, goto loop.case38
	beq $t7 -48 loop.case123 #case 3, goto loop.case48
	j loop.case4		#case 4, goto loop.case4
	
#Cases
loop.case123:	#case 1/2/3
	addi $t2 $t2 1 #increment the pointer
	j loop.final
loop.case4: 	#case 4
	li $t3 4 #set #t3=4 to designate this as case 4
	move $t0 $t2 #t0 <- temporary pointer to buffer[i]
loop.case4.begin: #finding the total number by looping until a negative number is reached
	addi $t0 $t0 1 	#t0<-pointer to buffer[t7+1]
	lb $t1 ($t0)	#t1<-buffer[t7+1]
	subi $t1 $t1 48 #decrement by 48 to get the proper result
	bltz $t1 loop.case4.end	#if t1<0 exit
	mul $t7 $t7 10			#else adjust t7 by t7<-t7*10+t1
	add $t7 $t7 $t1
	j loop.case4.begin #return and loop for next number in sequence
loop.case4.end: 
	move $t2 $t0 #Now set the pointer to t2
	
	#Now, t7 is the value in question, and t6 is the location in which is should be placed
	#t6*<-t7 then t6++
	sb $t7 ($t6)
	addi $t6 $t6 1
	
loop.final:
	bne $t7 -48 loop
	jr $ra
