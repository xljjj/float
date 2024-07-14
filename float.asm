.data  #数据字段

	#第1个数，第2个数和运算结果 0-4浮点表示 4-8符号位 8-12指数带偏移 12-16尾数
	num1: .space 16
	num2: .space 16
	res: .space 16
	
	msg1: .ascii "\nHello! Choose one: 1.add 2.sub 3.mul 4.div 0.exit\n\0"  #加法、减法、乘法、除法、退出
	msg2: .ascii "\nPlease input the first floating number:\n\0"  #输入第一个浮点数
	msg3: .ascii "\nPlease input the second floating number:\n\0"  #输入第二个浮点数
	msg4: .ascii "\nThe binary result is:\n\0"  #二进制结果
	msg5: .ascii "\nThe decimal result is:\n\0"  #十进制结果
	msg6: .ascii "\nThe hexadecimal result is:\n\0"  #十六进制结果
	msg7: .ascii "\nError: The divisor can't be zero!\n\0"  #除数不能为0
	msg8: .ascii "\nPlease input number from 0 to 4!\n\0"  #输入要求
	msg9: .ascii "\nThanks for using!\n\0"  #结束
	
.text
.globl main
main:  #主函数

	#存储数组的地址
	la $s5, num1  
	la $s6, num2
	la $s7, res
	#清空结果
	sw $0, 0($s7)
	sw $0, 4($s7)
	sw $0, 8($s7)
	sw $0, 12($s7)

	la $a0, msg1
	li $v0, 4  #输出欢迎语
	syscall 
	li $v0, 5  #读取输入值并存入$v0
	syscall
	
	li $t0, 1
	beq $t0, $v0, add_func  #加法操作
	li $t0, 2
	beq $t0, $v0, sub_func  #减法操作
	li $t0, 3
	beq $t0, $v0, mul_func  #乘法操作
	li $t0, 4
	beq $t0, $v0, div_func  #除法操作
	li $t0, 0
	beq $t0, $v0, exit  #退出
	bne $t0, $v0, wrong_choice  #错误选择
	
exit:
	la $a0, msg9
	li $v0, 4
	syscall  #结束语
	li $v0, 10
	syscall  #退出
	
wrong_choice:
	la $a0, msg8
	li $v0, 4
	syscall  #报错
	j main  #重新输入

##############################################################
add_func:
	jal input_first
	jal input_second

help_sub:
	#只要有一个数为0，则直接输出另一个
	lw $t0, 8($s5)
	beq $t0, 0, first_zero
	lw $t0, 8($s6)
	beq $t0, 0, second_zero
	#判断是否同号
	lw $t1, 4($s5)
	lw $t2, 4($s6)
	beq $t1, $t2, add_same_process
	jal sub_cal
	j add_done
add_same_process:
	sw $t1, 4($s7)
	jal add_cal
	j add_done
first_zero:  #结果为第二个数
	lw $t1, 4($s6)
	lw $t2, 8($s6)
	lw $t3, 12($s6)
	sw $t1, 4($s7)
	sw $t2, 8($s7)
	sw $t3, 12($s7)
	j add_done
second_zero:  #结果为第一个数
	lw $t1, 4($s5)
	lw $t2, 8($s5)
	lw $t3, 12($s5)
	sw $t1, 4($s7)
	sw $t2, 8($s7)
	sw $t3, 12($s7)
add_done:
	jal result_join
	jal output_decimal
	jal output_binary
	jal output_hexadecimal
	j main

##############################################################
sub_func:
	jal input_first
	jal input_second
	#将第二个数的符号取反，用加法处理
	lw $t0, 4($s6)
	xor $t0,$t0, 1
	sw $t0, 4($s6)
	j help_sub

##############################################################
mul_func:
	jal input_first
	jal input_second
	#若其中一个数为0，则不必进行
	lw $t0, 8($s5)
	beq $t0, 0, mul_done
	lw $t0, 8($s6)
	beq $t0, 0, mul_done
	jal mul_div_sign
	jal mul_cal
mul_done:
	jal result_join
	jal output_decimal
	jal output_binary
	jal output_hexadecimal
	j main

##############################################################
div_func:
	jal input_first
divisor_check:
	jal input_second
	lw $t0, 8($s6)
	bne $t0, 0, div_allow  #检查除数是否为0
	la $a0, msg7  #报错
	li $v0, 4
	syscall
	j divisor_check
div_allow:
	#若被除数为0，则不必进行
	lw $t0, 8($s5)
	beq $t0, 0, div_done
	jal mul_div_sign
	jal div_cal
