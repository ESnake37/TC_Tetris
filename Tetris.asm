const x = r1
const y = r2
const x0 = r3
const y0 = r4
const i = r5
const j = r6
const i0 = r7
const j0 = r8
const t = r9
const t2 = r10
const block_x = r11
const block_y = r12
const block_type = r13
const block_cur = r14
const block_next = r15
const block_rotation = r16
const block_data = r17
const block_color = r18
const score = r19
const delay = r20
const key_code = r21
const level = r22
const block_x_new = r23
const block_y_new = r24
const addr = r25
const collision = r26
const end = r27
const hard_drop_flag = r28
const max_row = r29
const character_x = r30
const character_y = r31
const screen_width = 128
const screen_height = 96
const screen_color = 0x000000
const title_x = 46
const title_y = 24
const draw_title_delay = 2000
const play_x = 52
const play_y = 50
const play_color = 0x999999
const level_x = 31
const level_y = 66
const level_color = 0x999999
const easy = 3
const normal = 2
const hard = 1
const insane = 0
const easy_color = 0x00D4FF
const normal_color = 0x00FF41
const hard_color = 0xFFF300
const insane_color = 0xFF78D8
const block_size = 5
const board_width = 12
const board_height = 19
const board_color = 0x787878
const draw_board_delay = 40
const next_x = 65
const next_y = 8
const next_color = 0xffffff
const score_x = 65
const score_y = 20
const score_color = 0xffffff
const I = 0
const O = 1
const T = 2
const S = 3
const Z = 4
const J = 5
const L = 6
const I_color = 0x00CDCD
const O_color = 0xCDCD00
const T_color = 0x9A00CD
const S_color = 0x00CD00
const Z_color = 0xCD0000
const J_color = 0x0000CD
const L_color = 0xCD6600
const backspace = 26
const enter = 53
const space = 68
const left = 69
const up = 70
const right = 71
const down = 72



main:
	call init_screen
	call draw_title
	sc play_color
	call draw_play
	mov level easy
	call draw_level
	call set_level_color
	call draw_difficulty
	; 游戏菜单
	menu_loop:
		in key_code kbd
		jge key_code 0 menu_loop
		and key_code 0xff
		je key_code up level_up
		je key_code down level_down
		je key_code enter init_game
		jmp menu_loop
		level_up:
			sc 0x000000
			call draw_difficulty
			dec level
			jge level 0 not_warp
			mov level easy
			not_warp:
			mod level 4
			call set_level_color
			call draw_difficulty
			jmp menu_loop
		level_down:
			sc 0x000000
			call draw_difficulty
			inc level
			mod level 4
			call set_level_color
			call draw_difficulty
			jmp menu_loop
	; 游戏初始化
	init_game:
		call gen_block
		sc 0xffffff
		call draw_play
		call init_screen
		call draw_game_border
		call draw_next_area
		mov max_row board_height
		sub max_row 2
		clr score
		call draw_score_area
		mul level level
		mul delay level 600
		clr i
		mov t board_height
		dec t
		mul t board_width
		store_board_lr:
			sw [i] 1
			dec i
			add i board_width
			sw [i] 1
			inc i
			jl i t store_board_lr
		add t board_width
		store_board_down:
			sw [i] 1
			inc i
			jl i t store_board_down
	; 游戏主循环
	main_loop:
		clr end
		clr block_rotation
		clr hard_drop_flag
		call check_line_full
		sc score_color
		call draw_score
		mov x next_x
		add x 36
		mov y next_y
		sub y 3
		push block_next
		call get_block_data
		sc 0x000000
		call draw_block
		mov block_cur block_next
		call gen_block
		mov x next_x
		add x 36
		mov y next_y
		sub y 3
		push block_next
		call get_block_data
		push block_next
		call set_block_color
		sc block_color
		call draw_block
		mov t block_size
		mul t 3
		add x t 3
		mov y 3
		push block_cur
		call get_block_data
		push block_cur
		call set_block_color
		sc block_color
		call draw_block
		mov block_x 4
		clr block_y
		main_loop_start:
			je end 1 main_loop
			je hard_drop_flag 1 fall_wait
			mul delay level 500
			fall_wait:
				in key_code kbd
				jl key_code 0 handle_key
				dec delay
				jg delay 0 fall_wait
			call move_down
			jmp main_loop_start
			handle_key:
				and key_code 0xff
				je key_code left move_left
				je key_code right move_right
				je key_code up rotate
				je key_code down soft_drop
				je key_code space hard_drop
				jmp fall_wait
			move_left:
				sub block_x_new block_x 1
				mov block_y_new block_y
				call check_collision
				je collision 1 fall_wait
				mov t block_size
				mul x t block_x
				mul y t block_y
				sub x 2
				add y 3
				sc 0x000000
				call draw_block
				dec block_x
				mov t block_size
				mul x t block_x
				mul y t block_y
				sub x 2
				add y 3
				push block_cur
				call set_block_color
				sc block_color
				call draw_block
				jmp fall_wait
			move_right:
				add block_x_new block_x 1
				mov block_y_new block_y
				call check_collision
				je collision 1 fall_wait
				mov t block_size
				mul x t block_x
				mul y t block_y
				sub x 2
				add y 3
				sc 0x000000
				call draw_block
				inc block_x
				mov t block_size
				mul x t block_x
				mul y t block_y
				sub x 2
				add y 3
				push block_cur
				call set_block_color
				sc block_color
				call draw_block
				jmp fall_wait
			rotate:
				mov t block_size
				mul x t block_x
				mul y t block_y
				sub x 2
				add y 3
				sc 0x000000
				call draw_block
				inc block_rotation
				mod block_rotation 4
				mov t block_size
				mul x t block_x
				mul y t block_y
				sub x 2
				add y 3
				push block_cur
				call get_block_data
				call check_collision
				je collision 1 fall_wait
				push block_cur
				call set_block_color
				sc block_color
				call draw_block
				jmp fall_wait
			soft_drop:
				call move_down
				jmp fall_wait
			hard_drop:
				mov hard_drop_flag 1
				clr delay
				jmp main_loop_start



