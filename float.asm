.data  #�����ֶ�

	#��1��������2������������ 0-4�����ʾ 4-8����λ 8-12ָ����ƫ�� 12-16β��
	num1: .space 16
	num2: .space 16
	res: .space 16
	
	msg1: .ascii "\nHello! Choose one: 1.add 2.sub 3.mul 4.div 0.exit\n\0"  #�ӷ����������˷����������˳�
	msg2: .ascii "\nPlease input the first floating number:\n\0"  #�����һ��������
	msg3: .ascii "\nPlease input the second floating number:\n\0"  #����ڶ���������
	msg4: .ascii "\nThe binary result is:\n\0"  #�����ƽ��
	msg5: .ascii "\nThe decimal result is:\n\0"  #ʮ���ƽ��
	msg6: .ascii "\nThe hexadecimal result is:\n\0"  #ʮ�����ƽ��
	msg7: .ascii "\nError: The divisor can't be zero!\n\0"  #��������Ϊ0
	msg8: .ascii "\nPlease input number from 0 to 4!\n\0"  #����Ҫ��
	msg9: .ascii "\nThanks for using!\n\0"  #����
	
.text
.globl main
main:  #������

	#�洢����ĵ�ַ
	la $s5, num1  
	la $s6, num2
	la $s7, res
	#��ս��
	sw $0, 0($s7)
	sw $0, 4($s7)
	sw $0, 8($s7)
	sw $0, 12($s7)

	la $a0, msg1
	li $v0, 4  #�����ӭ��
	syscall 
	li $v0, 5  #��ȡ����ֵ������$v0
	syscall
	
	li $t0, 1
	beq $t0, $v0, add_func  #�ӷ�����
	li $t0, 2
	beq $t0, $v0, sub_func  #��������
	li $t0, 3
	beq $t0, $v0, mul_func  #�˷�����
	li $t0, 4
	beq $t0, $v0, div_func  #��������
	li $t0, 0
	beq $t0, $v0, exit  #�˳�
	bne $t0, $v0, wrong_choice  #����ѡ��
	
exit:
	la $a0, msg9
	li $v0, 4
	syscall  #������
	li $v0, 10
	syscall  #�˳�
	
wrong_choice:
	la $a0, msg8
	li $v0, 4
	syscall  #����
	j main  #��������

##############################################################
add_func:
	jal input_first
	jal input_second

help_sub:
	#ֻҪ��һ����Ϊ0����ֱ�������һ��
	lw $t0, 8($s5)
	beq $t0, 0, first_zero
	lw $t0, 8($s6)
	beq $t0, 0, second_zero
	#�ж��Ƿ�ͬ��
	lw $t1, 4($s5)
	lw $t2, 4($s6)
	beq $t1, $t2, add_same_process
	jal sub_cal
	j add_done
add_same_process:
	sw $t1, 4($s7)
	jal add_cal
	j add_done
first_zero:  #���Ϊ�ڶ�����
	lw $t1, 4($s6)
	lw $t2, 8($s6)
	lw $t3, 12($s6)
	sw $t1, 4($s7)
	sw $t2, 8($s7)
	sw $t3, 12($s7)
	j add_done
second_zero:  #���Ϊ��һ����
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
	#���ڶ������ķ���ȡ�����üӷ�����
	lw $t0, 4($s6)
	xor $t0,$t0, 1
	sw $t0, 4($s6)
	j help_sub

##############################################################
mul_func:
	jal input_first
	jal input_second
	#������һ����Ϊ0���򲻱ؽ���
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
	bne $t0, 0, div_allow  #�������Ƿ�Ϊ0
	la $a0, msg7  #����
	li $v0, 4
	syscall
	j divisor_check
div_allow:
	#��������Ϊ0���򲻱ؽ���
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
	la $a0, msg2  #��ʾ����
	li $v0, 4
	syscall
	
	li $v0, 6  #��ȡ�����Ǵ���$f0
	syscall
	mfc1 $t0, $f0  #����$t0
	sw $t0, 0($s5)  #��������
	
	andi $t1,$t0,0x80000000    
  	srl  $t1,$t1,31  #�õ�����λ
  	sw   $t1,4($s5)  
  	andi $t1,$t0,0x7f800000    
  	srl  $t2,$t1,23  #�õ�ָ��λ
  	sw   $t2,8($s5) 
  	andi  $t1,$t0,0x007fffff  #�õ�β��λ
  	sw    $t1,12($s5)                           
	
	jr $ra

input_second:
	la $a0, msg3  #��ʾ����
	li $v0, 4
	syscall
	
	li $v0, 6  #��ȡ�����Ǵ���$f0
	syscall
	mfc1 $t0, $f0  #����$t0
	sw $t0, 0($s6)  #��������
	
	andi $t1,$t0,0x80000000    
  	srl  $t1,$t1,31  #�õ�����λ
  	sw   $t1,4($s6)  
  	andi $t1,$t0,0x7f800000    
  	srl  $t2,$t1,23  #�õ�ָ��λ
  	sw   $t2,8($s6) 
  	andi  $t1,$t0,0x007fffff  #�õ�β��λ
  	sw    $t1,12($s6)                         
	
	jr $ra

