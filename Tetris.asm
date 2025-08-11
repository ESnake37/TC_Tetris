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
const block_cur = r13
const block_next = r14
const block_rotation = r15
const block_data = r16
const block_color = r17
const seed = r18
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
const rank = r1
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
const highscore_x = 65
const highscore_y = 40
const highscore_color = 0xffffff
const gameover_x = 38
const gameover_y = 44
const gameover_color = 0xffffff
const name_len = 6
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
const backspace = 4
const enter = 5
const left = 15
const up = 16
const right = 17
const down = 18
const space = 32
const num_0 = 48
const num_1 = 49
const num_2 = 50
const num_3 = 51
const num_4 = 52
const num_5 = 53
const num_6 = 54
const num_7 = 55
const num_8 = 56
const num_9 = 57
const ltr_A = 65
const ltr_B = 66
const ltr_C = 67
const ltr_D = 68
const ltr_E = 69
const ltr_F = 70
const ltr_G = 71
const ltr_H = 72
const ltr_I = 73
const ltr_J = 74
const ltr_K = 75
const ltr_L = 76
const ltr_M = 77
const ltr_N = 78
const ltr_O = 79
const ltr_P = 80
const ltr_Q = 81
const ltr_R = 82
const ltr_S = 83
const ltr_T = 84
const ltr_U = 85
const ltr_V = 86
const ltr_W = 87
const ltr_X = 88
const ltr_Y = 89
const ltr_Z = 90



main:
	call init_screen
	call draw_title
	sc play_color
	call draw_play
	mov level easy
	call draw_level
	call set_level_color
	call draw_difficulty
	menu:
		in key_code kbd
		jge key_code 0 menu
		and key_code 0xff
		je key_code up level_up
		je key_code down level_down
		je key_code enter init_game
		jmp menu
		level_up:
			sc 0x000000
			call draw_difficulty
			dec level
			jge level 0 skip_warp
			mov level easy
			skip_warp:
			mod level 4
			call set_level_color
			call draw_difficulty
			jmp menu
		level_down:
			sc 0x000000
			call draw_difficulty
			inc level
			mod level 4
			call set_level_color
			call draw_difficulty
			jmp menu
	init_game:
		in seed time
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
		call draw_highscore_area
		mul level level
		mul level 700
		clr addr
		mov t board_height
		dec t
		mul t board_width
		store_board_lr:
			sw [addr] 1
			dec addr
			add addr board_width
			sw [addr] 1
			inc addr
			jl addr t store_board_lr
		add t board_width
		store_board_down:
			sw [addr] 1
			inc addr
			jl addr t store_board_down
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
		sub level 10
		main_loop_start:
			je end 1 main_loop
			je hard_drop_flag 1 fall_wait
			mov delay level
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
	gameover:
		sc gameover_color
		call check_rank
		call init_screen
		sc gameover_color
		mov x gameover_x
		mov y gameover_y
		push x
		push y
		call char_G
		add x 6
		push x
		push y
		call char_A
		add x 6
		push x
		push y
		call char_M
		add x 6
		push x
		push y
		call char_E
		add x 12
		push x
		push y
		call char_O
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
		call char_R
		halt



check_rank:
	clr addr
	mov t2 name_len
	inc t2
	mul t2 3
	dec t2
	ld t [0]
	sw [addr] t
	rank_load:
		inc addr
		ld t [1]
		sw [addr] t
		jl addr t2 rank_load
	neg t2
	ld t [t2]
	clr addr
	lw t [addr]
	jg score t rank1
	add addr name_len
	inc addr
	lw t [addr]
	jg score t rank2
	add addr name_len
	inc addr
	lw t [addr]
	jg score t rank3
	jmp check_rank_ret
	rank1:
		mov t name_len
		inc t
		add addr t
		clr i
		call rank_shift
		clr addr
		clr i
		call rank_shift
		clr addr
		sw [addr] score
		call newbest
		jmp check_rank_ret
	rank2:
		mov t name_len
		inc t
		clr i
		call rank_shift
		sub addr t
		sw [addr] score
		call newbest
		jmp check_rank_ret
	rank3:
		sw [addr] score
		call newbest
	check_rank_ret:
		ret