init_screen:
	sc screen_color
	clr y
	y_loop:
	    clr x
	x_loop:
	    draw x y
	    inc x
	    jl x screen_width x_loop
	    inc y
	    jl y screen_height y_loop
	ret

draw_title:
	mov x title_x
	mov y title_y
	mov delay draw_title_delay
	draw_title_wait1:
		dec delay
		jg delay 0 draw_title_wait1
	push x
	push y
	sc Z_color
	call char_T
	mov delay draw_title_delay
	draw_title_wait2:
		dec delay
		jg delay 0 draw_title_wait2
	add x 6
	push x
	push y
	sc L_color
	call char_E
	mov delay draw_title_delay
	draw_title_wait3:
		dec delay
		jg delay 0 draw_title_wait3
	add x 6
	push x
	push y
	sc O_color
	call char_T
	mov delay draw_title_delay
	draw_title_wait4:
		dec delay
		jg delay 0 draw_title_wait4
	add x 6
	push x
	push y
	sc S_color
	call char_R
	mov delay draw_title_delay
	draw_title_wait5:
		dec delay
		jg delay 0 draw_title_wait5
	add x 6
	push x
	push y
	sc I_color
	call char_I
	mov delay draw_title_delay
	draw_title_wait6:
		dec delay
		jg delay 0 draw_title_wait6
	add x 6
	push x
	push y
	sc T_color
	call char_S
	mov delay draw_title_delay
	mul delay 2
	draw_title_wait7:
		dec delay
		jg delay 0 draw_title_wait7
	ret

draw_play:
	mov x play_x
	mov y play_y
	push x
	push y
	call char_P
	add x 6
	push x
	push y
	call char_L
	add x 6
	push x
	push y
	call char_A
	add x 6
	push x
	push y
	call char_Y
	ret

draw_level:
	mov x level_x
	mov y level_y
	sc level_color
	push x
	push y
	call char_L
	add x 6
	push x
	push y
	call char_E
	add x 6
	push x
	push y
	call char_V
	add x 6
	push x
	push y
	call char_E
	add x 6
	push x
	push y
	call char_L
	add x 6
	push x
	push y
	call colon
	ret