div_done:
	jal result_join
	jal output_decimal
	jal output_binary
	jal output_hexadecimal
	j main

##############################################################
input_first:
	la $a0, msg2  #提示输入
	li $v0, 4
	syscall
	
	li $v0, 6  #读取浮点是存入$f0
	syscall
	mfc1 $t0, $f0  #存入$t0
	sw $t0, 0($s5)  #存入数组
	
	andi $t1,$t0,0x80000000    
  	srl  $t1,$t1,31  #得到符号位
  	sw   $t1,4($s5)  
  	andi $t1,$t0,0x7f800000    
  	srl  $t2,$t1,23  #得到指数位
  	sw   $t2,8($s5) 
  	andi  $t1,$t0,0x007fffff  #得到尾数位
  	sw    $t1,12($s5)                           
	
	jr $ra

input_second:
	la $a0, msg3  #提示输入
	li $v0, 4
	syscall
	
	li $v0, 6  #读取浮点是存入$f0
	syscall
	mfc1 $t0, $f0  #存入$t0
	sw $t0, 0($s6)  #存入数组
	
	andi $t1,$t0,0x80000000    
  	srl  $t1,$t1,31  #得到符号位
  	sw   $t1,4($s6)  
  	andi $t1,$t0,0x7f800000    
  	srl  $t2,$t1,23  #得到指数位
  	sw   $t2,8($s6) 
  	andi  $t1,$t0,0x007fffff  #得到尾数位
  	sw    $t1,12($s6)                         
	
	jr $ra

##############################################################
#打印十进制形式
output_decimal:
	la $a0, msg5
	li $v0, 4
	syscall
	lw $t0, 0($s7)
	mtc1 $t0, $f12
	li $v0, 2
	syscall
	jr $ra

#打印二进制形式
output_binary:
	la $a0, msg4
	li $v0, 4
	syscall
	lw $t0, 0($s7)  #取出结果的浮点数表示
	li $t1, 32  #循环次数
	li $t2, 0  #当前为0/1
	addi $t3, $0, 0x80000000  #用于取出每一位
	
binary_loop:
	addi $t1, $t1, -1
	and $t2, $t0, $t3
	srl $t3, $t3, 1
	srlv $t2, $t2, $t1
	addi $a0, $t2, 0
	li $v0, 1  #打印每1位
	syscall
	beq $t1, $0, binary_end
	j binary_loop
	
binary_end:
	jr $ra

#打印十六进制形式
output_hexadecimal:
	la $a0, msg6
	li $v0, 4
	syscall
	lw $t0, 0($s7)  #取出结果的浮点数表示
	li $t1, 8  #循环次数
	li $t2, 0  #当前为0-E
hex_loop:
	beq $t1, $0, hexadecimal_end
	addi $t1, $t1, -1
	srl $t2, $t0, 28  #取4位
	sll $t0, $t0, 4  #左移4位
	bgt $t2, 9, output_char
	li $v0,1  #输出一个十六进制数
   	add $a0,$t2,$zero
   	syscall
   	j hex_loop
	
output_char:
	addi $t2,$t2,55  #求字符码
  	li 	$v0,11
  	add	$a0,$t2,$zero
  	syscall
  	j hex_loop
	
hexadecimal_end:
	jr $ra
	
##############################################################
result_join:
	li $t0, 0  #浮点表示
	lw $t1, 4($s7)  #符号位
	sll $t1, $t1, 31
	lw $t2, 8($s7)  #指数已加偏置值
	sll $t2, $t2, 23
	lw $t3, 12($s7)  #尾数
	or $t0, $t0, $t1
	or $t0, $t0, $t2
	or $t0, $t0, $t3
	sw $t0, 0($s7)
	jr $ra
	
##############################################################
mul_div_sign:
	li $t0, 0 #结果符号位
	lw $t1, 4($s5)  #第一个数符号位
	lw $t2, 4($s6)  #第二个数符号位
	xor $t0, $t1, $t2
	sw $t0, 4($s7)
	jr $ra

