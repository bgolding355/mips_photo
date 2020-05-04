# Student ID = 260777610
####################################write Image#####################
.data
P2_magic_number: 	.asciiz "P2\n"
P5_magic_number: 	.asciiz "P5\n"
writeimage_whitespace:	.asciiz " "
writeimage_endl:	.asciiz "\n"
buffer:			.space	4
sRegister:		.space 8
.text
.globl write_image

write_image:
	# $a0 -> image struct
	# $a1 -> output filename
	# $a2 -> type (0 ->P5, 1->P2)
	################# returns #################
	# void
	
	#First, saving all of the s - registers in sRegister
	la $t0 sRegister
	sb $s0 ($t0)	#storing s0 in &t0
	addi $t0 $t0 1	#incrementing t0
	sb $s1 ($t0)	#continuing until all s registers are saved
	addi $t0 $t0 1
	sb $s2 ($t0)
	addi $t0 $t0 1
	sb $s3 ($t0)
	addi $t0 $t0 1
	sb $s4 ($t0)
	addi $t0 $t0 1
	sb $s5 ($t0)
	addi $t0 $t0 1
	sb $s6 ($t0)
	addi $t0 $t0 1
	sb $s7 ($t0)
	
	#Copying a0->t0, a1->t1, a2->t2
	move $t0 $a0
	move $t1 $a1
	move $t2 $a2
	move $t4 $ra #saving $ra so that we can jal within this file
	
	#Getting File Descriptor a1.pgm
	li $v0 13 # function 13 -> Read from file
	move $a0 $t1 #a0 <- output file
	li $a1 1 #Opening the file with "write" flag
	li $a2 0 #Setting mode = 0 (this is ignored)
	syscall #now v0 = file descriptor
	move $t3 $v0 #Save the file descriptor in t3
	
	#Calling write.P5 or write.P2 as required
	beq $t2 0 write_image.P5 #if (t2=0) j p5
	beq $t2 1 write_image.P2 #if (t2=1) j p2

write_image.P2: # t0 = image struct, t3 = file descriptor
	#Print "P2\n"
	li $v0 15 #15->write to file
	move $a0 $t3 #a0<-file descriptor
	la $a1 P2_magic_number #print P5/n
	li $a2 3 #size of "P5/n" = 3
	syscall
write_image.P5Rem:
	#Print "t0*" (Width)									
	li $v0 15
	lw $a0 ($t0)	#load int from t0	
	move $t1 $a0	#save width in t1
	#When code is complete, v0 -> string, v1 -> strlen, a0->int to be converted
	jal intToString
	move $a1 $v0	#a1<-output buffer
	move $a0 $t3 	#a0<-file descriptor
	move $a2 $v1	#a2<-size of string
	li $v0 15	#call for wtite to file
	syscall
	addi $t0 $t0 4 #increment pointer by 4
	
	# t0 = image struct, t3 = file descriptor, t4=ra, t1/t2 availible
	#Printing whitespace
	li $v0 15
	move $a0 $t3 			#a0<-file descriptor
	la $a1 writeimage_whitespace	#a1<-buffer address
	li $a2 1			#sizeof whitespace = 1
	syscall
	
	#Printing  "(t0+4)" (height + endl)
	li $v0 15
	lw $a0 ($t0)	#load int from t0
	move $t2 $a0	#saving height in t2
	#When code is complete, v0 -> string, v1 -> strlen, a0->int to be converted
	jal intToString
	move $a1 $v0	#a1<-output buffer
	move $a0 $t3 	#a0<-file descriptor
	move $a2 $v1	#a2<-size of string
	li $v0 15	#call for wtite to file
	syscall
	addi $t0 $t0 4 #increment pointer by 4
	
	#Printing '\n'
	li $v0 15
	move $a0 $t3
	la $a1 writeimage_endl
	li $a2 1	#sizeof endl = 1
	syscall
	
	#Printing (t0+8) (maxValue + endl)
	li $v0 15
	lw $a0 ($t0)	#load int from t0	
	#When code is complete, v0 -> string, v1 -> strlen, a0->int to be converted
	jal intToString
	move $a1 $v0	#a1<-output buffer
	move $a0 $t3 	#a0<-file descriptor
	move $a2 $v1	#a2<-size of string
	li $v0 15	#call for write to file
	syscall
	addi $t0 $t0 4 #increment pointer by 4
	
	#Printing '\n'
	li $v0 15
	move $a0 $t3
	la $a1 writeimage_endl
	li $a2 1	#sizeof endl = 1
	syscall
	
	#Printing body: Idea is to convert p0*->int then print it.
	#If (p*+i)%width == 0, then print endl
	#loop unitl #i<-width*height
	#print whitespace after each entry
	#t1 <- width, t2 <- height
	li $s3 0 #s3 <- i
	mul $s1 $t1 $t2	#s1 <- width * height
	move $s5 $s1	#copy size to s5
	