set_level_color:
	je level easy set_easy_color
	je level normal set_normal_color
	je level hard set_hard_color
	je level insane set_insane_color
	set_easy_color:
		sc easy_color
		jmp set_level_color_ret
	set_normal_color:
		sc normal_color
		jmp set_level_color_ret
	set_hard_color:
		sc hard_color
		jmp set_level_color_ret
	set_insane_color:
		sc insane_color
	set_level_color_ret:
		ret

draw_difficulty:
	mov x level_x
	add x 36
	mov y level_y
	je level easy draw_easy
	je level normal draw_normal
	je level hard draw_hard
	je level insane draw_insane
	draw_easy:
		push x
		push y
		call char_E
		add x 6
		push x
		push y
		call char_A
		add x 6
		push x
		push y
		call char_S
		add x 6
		push x
		push y
		call char_Y
		jmp draw_difficulty_ret
	draw_normal:
		push x
		push y
		call char_N
		add x 6
		push x
		push y
		call char_O
		add x 6
		push x
		push y
		call char_R
		add x 6
		push x
		push y
		call char_M
		add x 6
		push x
		push y
		call char_A
		add x 6
		push x
		push y
		call char_L
		jmp draw_difficulty_ret
	draw_hard:
		push x
		push y
		call char_H
		add x 6
		push x
		push y
		call char_A
		add x 6
		push x
		push y
		call char_R
		add x 6
		push x
		push y
		call char_D
		jmp draw_difficulty_ret
	draw_insane:
		push x
		push y
		call char_I
		add x 6
		push x
		push y
		call char_N
		add x 6
		push x
		push y
		call char_S
		add x 6
		push x
		push y
		call char_A
		add x 6
		push x
		push y
		call char_N
		add x 6
		push x
		push y
		call char_E
	draw_difficulty_ret:
		ret

gen_block:
	in t time
	mul t 1103515245
	add t 12345
	mod t 2147483648
	shr block_next t 16
	mod block_next 7
	ret

draw_game_border:
	clr x
	clr y
	sc board_color
	draw_game_border_loop1:
		draw x y
		inc x
		draw x y
		inc x
		draw x y
		sub x 2
		inc y
		mov delay draw_board_delay
		draw_board_wait1:
			dec delay
			jg delay 0 draw_board_wait1
		jl y screen_height draw_game_border_loop1
	add x 3
	dec y
	mov t block_size
	mul t 10
	add t 3
	draw_game_border_loop2:
		draw x y
		dec y
		draw x y
		dec y
		draw x y
		add y 2
		inc x
		mov delay draw_board_delay
		draw_board_wait2:
			dec delay
			jg delay 0 draw_board_wait2
		jl x t draw_game_border_loop2
	draw_game_border_loop3:
		draw x y
		inc x
		draw x y
		inc x
		draw x y
		sub x 2
		dec y
		mov delay draw_board_delay
		draw_board_wait3:
			dec delay
			jg delay 0 draw_board_wait3
		jge y 0 draw_game_border_loop3
	dec x
	inc y
	draw_game_border_loop4:
		draw x y
		inc y
		draw x y
		inc y
		draw x y
		sub y 2
		dec x
		mov delay draw_board_delay
		draw_board_wait4:
			dec delay
			jg delay 0 draw_board_wait4
		jge x 3 draw_game_border_loop4
	ret

draw_next_area:
	mov x next_x
	mov y next_y
	sc next_color
	push x
	push y
	call char_N
	add x 6
	push x
	push y
	call char_E
	add x 6
	push x
	push y
	call char_X
	add x 6
	push x
	push y
	call char_T
	add x 6
	push x
	push y
	call colon
	ret

draw_score_area:
	mov x score_x
	mov y score_y
	sc score_color
	push x
	push y
	call char_S
	add x 6
	push x
	push y
	call char_C
	add x 6
	push x
	push y
	call char_O
	add x 6
	push x
	push y
	call char_R
	add x 6
	push x
	push y
	call char_E
	add x 6
	push x
	push y
	call colon
	ret

draw_score:
	mov x score_x
	add x 36
	mov y score_y

	div t score 100
	call draw_num
	add x 6
	mod t score 100
	div t 10
	call draw_num
	add x 6
	mod t score 10
	call draw_num

	ret

