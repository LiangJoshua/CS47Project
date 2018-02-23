.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
# TBD: Complete it
	addi	$sp, $sp, -24			#Framework Storage
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	li	$t0, '+'			#$t0 holds '+'
	li	$t1, '-'			#$t1 holds '-'
	li	$t2, '*'			#$t2 holds '*'
	li	$t3, '/'			#$t3 holds'/'
	
	beq	$a2, $t0, ADDITION 		#Goes to ADDITION if $t0
	beq	$a2, $t1, SUBTRACTION		#Goes to SUBTRACTION if $t1
	beq	$a2, $t2, MULTIPLICATION	#Goes to MULTIPLICATION if $t2
	beq	$a2, $t3, DIVISION		#Goes to DIVISION if $t3
	
	j	RETURN				#Jumps to RETURN
	
ADDITION:					#ADDITION
	jal	ADD_LOGICAL			#Calls ADD_LOGICAL procedure
	j	RETURN				#Jumps to RETURN

SUBTRACTION:					#SUBTRACTION
	jal	SUB_LOGICAL			#Calls SUB_LOGICAL procedure
	j	RETURN				#Jumps to RETURN

MULTIPLICATION:					#MULTIPLICATION
	jal	MUL_SIGNED			#Calls MUL_SIGNED procedure
	j	RETURN				#Jumps to RETURN

DIVISION:					#DIVISION
	jal	DIV_SIGNED			#Calls DIV_SIGNED procedure
	j	RETURN				#Jumps to RETURN

RETURN:						#RETURN
	lw	$fp, 24($sp)			#Framework Storage
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr	$ra
	
ADD_LOGICAL:					#ADD_LOGICAL
	addi	$sp, $sp, -24			#Framework Storage
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	or	$a2, $zero, 0		#$a2 mode is addition so it is set to 0
	
	jal	ADD_SUB_LOGICAL			#Calls ADD_SUB_LOGICAL
	j	RETURN				#Jumps to return

SUB_LOGICAL:					#SUB_LOGICAL
	addi	$sp, $sp, -24			#Framework Storage
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	or	$a2, $zero, 0	
	addi	$a2, $a2, 0xFFFFFFFF		#$a2 mode is subtraction so it's set to 1
	
	jal	ADD_SUB_LOGICAL			#Calls to ADD_SUB_LOGICAL
	j	RETURN				#Jumps to RETURN
	
ADD_SUB_LOGICAL:				#ADD_SUB_LOGICAL
	addi	$sp, $sp, -40			#Framework Storage
	sw	$fp, 40($sp)
	sw	$ra, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$a2, 24($sp)
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	addi	$fp, $sp, 40
	
	or	$t0, $zero, 0 			#i(index)
	or	$t1, $zero, 0 			#S(result of the operation)
	or	$t2, $zero, 0			#C
	extract_nth_bit($t2, $a2, $zero) 	#extracted bit taken from 0th position of $a2's bit pattern
	beq	$a2, 0, ADD_SUB_LOGICAL_1
	not	$a1, $a1			#invert number for subtraction
	
ADD_SUB_LOGICAL_1:				#ADD_SUB_LOGICAL_1
	beq	$t0, 32, ADD_SUB_LOGICAL_EXIT	#If index == 32, exit loop
	extract_nth_bit($t3, $a0, $t0) 		#t3 = Y = a0[i]
	extract_nth_bit($t4, $a1, $t0) 		#t4 = B = a1[i]
	xor	$s0, $t3, $t4			#$s0 = Y = xor the two bits
	xor	$s1, $t2, $s0			#$s1 = Y = xor between CI and Y($s4)
	and	$s2, $t3, $t4			#$s2 = c1 = A and B
	and	$s3, $t2, $s0			#$s3 = c2 = CI and (A xor B)
	or	$t2, $s2, $s3			#CI = c1 or c2	
	insert_to_nth_bit($v0, $t0, $s1, $t9)	#Insert $s1(Y) into ith bit of result
	addi	$t0, $t0, 1			#index++
	
	j	ADD_SUB_LOGICAL_1		#Jump to ADD_SUB_LOGICAL_1
	
ADD_SUB_LOGICAL_EXIT:				#ADD_SUB_LOGICAL_EXIT
	move	$v1, $t2			#Move carry out into $v1 
	
	lw	$fp, 40($sp)			#Framework Storage
	lw	$ra, 36($sp)
	lw	$a0, 32($sp)
	lw	$a1, 28($sp)
	lw	$a2, 24($sp)
	lw	$s0, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	addi	$sp, $sp, 40
	jr	$ra
	