rank_shift:
	lw t2 [addr]
	add addr t
	sw [addr] t2
	inc addr
	sub addr t
	inc i
	jl i t rank_shift
	ret

newbest:
	call init_screen
	sc gameover_color
	mov x gameover_x
	mov y gameover_y
	sub y 16
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
	call char_W
	add x 12
	push x
	push y
	call char_B
	add x 6
	push x
	push y
	call char_E
	add x 6
	push x
	push y
	call char_S
	add x 6
	push x
	push y
	call char_T
	add x 6
	push x
	push y
	call char_exclamation_mark
	mov x gameover_x
	sub x 6
	add y 20
	push x
	push y
	call char_N
	add x 6
	push x
	push y
	call char_A
	add x 6
	push x
	push y
	call char_M
	add x 6
	push x
	push y
	call char_E
	add x 6
	push x
	push y
	call char_colon
	clr i
	input_name:
		in key_code kbd
		jl key_code 0 input_char
		jmp input_name
		input_char:
			and key_code 0xff
			je key_code enter rank_save
			je key_code backspace delete_char
			jge i name_len input_name
			add x 6
			sc gameover_color
			call draw_char
			inc i
			inc addr
			sw [addr] key_code
			jmp input_name
		delete_char:
			jle i 0 input_name
			lw key_code [addr]
			sw [addr] 0
			sc 0x000000
			call draw_char
			dec i
			dec addr
			sub x 6
			jmp input_name
	rank_save:
		clr addr
		mov t name_len
		inc t
		mul t 3
		lw t2 [addr]
		sd [0] t2
		inc addr
		rank_save_loop:
			lw t2 [addr]
			sd [1] t2
			inc addr
			jl addr t rank_save_loop
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
	je max_row 0 gameover
	store_block:
		and t t2 0b1000000000000000
		je t2 0 move_down_ret
		shl t2 1
		and t2 0b1111111111111111
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
		je t2 0 check_collision_ret
		shl t2 1
		and t2 0b1111111111111111
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
	check_line_loop:
		inc addr
		lw t [addr]
		je t 0 check_next_line
		inc j
		jge j board_width clear_line
		jmp check_line_loop
		check_next_line:
			inc i
			clr j
			mov t2 i
			mul addr i board_width
			jl i board_height check_line_loop
			jmp check_line_full_ret
	clear_line:
		dec t2
		mul addr t2 board_width
		call draw_line
		jge t2 max_row clear_line
		sc 0x000000
		call draw_score
		inc score
		jmp check_next_line
	check_line_full_ret:
		ret

draw_line:
	mov x 3
	add t t2 1
	mul y t block_size
	add y 3
	mov j 2
	draw_line_loop:
		inc addr
		lw block_color [addr]
		add t addr board_width
		sw [t] block_color
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

init_screen:
	clr x
	clr y
	sc screen_color
	init_screen_loop:
	    draw x y
	    inc x
	    jl x screen_width init_screen_loop
		clr x
	    inc y
	    jl y screen_height init_screen_loop
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
	call char_colon
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
	mul seed 1103515245
	add seed 12345
	mod seed 2147483648
	shr block_next seed 16
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
	call char_colon
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
	call char_colon
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

draw_highscore_area:
	mov x highscore_x
	mov y highscore_y
	sc highscore_color
	push x
	push y
	call char_H
	add x 6
	push x
	push y
	call char_I
	add x 6
	push x
	push y
	call char_G
	add x 6
	push x
	push y
	call char_H
	add x 9
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
	ld i [0]
	clr i0
	je i 0 draw_highscore_area_ret
	mov x highscore_x
	sub x 5
	add y 12
	push x
	push y
	call char_1
	add x 9
	call draw_highscore
	ld i [1]
	inc i0
	je i 0 draw_highscore_area_ret
	mov x highscore_x
	sub x 5
	add y 12
	push x
	push y
	call char_2
	add x 9
	call draw_highscore
	ld i [1]
	inc i0
	je i 0 draw_highscore_area_ret
	mov x highscore_x
	sub x 5
	add y 12
	push x
	push y
	call char_3
	add x 9
	call draw_highscore
	draw_highscore_area_ret:
		neg i0
		ld t [i0]
		ret