draw_num:
	je t 0 draw_0
	je t 1 draw_1
	je t 2 draw_2
	je t 3 draw_3
	je t 4 draw_4
	je t 5 draw_5
	je t 6 draw_6
	je t 7 draw_7
	je t 8 draw_8
	je t 9 draw_9
	draw_0:
		push x
		push y
		call num0
		jmp draw_num_ret
	draw_1:
		push x
		push y
		call num1
		jmp draw_num_ret
	draw_2:
		push x
		push y
		call num2
		jmp draw_num_ret
	draw_3:
		push x
		push y
		call num3
		jmp draw_num_ret
	draw_4:
		push x
		push y
		call num4
		jmp draw_num_ret
	draw_5:
		push x
		push y
		call num5
		jmp draw_num_ret
	draw_6:
		push x
		push y
		call num6
		jmp draw_num_ret
	draw_7:
		push x
		push y
		call num7
		jmp draw_num_ret
	draw_8:
		push x
		push y
		call num8
		jmp draw_num_ret
	draw_9:
		push x
		push y
		call num9
		jmp draw_num_ret
	draw_num_ret:
		ret

get_block_data:
	pop block_type
	
	je block_type I get_I_data
	je block_type O get_O_data
	je block_type T get_T_data
	je block_type S get_S_data
	je block_type Z get_Z_data
	je block_type J get_J_data
	je block_type L get_L_data

	get_I_data:
		je block_rotation 0 get_I0_data
		je block_rotation 1 get_I1_data
		je block_rotation 2 get_I2_data
		je block_rotation 3 get_I3_data
		get_I0_data:
			mov block_data 0b0000111100000000
			jmp get_block_data_ret
		get_I1_data:
			mov block_data 0b0010001000100010
			jmp get_block_data_ret
		get_I2_data:
			mov block_data 0b0000000011110000
			jmp get_block_data_ret
		get_I3_data:
			mov block_data 0b0100010001000100
			jmp get_block_data_ret
	get_O_data:
		mov block_data 0b0110011000000000
		jmp get_block_data_ret
	get_T_data:
		je block_rotation 0 get_T0_data
		je block_rotation 1 get_T1_data
		je block_rotation 2 get_T2_data
		je block_rotation 3 get_T3_data
		get_T0_data:
			mov block_data 0b0100111000000000
			jmp get_block_data_ret
		get_T1_data:
			mov block_data 0b0100011001000000
			jmp get_block_data_ret
		get_T2_data:
			mov block_data 0b0000111001000000
			jmp get_block_data_ret
		get_T3_data:
			mov block_data 0b0100110001000000
			jmp get_block_data_ret
	get_S_data:
		je block_rotation 0 get_S0_data
		je block_rotation 1 get_S1_data
		je block_rotation 2 get_S2_data
		je block_rotation 3 get_S3_data
		get_S0_data:
			mov block_data 0b0110110000000000
			jmp get_block_data_ret
		get_S1_data:
			mov block_data 0b0100011000100000
			jmp get_block_data_ret
		get_S2_data:
			mov block_data 0b0000011011000000
			jmp get_block_data_ret
		get_S3_data:
			mov block_data 0b1000110001000000
			jmp get_block_data_ret
	get_Z_data:
		je block_rotation 0 get_Z0_data
		je block_rotation 1 get_Z1_data
		je block_rotation 2 get_Z2_data
		je block_rotation 3 get_Z3_data
		get_Z0_data:
			mov block_data 0b1100011000000000
			jmp get_block_data_ret
		get_Z1_data:
			mov block_data 0b0010011001000000
			jmp get_block_data_ret
		get_Z2_data:
			mov block_data 0b0000011000110000
			jmp get_block_data_ret
		get_Z3_data:
			mov block_data 0b0100110010000000
			jmp get_block_data_ret
	get_J_data:
		je block_rotation 0 get_J0_data
		je block_rotation 1 get_J1_data
		je block_rotation 2 get_J2_data
		je block_rotation 3 get_J3_data
		get_J0_data:
			mov block_data 0b1000111000000000
			jmp get_block_data_ret
		get_J1_data:
			mov block_data 0b0110010001000000
			jmp get_block_data_ret
		get_J2_data:
			mov block_data 0b0000111000100000
			jmp get_block_data_ret
		get_J3_data:
			mov block_data 0b0100010011000000
			jmp get_block_data_ret
	get_L_data:
		je block_rotation 0 get_L0_data
		je block_rotation 1 get_L1_data
		je block_rotation 2 get_L2_data
		je block_rotation 3 get_L3_data
		get_L0_data:
			mov block_data 0b0010111000000000
			jmp get_block_data_ret
		get_L1_data:
			mov block_data 0b0100010001100000
			jmp get_block_data_ret
		get_L2_data:
			mov block_data 0b0000111010000000
			jmp get_block_data_ret
		get_L3_data:
			mov block_data 0b1100010001000000

	get_block_data_ret:
		ret