TWOS_COMPLEMENT:				#TWOS_COMPLEMENT
	addi	$sp, $sp, -20			#Framework Storage
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 20
	
	not	$a0, $a0			#Invert $a0
	or	$a1, $zero, 0		
	or	$a1, 1			
	jal	ADD_LOGICAL			#Call ADD_LOGICAL
	
	lw	$fp, 20($sp)			#Framework Storage
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 20
	jr	$ra
	
TWOS_COMPLEMENT_IF_NEG:				#TWOS_COMPLEMENT_IF_NEG
	addi	$sp, $sp, -16			#Framework Storage
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	
	addi	$fp, $sp, 16
	move	$v0, $a0			#Move $a0 to $v0, if $a0 is negative
	bgt	$a0, 0, TWOS_COMPLEMENT_IF_NEG_EXIT	#If $a0 > 0, then exit. Or else use TWOS_COMPLEMENT to test if $a0 < 0
	jal	TWOS_COMPLEMENT	

TWOS_COMPLEMENT_IF_NEG_EXIT:			#TWOS_COMPLEMENT_IF_NEG_EXIT
	lw	$fp, 16($sp)			#Framework Storage
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra
	
TWOS_COMPLEMENT_64BIT:				#TWOS_COMPLEMENT_64BIT
	addi	$sp, $sp, -36			#Framework Storage
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$a2, 20($sp)
	sw	$s0, 16($sp)
	sw	$s1, 12($sp)
	sw	$s2, 8($sp)
	addi	$fp, $sp, 36
	
	not	$a0, $a0			#Invert $a0
	not	$a1, $a1			#Invert $a1
	move	$s0, $a1			
	or	$a1, $zero, 1
	jal	ADD_LOGICAL			#Calls ADD_LOGICAL
	move	$s1, $v0			#Move twos compliment of lo to $s1
	move	$s2, $v1			#Move carry bit to $s2
	move	$a0, $s0			#Move inverted hi into $a0
	move	$a1, $s2			#Move carry bit into $a1 
	jal	ADD_LOGICAL			#Calls ADD_LOGICAL	
	move	$v1, $v0			#Move twos compliment of hi to $v1
	move	$v0, $s1			#Move twos compliment of lo to $v0
	
	lw	$fp, 36($sp)			#Framework Storage
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$a2, 20($sp)
	lw	$s0, 16($sp)
	lw	$s1, 12($sp)
	lw	$s2, 8($sp)
	addi	$sp, $sp, 36
	jr	$ra
	
BIT_REPLICATOR:					#BIT_REPLICATOR:
	addi	$sp, $sp, -16			#Framework Storage
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi 	$fp, $sp, 16
	
	or	$v0, $a0, 0			#$v0 = 0x00000000
	beq	$a0, 0, BIT_REPLICATOR_EXIT	#If a0 = 0, exit
	li	$v0, 0xFFFFFFFF
	
BIT_REPLICATOR_EXIT:				#BIT_REPLICATOR_EXIT
	lw	$fp, 16($sp)			#Framework Storage
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi 	$sp, $sp, 16
	jr	$ra

MUL_UNSIGNED:					#MUL_UNSIGNED
	addi	$sp, $sp, -40			#Framework Storage
	sw	$fp, 40($sp)
	sw	$ra, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$a2, 24($sp)
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	addi	$fp, $sp, 40
	or	$t5, $zero, 0			#$t5 = index
	or	$t6, $zero, 0			#$t6 = H
	move	$s0, $a0			#Move M to $s0
	move	$s1, $a1			#Move L to $s1
	or	$s2, $zero, 0			#$s2 as R
	or	$s3, $zero, 0			#$s3 as X
	