##############################################################
#��ӡʮ������ʽ
output_decimal:
	la $a0, msg5
	li $v0, 4
	syscall
	lw $t0, 0($s7)
	mtc1 $t0, $f12
	li $v0, 2
	syscall
	jr $ra

#��ӡ��������ʽ
output_binary:
	la $a0, msg4
	li $v0, 4
	syscall
	lw $t0, 0($s7)  #ȡ������ĸ�������ʾ
	li $t1, 32  #ѭ������
	li $t2, 0  #��ǰΪ0/1
	addi $t3, $0, 0x80000000  #����ȡ��ÿһλ
	
binary_loop:
	addi $t1, $t1, -1
	and $t2, $t0, $t3
	srl $t3, $t3, 1
	srlv $t2, $t2, $t1
	addi $a0, $t2, 0
	li $v0, 1  #��ӡÿ1λ
	syscall
	beq $t1, $0, binary_end
	j binary_loop
	
binary_end:
	jr $ra

#��ӡʮ��������ʽ
output_hexadecimal:
	la $a0, msg6
	li $v0, 4
	syscall
	lw $t0, 0($s7)  #ȡ������ĸ�������ʾ
	li $t1, 8  #ѭ������
	li $t2, 0  #��ǰΪ0-E
hex_loop:
	beq $t1, $0, hexadecimal_end
	addi $t1, $t1, -1
	srl $t2, $t0, 28  #ȡ4λ
	sll $t0, $t0, 4  #����4λ
	bgt $t2, 9, output_char
	li $v0,1  #���һ��ʮ��������
   	add $a0,$t2,$zero
   	syscall
   	j hex_loop
	
output_char:
	addi $t2,$t2,55  #���ַ���
  	li 	$v0,11
  	add	$a0,$t2,$zero
  	syscall
  	j hex_loop
	
hexadecimal_end:
	jr $ra
	
##############################################################
result_join:
	li $t0, 0  #�����ʾ
	lw $t1, 4($s7)  #����λ
	sll $t1, $t1, 31
	lw $t2, 8($s7)  #ָ���Ѽ�ƫ��ֵ
	sll $t2, $t2, 23
	lw $t3, 12($s7)  #β��
	or $t0, $t0, $t1
	or $t0, $t0, $t2
	or $t0, $t0, $t3
	sw $t0, 0($s7)
	jr $ra
	
##############################################################
mul_div_sign:
	li $t0, 0 #�������λ
	lw $t1, 4($s5)  #��һ��������λ
	lw $t2, 4($s6)  #�ڶ���������λ
	xor $t0, $t1, $t2
	sw $t0, 4($s7)
	jr $ra

mul_cal:
	lw $t1, 12($s5)  #��һ����β��
	lw $t2, 12($s6)  #�ڶ�����β��
	li $t0, 0x00800000
	or $t1, $t1, $t0 #��������1
	or $t2, $t2, $t0 #��������1
	lw $t3, 8($s5)  #��һ����ָ����ƫ��
	lw $t4, 8($s6)  #�ڶ�����ָ����ƫ��
	add $t5, $t3, $t4  #ָ��������ӽ��
	subi $t5, $t5, 127  #��ȥ�����ƫ��ֵ
	mult $t1, $t2
	mfhi $t1  #�����32λ
	mflo $t2  #�����32λ
	srl $t3, $t1, 15
	andi $t3, $t3, 0x00000001  #�ж��ܵ�48λ�Ƿ�Ϊ1������1�轫С��������
	beq $t3, 0, mul_wei_cal
	addi $t5, $t5, 1
	srl $t2, $t2, 1
	andi $t3, $t3, 0x00000001  #ȡ���ܵ�33λ
	sll $t3, $t3, 31
	or $t2, $t2, $t3
	srl $t1, $t1, 1
mul_wei_cal:
	srl $t2, $t2, 23  #ȡ9λ
	andi $t1, $t1, 0x000003fff  #ȡ14λ
	sll $t1, $t1, 9
	addi $s1, $t5, 0  #ָ��
	or $s2, $t1, $t2  #β��
	#Ҫ��s1Ϊ�����ָ����s2Ϊ�����β��
	li $t6, 1
	li $t7, 254
	slt $t1, $s1, $t6  #���ָ��С��1����Ϊ��0
	beq $t1, 1, mul_zhi_small
	slt $t2, $t7, $s1  #���ָ������254����Ϊ�������
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
	#�ڴ˺�����Ҫ����������������һ����3ָ����4β�������ڶ�����5ָ����6β�����������1ָ����2β����
	lw $t3, 8($s5)
	lw $t4, 12($s5)
	lw $t5, 8($s6)
	lw $t6, 12($s6)
	li $t0, 0x00800000
	or $t4, $t4, $t0 #��������1
	or $t6, $t6, $t0 #��������1
	sub $s1, $t3, $t5
	addi $s1, $s1, 127  #���ָ���������
	li $s2, 0  #��������
	li $t7, 24  #ѭ������
	li $t1, 0  #��ǰ�ϵ�λֵ
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
	#�����24λΪ0����ָ����1λ
	srl $t1, $s2, 23
	andi $t1, $t1, 1
	beq $t1, 0, borrow
	j div_check