write_image.P2.loopBody:
	#Printing int at (t0* + i)
	li $v0 15
	lbu $a0 ($t0)	#load int from t0	
	jal intToString #When code is complete, v0 -> string, v1 -> strlen, a0->int to be converted
	move $a1 $v0	#a1<-output buffer
	move $a0 $t3 	#a0<-file descriptor
	move $a2 $v1	#a2<-size of string
	li $v0 15	#call for wtite to file
	syscall
	
	addi $t0 $t0 1 	#increment pointer by 1
	addi $s3 $s3 1 	#increment i by 1
	subi $s5 $s5 1	#decrement totalSize copy
	
	rem $s2 $s3 $t1 #If (i)%width == 0, then jump printNewLine
	beqz $s2 write_image.P2.loopBody.printNewLine
	#if a newline was not printed, print a space
	
	#Printing whitespace
	bne $a2 1 write_image.P2.loopBody.printSingle	#a2<-size of int
	li $v0 15
	move $a0 $t3 			#a0<-file descriptor
	la $a1 writeimage_whitespace	#a1<-buffer address
	li $a2 1			#sizeof whitespace = 1
	syscall
	
write_image.P2.loopBody.printSingle: #Print 1 or 2 whitespaces as required
	li $v0 15
	move $a0 $t3 			#a0<-file descriptor
	la $a1 writeimage_whitespace	#a1<-buffer address
	li $a2 1			#sizeof whitespace = 1
	syscall

	bgt $s5 1 write_image.P2.loopBody	#Branch if not on last
	j write_image.P2.loopBody.done		#Else jump to done
	
write_image.P2.loopBody.printNewLine:	
	li $v0 15
	move $a0 $t3
	la $a1 writeimage_endl
	li $a2 1 #sizeof endl = 1
	syscall
	j write_image.P2.loopBody


write_image.P2.loopBody.done:
	#print last bit
	li $v0 15
	addi $t0 $t0 1 	#increment pointer by 1
	lw $a0 ($t0)	#load int from t0
	jal intToString #When code is complete, v0 -> string, v1 -> strlen, a0->int to be converted
	move $a1 $v0	#a1<-output buffer
	move $a0 $t3 	#a0<-file descriptor
	move $a2 $v1	#a2<-size of string
	li $v0 15	#call for wtite to file
	syscall

	#Printing newline
	li $v0 15
	move $a0 $t3
	la $a1 writeimage_endl
	li $a2 1 #sizeof endl = 1
	syscall

	#Close the File
	li $v0 16
	move $a0 $t3 #t3 is file descriptor
	syscall
	
	#Now reseting all of the values into the s registers
	la $t0 sRegister
	lb $s0 ($t0)	#setting s0 to t0*
	addi $t0 $t0 1	#incrementing t0
	lb $s1 ($t0)	#continuing until all s registers are saved
	addi $t0 $t0 1
	lb $s2 ($t0)
	addi $t0 $t0 1
	lb $s3 ($t0)
	addi $t0 $t0 1
	lb $s4 ($t0)
	addi $t0 $t0 1
	lb $s5 ($t0)
	addi $t0 $t0 1
	lb $s6 ($t0)
	addi $t0 $t0 1
	lb $s7 ($t0)
	
	jr $t4	#origonal ra stored in t4

write_image.P5:
	#Print "P5\n"
	li $v0 15 #15->write to file
	move $a0 $t3 #a0<-file descriptor
	la $a1 P5_magic_number #print P5/n
	li $a2 3 #size of "P5/n" = 3
	syscall
	j write_image.P5Rem #Printing the rest in P2 system
	
	
#intToString takes an int ($a0) as input
#then returns a pointer to the string in question ($v0) as well as ints length ($v1)
intToString:
	move $t7 $a0	#making a copy of a0
	j findNumDigit
intToString.findDigit_done: #to preserve $ra
	move $v1 $v0	#v1<-numDigits
	#Setting v0<-buffer
	la $v0 buffer
	add $t5 $v0 $v1	#t5 <- pointer to last element in the array (will be decremented at the beginning of each loop
	#loading input into the array by repeatedly dividing by 10
	#t7<-initial number, t6 <- tempNumber, t5 <- pointer to be decremented, v0 original pointer
intToString.loop:
	subi $t5 $t5 1	#decrement t5
	rem $t6 $t7 10	#t6 <- t7 % 10
	addi $t6 $t6 48	#convert t6 to ascii by adding 48
	sb $t6 ($t5)	#Store t6 in &t5
	div $t7 $t7 10	#t7 <- t7 / 10
	bne $v0 $t5 intToString.loop	#continue until t5 = v0
	#now v0 <- pointer to the first digit, v1 <- number of digits
	jr $ra
#Takes a number a0 as input, then returns the number of digits. Ex a0 = 304 -> v0 = 3 
findNumDigit:
	li $v0 0	#t5<-numDigits
findNumDigit.loop:	#Loop until a0/10 == 0
	div $a0 $a0 10	#Divide a0 by 10 (integer division)
	addi $v0 $v0 1	#increment v0
	bne $a0 0 findNumDigit.loop #repeat until a0=0
	j intToString.findDigit_done
