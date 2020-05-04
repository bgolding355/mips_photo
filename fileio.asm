#Student ID = 260777610
############################ Q1: file-io########################
.data
			.align 2
inputTest1:		.asciiz "test1.txt"
			.align 2
inputTest2:		.asciiz "test2.txt"
			.align 2
outputFile:		.asciiz "copy.pgm"
			.align 2
buffer:			.space 1024
outputFileHeader:	.asciiz "P2\n24 7\n15\n"
.text
.globl fileio

fileio:
	
	la $a0,inputTest1
	la $a0,inputTest2
	jal read_file
	la $a0,outputFile
	jal write_file
	
	li $v0,10		# exit...
	syscall	
		

	
read_file:
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
	
	#Printing the result
	la $a0 buffer
	addi $v0 $zero 4 #4->print string
	syscall
	
	jr $ra
	
write_file:
	# $a0 -> outputFilename
	# open file for writing
	# write following contents:
	# P2
	# 24 7
	# 15
	# write out contents read into buffer
	# close file
	
	#Getting File Descriptor for copy.pgm
	addi $v0 $zero 13 # function 13 -> Read from file
	la $a0 outputFile #a0 <- output file
	li $a1 1 #Opening the file with "write" flag
	li $a2 0 #Setting mode=0 (this is ignored)
	syscall #now v0 = file descriptor
	addi $s3 $v0 0 #Save the file descriptor in s3
	
	#writing "P2\n24 7\n15\n" to copy.pgm
	li $v0 15 #15->write to file
	addi $a0 $s3 0 #a0<-file descriptor
	la $a1 outputFileHeader #a1<-input to write from
	li $a2 1024 #<-size of the buffer
	syscall
	
	#Appending the buffer result to copy.pgm
	li $v0 15 #15->write to file
	addi $a0 $s3 0 #a0<-file descriptor
	la $a1 buffer #a1<-input to write from
	li $a2 1024 #<-size of the buffer
	syscall
	
	#Closing the File
	li $v0 16
	addi $a0 $s3 0 #s3<-file descriptor for copy.pgm
	syscall
	
	jr $ra
		  	  
