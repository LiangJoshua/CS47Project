# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
.macro extract_nth_bit($regD, $regS, $regT)
	li	$regD, 1			#$regD = 1
	sllv  	$regD, $regD, $regT		#1 << regT (bit position)
	and 	$regD, $regS, $regD		#mask = $regS and mask
	srlv 	$regD, $regD, $regT		#mask = mask >> $regT(bit position) 
.end_macro


.macro insert_to_nth_bit ($regD, $regS, $regT, $maskReg)
	li	$maskReg, 1			#$maskReg = 1
	sllv  	$maskReg, $maskReg, $regS	#$maskReg = $maskReg << $regS(bit position)
	not 	$maskReg, $maskReg		#$maskReg = ~$maskReg(inverted)
	and 	$regD, $regD, $maskReg		#$regD = regD and $maskReg
	move	$maskReg, $regT			#$maskReg = $regT(bit to insert)
	sllv 	$maskReg, $maskReg, $regS	#$maskReg = $maskReg << regS(bit position)
	or 	$regD, $regD, $maskReg		#$regD = result and $maskReg 
.end_macro