borrow:
	sll $s2, $s2, 1
	subi $s1, $s1, 1
div_check:
	#β��ȡ��23λ
	li $t1, 0x007fffff
	and $s2, $s2, $t1
	#Ҫ��s1Ϊ�����ָ����s2Ϊ�����β��
	li $t6, 1
	li $t7, 254
	slt $t1, $s1, $t6  #���ָ��С��1����Ϊ��0
	beq $t1, 1, div_zhi_too_small
	slt $t2, $t7, $s1  #���ָ������254����Ϊ�������
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
	#�ڴ˺�����Ҫ����������������һ����3ָ����4β�������ڶ�����5ָ����6β�����������1ָ����2β����
	lw $t3, 8($s5)
	lw $t4, 12($s5)
	lw $t5, 8($s6)
	lw $t6, 12($s6)
	li $t0, 0x00800000
	or $t4, $t4, $t0 #��������1
	or $t6, $t6, $t0 #��������1
	#ָ������
	slt $t0, $t3, $t5
	beq $t0, 1, add_zhi_small
	slt $t0, $t5, $t3
	beq $t0, 1, add_zhi_big
	j add_wei_cal
add_zhi_small:  #��һ������ָ��С�ڵڶ���
	sub $t7, $t5, $t3  #���λ��
	add $t3, $t3, $t7
	srlv $t4, $t4, $t7 
	j add_wei_cal
add_zhi_big:  #��һ������ָ�����ڵڶ���
	sub $t7, $t3, $t5  #���λ��
	add $t5, $t5, $t7
	srlv $t6, $t6, $t7
add_wei_cal:  #β������
	addi $s1, $t3, 0
	add $t2, $t4, $t6
	#�жϵ�25λ�Ƿ�Ϊ1��������ָ��+1
	srl $t0, $t2, 24
	andi $t0, $t0, 1
	beq $t0, 1, add_zhi_plus
	j add_final
add_zhi_plus:
	addi $s1, $s1, 1
	srl $t2, $t2, 1
add_final:
	#β��ȡ��23λ
	li $t0, 0x007fffff
	and $s2, $t2, $t0
	#Ҫ��s1Ϊ�����ָ����s2Ϊ�����β��
	li $t6, 1
	li $t7, 254
	slt $t1, $s1, $t6  #���ָ��С��1����Ϊ��0
	beq $t1, 1, add_zhi_too_small
	slt $t2, $t7, $s1  #���ָ������254����Ϊ�������
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
	#�ڴ˺�����Ҫ����������������һ����3ָ����4β�������ڶ�����5ָ����6β�����������1ָ����2β����
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
	or $t4, $t4, $t0 #��������1
	or $t6, $t6, $t0 #��������1
	#ָ������
	slt $t0, $t3, $t5
	beq $t0, 1, sub_zhi_small
	slt $t0, $t5, $t3
	beq $t0, 1, sub_zhi_big
	j sub_wei_cal
sub_zhi_small:  #��һ������ָ��С�ڵڶ���
	sub $t7, $t5, $t3  #���λ��
	add $t3, $t3, $t7
	srlv $t4, $t4, $t7 
	j sub_wei_cal
sub_zhi_big:  #��һ������ָ�����ڵڶ���
	sub $t7, $t3, $t5  #���λ��
	add $t5, $t5, $t7
	srlv $t6, $t6, $t7
sub_wei_cal:  #β������
	addi $s1, $t3, 0
	#Ҫ��β�����С
	slt $t0, $t4, $t6
	beq $t0, 1, res_neg
	li $t0, 0
	sw $t0, 4($s7)
	j sub_wei_continue
res_neg:
	li $t0, 1
	sw $t0, 4($s7)
	#t4 t6����
	addi $t0, $t4, 0
	addi $t4, $t6, 0
	addi $t6, $t0, 0
sub_wei_continue:
	sub $s2, $t4, $t6  #�����������Ϊ0���⴦��
	beq $s2,0, zero_process
	#ֻҪ��24λΪ0����ָ����1λ��ͬʱβ������
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
	#β��ȡ��23λ
	li $t1, 0x007fffff
	and $s2, $s2, $t1
	#Ҫ��s1Ϊ�����ָ����s2Ϊ�����β��
	li $t6, 1
	li $t7, 254
	slt $t1, $s1, $t6  #���ָ��С��1����Ϊ��0
	beq $t1, 1, sub_zhi_too_small
	slt $t2, $t7, $s1  #���ָ������254����Ϊ�������
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