MUL_UNSIGNED_1:					#MUL_UNSIGNED_1:
	beq	$t5, 32, MUL_UNSIGNED_EXIT	#If index = 32, exit
	extract_nth_bit($a0, $s0, $zero)	#Extract 0th bit of L and put into replicator
	jal	BIT_REPLICATOR			#Call BIT_REPLICATOR
	move	$s2, $v0			
	and	$s3, $s1, $s2			#$s3 = X = M and R
	move	$a0, $t6			#Move H to $a0
	move	$a1, $s3			#Move X to $a1 
	jal	ADD_LOGICAL			#Call ADD_LOGICAL
	move	$t6, $v0			#H += X
	srl	$s0, $s0, 1			#shift multipler right by 1 
	extract_nth_bit($t7, $t6, $zero)	#extract 0th position from prod into $t7
	li	$t8, 31
	insert_to_nth_bit ($s0, $t8, $t7, $t9)	#insert prod[0] into L[31]
	srl	$t6, $t6, 1			#shift prod right by 1 
	addi	$t5, $t5, 1			#index++
	j	MUL_UNSIGNED_1			#Jump to MUL_UNSIGNED_1
	
MUL_UNSIGNED_EXIT:				#MUL_UNSIGNED_EXIT
	move	$v0, $s0
	move	$v1, $t6
	
	lw	$fp, 40($sp)			#Framework Storage
	lw	$ra, 36($sp)
	lw	$a0, 32($sp)
	lw	$a1, 28($sp)
	lw	$a2, 24($sp)
	lw	$s0, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	addi	$sp, $sp, 40
	jr	$ra
	
MUL_SIGNED:					#MUL_SIGNED
	addi	$sp, $sp, -44			#Framework Storage
	sw	$fp, 44($sp)
	sw	$ra, 40($sp)
	sw	$a0, 36($sp)
	sw	$a1, 32($sp)
	sw	$a2, 28($sp)
	sw	$a3, 24($sp)
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	addi	$fp, $sp, 44
	
	move	$s0, $a0			#$s0 = $a0 = N1
	move	$a2, $a0			
	move	$s1, $a1			#$s1 = $a1 = N2
	move	$a3, $a1			
	jal	TWOS_COMPLEMENT_IF_NEG		#Call TWOS_COMPLEMENT_IF_NEG
	move	$s0, $v0			#Save TWOS_COMPLEMENT_IF_NEG of $a0
	move	$a0, $s1			#Save TWOS_COMPLEMENT_IF_NEG of $a1 or N1
	jal	TWOS_COMPLEMENT_IF_NEG		#Call TWOS_COMPLEMENT_IF_NEG
	move	$s1, $v0			#Save TWOS_COMPLEMENT_IF_NEG of $a1
	move	$a0, $s0			
	move	$a1, $s1			
	jal	MUL_UNSIGNED			#Call MUL_UNSIGNED
	move	$s0, $v0			#Move lo of result into $s0
	move	$s1, $v1			#Move hi of result into $s1
	li	$t8, 31
	extract_nth_bit($s2, $a2, $t8)		#extract sign bit of $a0[31]
	extract_nth_bit($s3, $a3, $t8)		#extract sign bit of $a1[31]
	xor	$t9, $s2, $s3			#$t9(sign bit) = a0[31]($s6) or $a1[31]($s7) 
	beq	$t9, 0, MUL_SIGNED_EXIT		#If positive, exit
	move	$a0, $s0			#Move $s0 to $a0 as argument for 64 bit conversion
	move	$a1, $s1			#Move $s1 to $a1 as argument for 64 bit conversion
	jal	TWOS_COMPLEMENT_64BIT		#Call TWOS_COMPLEMENT_64BIT
	
MUL_SIGNED_EXIT:				#MUL_SIGNED_EXIT
	lw	$fp, 44($sp)			#Framework Storage
	lw	$ra, 40($sp)
	lw	$a0, 36($sp)
	lw	$a1, 32($sp)
	lw	$a2, 28($sp)
	lw	$a3, 24($sp)
	lw	$s0, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	addi	$sp, $sp, 44
	jr	$ra

DIV_UNSIGNED:					#DIV_UNSIGNED
	addi	$sp, $sp, -40			#Framework Storage
	sw	$fp, 40($sp)
	sw	$ra, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$a2, 24($sp)
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	addi	$fp, $sp, 40
	or	$t5, $zero, 0			#$t5 = index
	or	$t6, $zero, 0			#$t6 = remainder
	move	$s0, $a0			#Save $a0(divident) in $s0
	move	$s1, $a1			#Save $a1(divisor) in $s1
	or	$s2, $zero, 0			#$s2 = S
	or	$s3, $zero, 0			