draw_highscore:
	clr j
	draw_highscore_loop:
		ld key_code [1]
		inc i0
		call draw_char
		add x 6
		inc j
		jl j name_len draw_highscore_loop
	add x 3
	div t i 100
	call draw_num
	add x 6
	mod t i 100
	div t 10
	call draw_num
	add x 6
	mod t i 10
	call draw_num
	ret

draw_num:
	je t 0 draw_num0
	je t 1 draw_num1
	je t 2 draw_num2
	je t 3 draw_num3
	je t 4 draw_num4
	je t 5 draw_num5
	je t 6 draw_num6
	je t 7 draw_num7
	je t 8 draw_num8
	je t 9 draw_num9
	jmp draw_num_ret
	draw_num0:
		push x
		push y
		call char_0
		jmp draw_num_ret
	draw_num1:
		push x
		push y
		call char_1
		jmp draw_num_ret
	draw_num2:
		push x
		push y
		call char_2
		jmp draw_num_ret
	draw_num3:
		push x
		push y
		call char_3
		jmp draw_num_ret
	draw_num4:
		push x
		push y
		call char_4
		jmp draw_num_ret
	draw_num5:
		push x
		push y
		call char_5
		jmp draw_num_ret
	draw_num6:
		push x
		push y
		call char_6
		jmp draw_num_ret
	draw_num7:
		push x
		push y
		call char_7
		jmp draw_num_ret
	draw_num8:
		push x
		push y
		call char_8
		jmp draw_num_ret
	draw_num9:
		push x
		push y
		call char_9
		jmp draw_num_ret
	draw_num_ret:
		ret

