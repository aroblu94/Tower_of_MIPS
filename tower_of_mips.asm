.data
	str0: .asciiz "Insert number of disks: "
	str1: .asciiz "Starting peg (0: left, 1: middle, 2: right): "
	str2: .asciiz "Arrival's peg (0: left, 1: middle, 2: right): "
	str3: .asciiz "Moves: "
	arrow: .asciiz " --> "
	endl: .asciiz "\n"
	nodisk: .asciiz "No disk, no party!\n"
	samepeg: .asciiz "Arrival's peg is the same as starting one. No moves.\n"

.text
	main:
		li $v0, 4							# select print_string
		la $a0, str0						# $a0 contains the address of "str0"
		syscall								# start print_string
		# read "n" from keyboard
		# don't same "n" in $a0 yet,
		# because this register is
		# already used in following 
		# syscall
		li $v0, 5							# select read_int
		syscall								# start read_int
		add $t0, $zero, $v0					# save "n" in $t0

		beq $t0, $zero, no_disk				# se n == 0 salto a "no_disk"

		li $v0, 4							# select print_string
		la $a0, str1						# $a0 contains the address of "str1"
		syscall								# start print_string
		# read "from" from keyboard
		li $v0, 5							# select read_int
		syscall								# start read_int
		add $a1, $zero, $v0					# save "from" in $a1
		
		li $v0, 4							# select print_string
		la $a0, str2						# $a0 contains the address of "str2"
		syscall								# start print_string
		# read "to" from keyboard
		li $v0, 5							# select read_int
		syscall								# start read_int
		add $a3, $zero, $v0					# save "to" in $a3
		
		beq $a1, $a3, same_peg				# if "from" == "to" jump to "same_peg"
		
		# choosing "temp" according to
		# user-selected pegs
		# uses $t1 and $t2 for comparisons
		addi $t1, $zero, 1					# $t1 = 1
		addi $t2, $zero, 2					# $t2 = 2
		
		beq $a1, $zero, from_zero			# if "from" == 0 jump to "from_zero"
		beq $a1, $t1, from_one				# if "from" == 1 jump to "from_uno"
		
		# if previous checks fails
		# ==> "from" == 2
		
		beq $a3, $zero, temp_one			# if "from" == 2 and "to" == 0 jump to "temp_uno"
		
		# if previous checks fails
		# ==> "from" == 2 and "to" == 1
		# ==> "temp" == 0
		
	temp_zero:
		add $a2, $zero, $zero				# "temp" == 0
		j call_hanoi						# skip subsequent checks
	
	temp_one:
		add	$a2, $t1, $zero					# "temp" == 1
		j call_hanoi						# skip subsequent checks
		
	temp_two:
		add $a2, $t2, $zero					# "temp" == 2
		j call_hanoi						# skip subsequent checks
		
	from_zero:
		beq $a3, $t1, temp_two				# if "from" == 0 and "to" == 1 jump to "temp_two"
		beq $a3, $t2, temp_one				# if "from" == 0 and "to" == 2 jump to "temp_one"
		
	from_one:
		beq $a3, $zero, temp_two			# if "from" == 1 and "to" == 0 jump to "temp_two"
		beq $a3, $t2, temp_zero				# if "from" == 1 and "to" == 2 jump to "temp_zero"
		
	call_hanoi:
		add $a0, $t0, $zero					# copy "n" in $a0 for the call
		jal hanoi							# hanoi(n, from, temp, to)
		
		# printing "Moves: XX"
		li $v0, 4							# select print_string
		la $a0, str3						# $a0 contains the address of "str3"
		syscall								# start print_string
		li $v0, 1							# select print_int
		add $a0, $zero, $s4					# load moves counter in $a0
		syscall								# start print_int
		li $v0, 4							# select print_string
		la $a0, endl						# $a0 contains the address of "endl"
		syscall								# start print_string

	exit:
		li $v0, 10							# select exit
		syscall								# start exit syscall

	hanoi:
		# INPUT:
		# $a0 "n"
		# $a1 "from"
		# $a2 "temp"
		# $a3 "to"

		addi $sp, $sp, -20					# dec sp (5 words)
		sw $ra, 16($sp)						# push $ra
		sw $s0, 12($sp)						# push $s0 (from)
		sw $s1, 8($sp)						# push $s1 (temp)
		sw $s2, 4($sp)						# push $s2 (to)
		sw $s3, 0($sp)						# push $s3 (n)

		beq $a0, $zero, zero			# se n == 0 salto a "zero"

		addi $sp, $sp, -16					# dec sp (4 words)
		sw $a0, 12($sp)						# push "n" ($a0)
		sw $a1, 8($sp)						# push "from" ($a1)
		sw $a2, 4($sp)						# push "temp" ($a2)
		sw $a3, 0($sp)						# push "to" ($a3)

		# prepare data for  
		# the next call:
		addi $a0, $a0, -1   				# n = n - 1
		add	$t0, $zero, $a2					# temporarily save $a2 in $t0
		add	$a2, $zero, $a3					# swap "temp" ($a2) and "to" ($a3) using $t0
		add	$a3, $zero, $t0	

		jal hanoi							# hanoi(n-1, from, to, temp)

		lw $s2, 0($sp)						# pop "to" in $s2
		lw $s1, 4($sp)						# pop "temp" in $s1
		lw $s0, 8($sp)						# pop "from" in $s0
		lw $s3, 12($sp)						# pop "n" in $s3
		addi $sp, $sp, 16					# inc sp (4 words)

		addi $s4, $s4, 1					# counter = counter + 1

		# print move:
		li $v0, 1							# select print_int
		add $a0, $zero, $s0					# load "from" in $a0
		syscall								# start print_int
		li $v0, 4							# select print_string
		la $a0, arrow						# $a0 contains the address of "arrow"
		syscall								# start print_string
		li $v0, 1							# select print_int
		add $a0, $zero, $s2					# load "to" in $a0
		syscall								# start print_int
		li $v0, 4							# select print_string
		la $a0, endl						# $a0 contains the address of "endl"
		syscall								# start print_string

		# prepare data for
		# the next call:
		addi $a0, $s3, -1       			# n = n - 1
		add $a1, $zero, $s1					# save "temp" in $a1
		add $a2, $zero, $s0					# save "from" in $a2
		add $a3, $zero, $s2					# save "to" in $a3
		
		jal hanoi							# hanoi(n-1, temp, from, to)

	zero:
		lw $s3, 0($sp)						# pop $s3
		lw $s2, 4($sp)						# pop $s2
		lw $s1, 8($sp)						# pop $s1
		lw $s0, 12($sp)						# pop $s0
		lw $ra, 16($sp)						# pop $ra
		addi $sp, $sp, 20					# inc sp (5 words)

		jr $ra								# go back to caller + 4

	no_disk:
		li $v0, 4							# select print_string
		la $a0, nodisk						# $a0 contains the address of "nodisk"
		syscall								# start print_string

		j exit								# jump to "exit"

	same_peg:
		li $v0, 4							# select print_string
		la $a0, samepeg						# $a0 contains the address of "samepeg"
		syscall								# start print_string
		
		j exit								# jump to "exit"