set_block_color:
	pop block_type
	
	je block_type I set_I_color
	je block_type O set_O_color
	je block_type T set_T_color
	je block_type S set_S_color
	je block_type Z set_Z_color
	je block_type J set_J_color
	je block_type L set_L_color

	set_I_color:
		mov block_color I_color
		jmp set_block_color_ret
	set_O_color:
		mov block_color O_color
		jmp set_block_color_ret
	set_T_color:
		mov block_color T_color
		jmp set_block_color_ret
	set_S_color:
		mov block_color S_color
		jmp set_block_color_ret
	set_Z_color:
		mov block_color Z_color
		jmp set_block_color_ret
	set_J_color:
		mov block_color J_color
		jmp set_block_color_ret
	set_L_color:
		mov block_color L_color

	set_block_color_ret:
		ret

draw_block:
	clr i
	clr j
	clr i0
	clr j0
	mov t2 block_data
	draw_block_loop:
		mov x0 x
		mov y0 y
		and t t2 0b1000000000000000
		shl t2 1
		je t 0 draw_done
		draw_block_loop0:
			draw x0 y0
			inc x0
			inc i0
			jl i0 block_size draw_block_loop0
			sub x0 block_size
			inc y0
			clr i0
			inc j0
			jl j0 block_size draw_block_loop0
		draw_done:
		add x block_size
		inc i
		clr j0
		jl i 4 draw_block_loop
		mov t block_size
		mul t 4
		sub x t
		add y block_size
		clr i
		inc j
		jl j 4 draw_block_loop
	ret

move_down:
	mov block_x_new block_x
	add block_y_new block_y 1
	call check_collision
	je collision 0 move_down_cont
	mov end 1
	clr i
	mov t2 block_data
	mul addr block_y board_width
	add addr block_x
	mov j block_y
	and t t2 0b1111111100000000
	jne t 0 max_row1
	inc j
	max_row1:
	and t t2 0b1111000000000000
	jne t 0 max_row2
	inc j
	max_row2:
	jge j max_row store_block
	mov max_row j
	store_block:
		and t t2 0b1000000000000000
		shl t2 1
		and t2 0b1111111111111111
		je t2 0 move_down_ret
		je t 0 skip_store_block
		sw [addr] block_color
		skip_store_block:
		inc addr
		inc i
		jl i 4 store_block
		add addr board_width
		sub addr 4
		clr i
		jmp store_block
	move_down_cont:
		mov t block_size
		mul x t block_x
		mul y t block_y
		sub x 2
		add y 3
		sc 0x000000
		call draw_block
		inc block_y
		mov t block_size
		mul x t block_x
		mul y t block_y
		sub x 2
		add y 3
		push block_cur
		call set_block_color
		sc block_color
		call draw_block
	move_down_ret:
		ret

check_collision:
	clr i
	clr collision
	mov t2 block_data
	mul addr block_y_new board_width
	add addr block_x_new
	dec addr
	check_collision_loop:
		inc addr
		inc i
		and t t2 0b1000000000000000
		shl t2 1
		and t2 0b1111111111111111
		je t2 0 check_collision_ret
		je t 0 skip_check
		lw t [addr]
		jne t 0 is_collision
		skip_check:
		jl i 4 check_collision_loop
		add addr board_width
		sub addr 4
		clr i
		jmp check_collision_loop
	is_collision:
		mov collision 1
	check_collision_ret:
		ret

check_line_full:
	mov i max_row
	mov j 2
	mul addr max_row board_width
	check_line_full_loop:
		inc addr
		lw t [addr]
		je t 0 check_next_line
		inc j
		jge j board_width clear_line
		jmp check_line_full_loop
		check_next_line:
			inc i
			clr j
			mul addr i board_width
			jl i board_height check_line_full_loop
			jmp check_line_full_ret
	clear_line:
		dec i
		mul addr i board_width
		call draw_line
		jge i max_row clear_line
		sc 0x000000
		call draw_score
		inc score
	check_line_full_ret:
		ret