mul_cal:
	lw $t1, 12($s5)  #第一个数尾数
	lw $t2, 12($s6)  #第二个数尾数
	li $t0, 0x00800000
	or $t1, $t1, $t0 #加上隐含1
	or $t2, $t2, $t0 #加上隐含1
	lw $t3, 8($s5)  #第一个数指数有偏置
	lw $t4, 8($s6)  #第二个数指数有偏置
	add $t5, $t3, $t4  #指数初步相加结果
	subi $t5, $t5, 127  #减去多算的偏置值
	mult $t1, $t2
	mfhi $t1  #结果高32位
	mflo $t2  #结果低32位
	srl $t3, $t1, 15
	andi $t3, $t3, 0x00000001  #判断总第48位是否为1，若是1需将小数点左移
	beq $t3, 0, mul_wei_cal
	addi $t5, $t5, 1
	srl $t2, $t2, 1
	andi $t3, $t3, 0x00000001  #取出总第33位
	sll $t3, $t3, 31
	or $t2, $t2, $t3
	srl $t1, $t1, 1
mul_wei_cal:
	srl $t2, $t2, 23  #取9位
	andi $t1, $t1, 0x000003fff  #取14位
	sll $t1, $t1, 9
	addi $s1, $t5, 0  #指数
	or $s2, $t1, $t2  #尾数
	#要求s1为结果的指数，s2为结果的尾数
	li $t6, 1
	li $t7, 254
	slt $t1, $s1, $t6  #如果指数小于1，认为是0
	beq $t1, 1, mul_zhi_small
	slt $t2, $t7, $s1  #如果指数大于254，认为是无穷大
	beq $t2, 1, mul_zhi_big
	j mul_check_final
mul_zhi_small:
	li $s1, 0
	li $s2, 0
	j mul_check_final
mul_zhi_big:
	li $s1, 255
	li $s2, 0
mul_check_final:
	sw $s1, 8($s7)
	sw $s2, 12($s7)
	jr $ra
	
##############################################################
div_cal:
	#在此函数中要求两个是正数，第一个（3指数，4尾数），第二个（5指数，6尾数），结果（1指数，2尾数）
	lw $t3, 8($s5)
	lw $t4, 12($s5)
	lw $t5, 8($s6)
	lw $t6, 12($s6)
	li $t0, 0x00800000
	or $t4, $t4, $t0 #加上隐含1
	or $t6, $t6, $t0 #加上隐含1
	sub $s1, $t3, $t5
	addi $s1, $s1, 127  #结果指数初步结果
	li $s2, 0  #存除法结果
	li $t7, 24  #循环次数
	li $t1, 0  #当前上的位值
div_loop:
	beq $t7, 0, div_loop_end
	subi $t7, $t7, 1
	slt $t0, $t4, $t6
	beq $t0, 1, div_loop_zero
	sub $t4, $t4, $t6
	li $t1, 1
	j div_loop_continue
div_loop_zero:
	li $t1, 0
div_loop_continue:
	sll $s2, $s2, 1
	or $s2, $s2, $t1
	sll $t4, $t4, 1
	j div_loop
div_loop_end:
	#如果第24位为0，向指数借1位
	srl $t1, $s2, 23
	andi $t1, $t1, 1
	beq $t1, 0, borrow
	j div_check
borrow:
	sll $s2, $s2, 1
	subi $s1, $s1, 1
div_check:
	#尾数取后23位
	li $t1, 0x007fffff
	and $s2, $s2, $t1
	#要求s1为结果的指数，s2为结果的尾数
	li $t6, 1
	li $t7, 254
	slt $t1, $s1, $t6  #如果指数小于1，认为是0
	beq $t1, 1, div_zhi_too_small
	slt $t2, $t7, $s1  #如果指数大于254，认为是无穷大
	beq $t2, 1, div_zhi_too_big
	j div_check_final
div_zhi_too_small:
	li $s1, 0
	li $s2, 0
	j div_check_final
div_zhi_too_big:
	li $s1, 255
	li $s2, 0
div_check_final:
	sw $s1, 8($s7)
	sw $s2, 12($s7)
	jr $ra
	
##############################################################
add_cal:
	#在此函数中要求两个是正数，第一个（3指数，4尾数），第二个（5指数，6尾数），结果（1指数，2尾数）
	lw $t3, 8($s5)
	lw $t4, 12($s5)
	lw $t5, 8($s6)
	lw $t6, 12($s6)
	li $t0, 0x00800000
	or $t4, $t4, $t0 #加上隐含1
	or $t6, $t6, $t0 #加上隐含1
	#指数对齐
	slt $t0, $t3, $t5
	beq $t0, 1, add_zhi_small
	slt $t0, $t5, $t3
	beq $t0, 1, add_zhi_big
	j add_wei_cal
add_zhi_small:  #第一个数的指数小于第二个
	sub $t7, $t5, $t3  #相差位数
	add $t3, $t3, $t7
	srlv $t4, $t4, $t7 
	j add_wei_cal