DIV_UNSIGNED_L1:				#DIV_UNSIGNED_LOOP
	beq	$t5, 32, DIV_UNSIGNED_EXIT	#If index = 32, exit
	sll	$t6, $t6, 1			#Shift $t6(remainder) to the left by 1
	li	$t8, 31
	extract_nth_bit($s3, $s0, $t8)		#Extract 31th bit of Q and save it into s7
	insert_to_nth_bit ($t6, $zero, $s3, $t9)#R[0] = Q[31]
	sll	$s0, $s0, 1			#Shift $s0(dividend) left by 1
	move	$a0, $t6			#Store R into $a0 
	move	$a1, $s1			#Store D into $a1 
	jal	SUB_LOGICAL			#Call SUB_LOGICAL
	move	$s2, $v0			#S = R - D
	bltz	$s2, DIV_UNSIGNED_L2		#If S is negative, go to DIV_UNSIGNED_L2. Or else, continue.
	move	$t6, $s2			#R = S
	li	$t8, 1
	insert_to_nth_bit($s0, $zero, $t8, $t9)	#Q[0] = 1
DIV_UNSIGNED_L2:
	addi	$t5, $t5, 1			#Index++
	j	DIV_UNSIGNED_L1			#Jump to DIV_UNSIGNED_L1
DIV_UNSIGNED_EXIT:				#DIV_UNSIGNED_EXIT
	move	$v0, $s0
	move	$v1, $t6
	
	lw	$fp, 40($sp)			#Framework Storage
	lw	$ra, 36($sp)
	lw	$a0, 32($sp)
	lw	$a1, 28($sp)
	lw	$a2, 24($sp)
	lw	$s0, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	addi	$sp, $sp, 40
	jr	$ra
	
DIV_SIGNED:					#DIV_SIGNED
	addi	$sp, $sp, -60			#Framework Storage
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw	$a2, 44($sp)
	sw	$a3, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 60
	
	move	$s0, $a0			#s0 = $a0(N1)
	move	$a2, $a0			#Move $a0 to $a2
	move	$s1, $a1			#s1 = $a1(N2)
	move	$a3, $a1			#Move $a1 to $a3
	jal	TWOS_COMPLEMENT_IF_NEG		#Call TWOS_COMPLEMENT_IF_NEG
	move	$s0, $v0			#Save TWOS_COMPLEMENT_IF_NEG of $a0 into $s0
	move	$a0, $s1			
	jal	TWOS_COMPLEMENT_IF_NEG		#Call TWOS_COMPLEMENT_IF_NEG
	move	$s1, $v0			#Save TWOS_COMPLEMENT_IF_NEG of $a1
	move	$a0, $s0			#Move $s0 into $a0 
	move	$a1, $s1			#Move $s1 into $a1 
	jal	DIV_UNSIGNED			#Call DIV_UNSIGNED
	move	$s0, $v0			#Move Q($v0) to $s4
	move	$s1, $v1			#Move R($v1) to $s5 
	
DETERMINE_Q:					#DETERMINE_Q
	li	$t8, 31
	extract_nth_bit($s2, $a2, $t8)		#Extract 31st bit of $a0 
	extract_nth_bit($s3, $a3, $t8)		#Extract 31st bit of $a1 
	xor	$s4, $s2, $s3			#R Sign = XOR of $a0[31] and $a1[31]
	move	$s5, $s0			
	beq	$s4, 0, DETERMINE_R		#If signed bit = 0, determine the sign of R
	move	$a0, $s5			#Move Q($s5) to $a0 
	jal	TWOS_COMPLEMENT			#Call TWOS_COMPLEMENT
	move	$s5, $v0			#Move TWOS_COMPLEMENT of Q into $s5
	
DETERMINE_R:
	li	$t8, 31
	extract_nth_bit($s4, $a2, $t8)		#Extract the 31st bit of $a0 into $s4
	move	$s6, $s1			
	beq	$s4, 0, DIV_SIGNED_EXIT		#If signed bit = 0, exit
	move	$a0, $s1			#Move R($s1) to $a0 
	jal	TWOS_COMPLEMENT			#Call TWOS_COMPLEMENT
	move	$s6, $v0			#Move TWOS_COMPLEMENT of R into $s6 

DIV_SIGNED_EXIT:				#DIV_SIGNED_EXIT
	move	$v0, $s5
	move	$v1, $s6
	
	lw	$fp, 60($sp)			#Framework Storage
	lw	$ra, 56($sp)
	lw	$a0, 52($sp)
	lw	$a1, 48($sp)
	lw	$a2, 44($sp)
	lw	$a3, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 60
	jr 	$ra