draw_line:
	mov x 3
	mov t block_size
	add t2 i 1
	mul y t t2
	add y 3
	mov j 2
	draw_line_loop:
		inc addr
		lw block_color [addr]
		sc block_color
		mov x0 x
		mov y0 y
		clr i0
		clr j0
		draw_line_loop0:
			draw x0 y0
			inc x0
			inc i0
			jl i0 block_size draw_line_loop0
			sub x0 block_size
			inc y0
			clr i0
			inc j0
			jl j0 block_size draw_line_loop0
		add x block_size
		inc j
		jl j board_width draw_line_loop
	ret


num0:
	pop character_y
	pop character_x
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	add character_x 3
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	ret

num1:
	pop character_y
	pop character_x
	add character_x 2
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y	
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	dec character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	ret
	
num2:
	pop character_y
	pop character_x
	inc character_y
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	ret
	
num3:
	pop character_y
	pop character_x
	inc character_y
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	sub character_x 2
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	ret
	
num4:
	pop character_y
	pop character_x
	add character_x 3
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	dec character_x
	sub character_y 4
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	add character_y 2
	draw character_x character_y
	inc character_y
	draw character_x character_y
	ret
	
num5:
	pop character_y
	pop character_x
	add character_x 4
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	ret
	
num6:
	pop character_y
	pop character_x
	add character_x 4
	inc character_y
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	ret
	
num7:
	pop character_y
	pop character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	ret

num8:
	pop character_y
	pop character_x
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	add character_y 3
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	ret
	
num9:
	pop character_y
	pop character_x
	add character_x 3
	add character_y 3
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	ret
	
char_A:
	pop character_y
	pop character_x
	add character_y 6
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	sub character_x 3
	sub character_y 2
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	ret
	
char_B:
	pop character_y
	pop character_x
	add character_x 6
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	sub character_x 3
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	ret
	
char_C:
	pop character_y
	pop character_x
	add character_x 4
	inc character_y
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	ret
	
char_D:
	pop character_y
	pop character_x
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	ret
	
char_E:
	pop character_y
	pop character_x
	add character_x 4
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	sub character_x 3
	sub character_y 3
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	ret
	
char_G:
	pop character_y
	pop character_x
	add character_x 4
	inc character_y
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	ret
	
char_H:
	pop character_y
	pop character_x
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	add character_x 4
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	sub character_x 3
	add character_y 3
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	ret
	
char_I:
	pop character_y
	pop character_x
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	ret
	
char_L:
	pop character_y
	pop character_x
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	ret
	
char_M:
	pop character_y
	pop character_x
	add character_y 6
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	sub character_y 2
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	ret
	
char_N:
	pop character_y
	pop character_x
	add character_y 6
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	inc character_x
	add character_y 2
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	add character_y 2
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	ret
	
char_O:
	pop character_y
	pop character_x
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	ret
	
char_P:
	pop character_y
	pop character_x
	add character_y 6
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	ret
	
char_R:
	pop character_y
	pop character_x
	add character_y 6
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	ret
	
char_S:
	pop character_y
	pop character_x
	add character_x 4
	inc character_y
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	ret
	
char_T:
	pop character_y
	pop character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	inc character_x
	draw character_x character_y
	sub character_x 2
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	ret
	
char_V:
	pop character_y
	pop character_x
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	ret
	
char_X:
	pop character_y
	pop character_x
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	sub character_y 6
	draw character_x character_y
	inc character_y
	draw character_x character_y
	dec character_x
	inc character_y
	draw character_x character_y
	sub character_x 2
	add character_y 2
	draw character_x character_y
	dec character_x
	inc character_y   
	draw character_x character_y
	inc character_y
	draw character_x character_y
	ret
	
char_Y:
	pop character_y
	pop character_x
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	sub character_x 2
	add character_y 4
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	ret
	
colon:
	pop character_y
	pop character_x
	inc character_x
	add character_y 2
	draw character_x character_y
	add character_y 3
	draw character_x character_y
	ret