add_zhi_big:  #第一个数的指数大于第二个
	sub $t7, $t3, $t5  #相差位数
	add $t5, $t5, $t7
	srlv $t6, $t6, $t7
add_wei_cal:  #尾数计算
	addi $s1, $t3, 0
	add $t2, $t4, $t6
	#判断第25位是否为1，若是则指数+1
	srl $t0, $t2, 24
	andi $t0, $t0, 1
	beq $t0, 1, add_zhi_plus
	j add_final
add_zhi_plus:
	addi $s1, $s1, 1
	srl $t2, $t2, 1
add_final:
	#尾数取后23位
	li $t0, 0x007fffff
	and $s2, $t2, $t0
	#要求s1为结果的指数，s2为结果的尾数
	li $t6, 1
	li $t7, 254
	slt $t1, $s1, $t6  #如果指数小于1，认为是0
	beq $t1, 1, add_zhi_too_small
	slt $t2, $t7, $s1  #如果指数大于254，认为是无穷大
	beq $t2, 1, add_zhi_too_big
	j add_check_final
add_zhi_too_small:
	li $s1, 0
	li $s2, 0
	j add_check_final
add_zhi_too_big:
	li $s1, 255
	li $s2, 0
add_check_final:
	sw $s1, 8($s7)
	sw $s2, 12($s7)
	jr $ra
	
##############################################################
sub_cal:
	#在此函数中要求两个是正数，第一个（3指数，4尾数），第二个（5指数，6尾数），结果（1指数，2尾数）
	lw $t1, 4($s5)
	lw $t2, 4($s6)
	beq $t1, 0, first_pos
	lw $t3, 8($s6)
	lw $t4, 12($s6)
	lw $t5, 8($s5)
	lw $t6, 12($s5)
	j sub_start
first_pos:
	lw $t3, 8($s5)
	lw $t4, 12($s5)
	lw $t5, 8($s6)
	lw $t6, 12($s6)
sub_start:
	li $t0, 0x00800000
	or $t4, $t4, $t0 #加上隐含1
	or $t6, $t6, $t0 #加上隐含1
	#指数对齐
	slt $t0, $t3, $t5
	beq $t0, 1, sub_zhi_small
	slt $t0, $t5, $t3
	beq $t0, 1, sub_zhi_big
	j sub_wei_cal
sub_zhi_small:  #第一个数的指数小于第二个
	sub $t7, $t5, $t3  #相差位数
	add $t3, $t3, $t7
	srlv $t4, $t4, $t7 
	j sub_wei_cal
sub_zhi_big:  #第一个数的指数大于第二个
	sub $t7, $t3, $t5  #相差位数
	add $t5, $t5, $t7
	srlv $t6, $t6, $t7
sub_wei_cal:  #尾数计算
	addi $s1, $t3, 0
	#要求尾数大减小
	slt $t0, $t4, $t6
	beq $t0, 1, res_neg
	li $t0, 0
	sw $t0, 4($s7)
	j sub_wei_continue
res_neg:
	li $t0, 1
	sw $t0, 4($s7)
	#t4 t6互换
	addi $t0, $t4, 0
	addi $t4, $t6, 0
	addi $t6, $t0, 0
sub_wei_continue:
	sub $s2, $t4, $t6  #相减结果，如果为0特殊处理
	beq $s2,0, zero_process
	#只要第24位为0，向指数借1位，同时尾数左移
sub_loop:
	srl $t7, $s2, 23
	andi $t0, $t7, 1
	beq $t0, 1, sub_check
	sll $s2, $s2, 1
	subi $s1, $s1, 1
	j sub_loop
zero_process:
	li $s1, 0
	li $s2, 0
	j sub_check_final
sub_check:
	#尾数取后23位
	li $t1, 0x007fffff
	and $s2, $s2, $t1
	#要求s1为结果的指数，s2为结果的尾数
	li $t6, 1
	li $t7, 254
	slt $t1, $s1, $t6  #如果指数小于1，认为是0
	beq $t1, 1, sub_zhi_too_small
	slt $t2, $t7, $s1  #如果指数大于254，认为是无穷大
	beq $t2, 1, sub_zhi_too_big
	j sub_check_final
sub_zhi_too_small:
	li $s1, 0
	li $s2, 0
	j sub_check_final
sub_zhi_too_big:
	li $s1, 255
	li $s2, 0
sub_check_final:
	sw $s1, 8($s7)
	sw $s2, 12($s7)
	jr $ra	