draw_char:
	je key_code 48 draw_0
	je key_code 49 draw_1
	je key_code 50 draw_2
	je key_code 51 draw_3
	je key_code 52 draw_4
	je key_code 53 draw_5
	je key_code 54 draw_6
	je key_code 55 draw_7
	je key_code 56 draw_8
	je key_code 57 draw_9
	je key_code 65 draw_A
	je key_code 66 draw_B
	je key_code 67 draw_C
	je key_code 68 draw_D
	je key_code 69 draw_E
	je key_code 70 draw_F
	je key_code 71 draw_G
	je key_code 72 draw_H
	je key_code 73 draw_I
	je key_code 74 draw_J
	je key_code 75 draw_K
	je key_code 76 draw_L
	je key_code 77 draw_M
	je key_code 78 draw_N
	je key_code 79 draw_O
	je key_code 80 draw_P
	je key_code 81 draw_Q
	je key_code 82 draw_R
	je key_code 83 draw_S
	je key_code 84 draw_T
	je key_code 85 draw_U
	je key_code 86 draw_V
	je key_code 87 draw_W
	je key_code 88 draw_X
	je key_code 89 draw_Y
	je key_code 90 draw_Z
	jmp draw_char_ret
	draw_0:
		push x
		push y
		call char_0
		jmp draw_char_ret
	draw_1:
		push x
		push y
		call char_1
		jmp draw_char_ret
	draw_2:
		push x
		push y
		call char_2
		jmp draw_char_ret
	draw_3:
		push x
		push y
		call char_3
		jmp draw_char_ret
	draw_4:
		push x
		push y
		call char_4
		jmp draw_char_ret
	draw_5:
		push x
		push y
		call char_5
		jmp draw_char_ret
	draw_6:
		push x
		push y
		call char_6
		jmp draw_char_ret
	draw_7:
		push x
		push y
		call char_7
		jmp draw_char_ret
	draw_8:
		push x
		push y
		call char_8
		jmp draw_char_ret
	draw_9:
		push x
		push y
		call char_9
		jmp draw_char_ret
	draw_A:
		push x
		push y
		call char_A
		jmp draw_char_ret
	draw_B:
		push x
		push y
		call char_B
		jmp draw_char_ret
	draw_C:
		push x
		push y
		call char_C
		jmp draw_char_ret
	draw_D:
		push x
		push y
		call char_D
		jmp draw_char_ret
	draw_E:
		push x
		push y
		call char_E
		jmp draw_char_ret
	draw_F:
		push x
		push y
		call char_F
		jmp draw_char_ret
	draw_G:
		push x
		push y
		call char_G
		jmp draw_char_ret
	draw_H:
		push x
		push y
		call char_H
		jmp draw_char_ret
	draw_I:
		push x
		push y
		call char_I
		jmp draw_char_ret
	draw_J:
		push x
		push y
		call char_J
		jmp draw_char_ret
	draw_K:
		push x
		push y
		call char_K
		jmp draw_char_ret
	draw_L:
		push x
		push y
		call char_L
		jmp draw_char_ret
	draw_M:
		push x
		push y
		call char_M
		jmp draw_char_ret
	draw_N:
		push x
		push y
		call char_N
		jmp draw_char_ret
	draw_O:
		push x
		push y
		call char_O
		jmp draw_char_ret
	draw_P:
		push x
		push y
		call char_P
		jmp draw_char_ret
	draw_Q:
		push x
		push y
		call char_Q
		jmp draw_char_ret
	draw_R:
		push x
		push y
		call char_R
		jmp draw_char_ret
	draw_S:
		push x
		push y
		call char_S
		jmp draw_char_ret
	draw_T:
		push x
		push y
		call char_T
		jmp draw_char_ret
	draw_U:
		push x
		push y
		call char_U
		jmp draw_char_ret
	draw_V:
		push x
		push y
		call char_V
		jmp draw_char_ret
	draw_W:
		push x
		push y
		call char_W
		jmp draw_char_ret
	draw_X:
		push x
		push y
		call char_X
		jmp draw_char_ret
	draw_Y:
		push x
		push y
		call char_Y
		jmp draw_char_ret
	draw_Z:
		push x
		push y
		call char_Z
		jmp draw_char_ret
	draw_char_ret:
		ret

get_block_data:
	pop t
	
	je t I get_I_data
	je t O get_O_data
	je t T get_T_data
	je t S get_S_data
	je t Z get_Z_data
	je t J get_J_data
	je t L get_L_data

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
	pop t
	
	je t I set_I_color
	je t O set_O_color
	je t T set_T_color
	je t S set_S_color
	je t Z set_Z_color
	je t J set_J_color
	je t L set_L_color

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



char_0:
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

char_1:
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
	
char_2:
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
	
char_3:
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
	
char_4:
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
	
char_5:
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
	
char_6:
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
	
char_7:
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

char_8:
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
	
char_9:
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
	
char_F:
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
	
char_J:
	pop character_y
	pop character_x
	inc character_x
	draw character_x character_y
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
	dec character_x
	draw character_x character_y
	dec character_x
	dec character_y
	draw character_x character_y
	ret
	
char_K:
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
	sub character_y 6
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
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	inc character_y
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
	
char_Q:
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
	add character_y 2
	draw character_x character_y
	sub character_x 2
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
	add character_x 2
	add character_y 3
	draw character_x character_y
	inc character_x
	inc character_y
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
	
char_U:
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
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	dec character_y
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
	
char_W:
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
	inc character_x
	inc character_y
	draw character_x character_y
	inc character_x
	dec character_y
	draw character_x character_y
	dec character_y
	draw character_x character_y
	inc character_x
	add character_y 2
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
	
char_Z:
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

char_exclamation_mark:
	pop character_y
	pop character_x
	add character_x 2
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	inc character_y
	draw character_x character_y
	add character_y 2
	draw character_x character_y
	ret

char_colon:
	pop character_y
	pop character_x
	inc character_x
	add character_y 2
	draw character_x character_y
	add character_y 3
	draw character_x character_y
	ret
