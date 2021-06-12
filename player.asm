
PLAYER_IDLE			equ			0
PLAYER_GO_LEFT		equ			3
PLAYER_GO_RIGHT		equ			6
PLAYER_GO_UP		equ			9
PLAYER_GO_DOWN		equ			12
PLAYER_SHIFT_LEFT	equ			15
PLAYER_SHIFT_RIGHT	equ			18
PLAYER_SHIFT_UP		equ			21
PLAYER_SHIFT_DOWN	equ			24

;PLAYER_MAX_X		equ 		31
;PLAYER_MAX_Y		equ			23

PLAYER_MOVE_DELAY_BITS equ		1

PLAYER_ATTR			equ			FLOOR_ATTR

					struct 		SPLAYER
x 					byte
y 					byte
state				byte
time				byte
					ends

player1:			SPLAYER		5,2,PLAYER_IDLE,0

InitPlayer:			ld			(ix+SPLAYER.state), PLAYER_IDLE
					ret

DrawPlayer:			ld			c, (ix+SPLAYER.x)
					ld			b, (ix+SPLAYER.y)

					ld			l, (ix+SPLAYER.state)
					ld			h, 0
					ld			de, .jumpTable
					add			hl, de
					jp			(hl)
.jumpTable:			jp			.drawIdle
					jp			.drawLeft
					jp			.drawRight
					jp			.drawUp
					jp			.drawDown
					jp			.drawShiftLeft
					jp			.drawShiftRight
					jp			.drawShiftUp
					jp			.drawShiftDown

.drawIdle:			ld			hl, 0x0000
					ld			d, h
					ld			e, h
					ld			a, PLAYER_ATTR
					jp			DrawChar

.drawShiftLeft:		ld			a, (ix+SPLAYER.time)
					dup			PLAYER_MOVE_DELAY_BITS
					rrca
					edup
					and			(1<<(8-PLAYER_MOVE_DELAY_BITS))-1
					inc			a
					neg
					ld			e, a

					and			3
					ld			h, 0x01
					ld			l, a
					ld			d, 0

					push		af

					push		bc
					push		de
					push		hl
					ld			a, SPHERE_ATTR
					call		DrawChar
					pop			hl
					pop			de
					pop			bc

					push		bc
					push		de
					dec			c
					ld			a, 8
					add			a, e
					ld			e, a
					ld			a, SPHERE_ATTR
					call		DrawChar
					pop			de
					pop			bc

					pop			af

					rrca
					and			1
					inc			a
					ld			l, a
					ld			h, 0
					ld			d, h

					push		hl
					push		de
					push		bc
					ld			a, PLAYER_ATTR
					inc			c
					call		DrawChar
					pop			bc
					pop			de
					pop			hl

					ld			a, DRAW_OR
					call		SetDrawCharMode

					ld			a, 8
					add			a, e
					ld			e, a
					ld			a, PLAYER_ATTR
					call		DrawChar

					ld			a, DRAW_REPLACE
					jp			SetDrawCharMode

.drawShiftRight:	;push		bc
					;inc			c
					;ld			hl, 0x0100
					;ld			de, 0
					;ld			a, SPHERE_ATTR
					;call		DrawChar
					;pop			bc

					ld			a, (ix+SPLAYER.time)
					dup			PLAYER_MOVE_DELAY_BITS
					rrca
					edup
					and			(1<<(8-PLAYER_MOVE_DELAY_BITS))-1
					inc			a
					ld			e, a

					and			3
					ld			h, 0x01
					ld			l, a
					ld			d, 0

					push		af

					push		bc
					push		de
					push		hl
					ld			a, SPHERE_ATTR
					call		DrawChar
					pop			hl
					pop			de
					pop			bc

					push		bc
					push		de
					inc			c
					ld			a, e
					sub			8
					ld			e, a
					ld			a, SPHERE_ATTR
					call		DrawChar
					pop			de
					pop			bc

					pop			af

					rrca
					and			1
					add			a, 3
					ld			l, a
					ld			h, 0
					ld			d, h

					ld			a, DRAW_REPLACE
					call		SetDrawCharMode

					push		hl
					push		de
					push		bc
					ld			a, PLAYER_ATTR
					dec			c
					call		DrawChar
					pop			bc
					pop			de
					pop			hl

					ld			a, DRAW_OR
					call		SetDrawCharMode

					ld			a, e
					sub			8
					ld			e, a
					ld			a, PLAYER_ATTR
					call		DrawChar

					ld			a, DRAW_REPLACE
					jp			SetDrawCharMode

.drawShiftUp:		push		bc
					dec			b
					ld			hl, 0x0100
					ld			de, 0
					ld			a, SPHERE_ATTR
					call		DrawChar
					pop			bc
					jr			.drawUp

.drawShiftDown:		push		bc
					inc			b
					ld			hl, 0x0100
					ld			de, 0
					ld			a, SPHERE_ATTR
					call		DrawChar
					pop			bc
					jr			.drawDown

.drawLeft:			ld			a, (ix+SPLAYER.time)
					dup			PLAYER_MOVE_DELAY_BITS
					rrca
					edup
					and			(1<<(8-PLAYER_MOVE_DELAY_BITS))-1
					inc			a
					neg
					ld			e, a
					rrca
					and			1
					inc			a
					ld			l, a
					ld			h, 0
					ld			d, h

					push		hl
					push		de
					push		bc
					ld			a, PLAYER_ATTR
					inc			c
					call		DrawChar
					pop			bc
					pop			de
					pop			hl

					ld			a, 8
					add			a, e
					ld			e, a
					ld			a, PLAYER_ATTR
					jp			DrawChar

.drawRight:			ld			a, (ix+SPLAYER.time)
					dup			PLAYER_MOVE_DELAY_BITS
					rrca
					edup
					and			(1<<(8-PLAYER_MOVE_DELAY_BITS))-1
					inc			a
					ld			e, a
					rrca
					and			1
					add			a, 3
					ld			l, a
					ld			h, 0
					ld			d, h

					push		hl
					push		de
					push		bc
					ld			a, PLAYER_ATTR
					dec			c
					call		DrawChar
					pop			bc
					pop			de
					pop			hl

					ld			a, e
					sub			8
					ld			e, a
					ld			a, PLAYER_ATTR
					jp			DrawChar

.drawDown:			ld			a, (ix+SPLAYER.time)
					dup			PLAYER_MOVE_DELAY_BITS
					rrca
					edup
					and			(1<<(8-PLAYER_MOVE_DELAY_BITS))-1
					inc			a
					ld			d, a
					and			3
					add			a, 5
					ld			l, a
					ld			h, 0
					ld			e, h

					ld			a, PLAYER_ATTR
					dec			b
					jp			DrawChar

.drawUp:			ld			a, (ix+SPLAYER.time)
					dup			PLAYER_MOVE_DELAY_BITS
					rrca
					edup
					and			(1<<(8-PLAYER_MOVE_DELAY_BITS))-1
					inc			a
					neg
					ld			d, a
					and			3
					add			a, 5
					ld			l, a
					ld			h, 0
					ld			e, h

					ld			a, PLAYER_ATTR
					inc			b
					push		de
					push		bc
					call		DrawChar
					pop			bc
					pop			de

					ld			a, 8
					add			a, d
					ld			d, a
					jp			DrawEmptyByte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

					macro 		PLAYERGO state, shift

					ld			c, (ix+SPLAYER.x)
					ld			b, (ix+SPLAYER.y)
				if state == PLAYER_GO_UP
					dec			b
				elseif state == PLAYER_GO_DOWN
					inc			b
				elseif state == PLAYER_GO_LEFT
					dec			c
				elseif state == PLAYER_GO_RIGHT
					inc			c
				endif
					call		CheckBlocked
					jr			nz, .tryShift
					ld			a, state
.doGo:			if state == PLAYER_GO_DOWN || state == PLAYER_GO_UP
					ld			(ix+SPLAYER.y), b
				elseif state == PLAYER_GO_LEFT || state == PLAYER_GO_RIGHT
					ld			(ix+SPLAYER.x), c
				endif
					ld			(ix+SPLAYER.state), a
					ld			(ix+SPLAYER.time), 0
					ret
.tryShift:			cp			'O'
					ret			nz
				if state == PLAYER_GO_UP
					dec			b
				elseif state == PLAYER_GO_DOWN
					inc			b
				elseif state == PLAYER_GO_LEFT
					dec			c
				elseif state == PLAYER_GO_RIGHT
					inc			c
				endif
					call		CheckBlocked
					ret			nz
					ld			(hl), 'O'
				if state == PLAYER_GO_UP
					inc			b
					ld			de, 32
					add			hl, de
				elseif state == PLAYER_GO_DOWN
					dec			b
					ld			de, -32
					add			hl, de
				elseif state == PLAYER_GO_LEFT
					inc			c
					inc			hl
				elseif state == PLAYER_GO_RIGHT
					dec			c
					dec			hl
				endif
					ld			(hl), ' '
					ld			a, shift
					jr			.doGo

					endm

HandlePlayer:		ld			l, (ix+SPLAYER.state)
					ld			h, 0
					ld			bc, .jumpTable
					add			hl, bc
					jp			(hl)
.jumpTable:			jp			.idle
					jp			.move
					jp			.move
					jp			.move
					jp			.move
					jp			.move
					jp			.move
					jp			.move
					jp			.move

.move:				ld			a, (ix+SPLAYER.time)
					inc			a
					cp			(8<<PLAYER_MOVE_DELAY_BITS)
					jr			z, .moveDone
					ld			(ix+SPLAYER.time), a
					ret
.moveDone:			ld			(ix+SPLAYER.state), PLAYER_IDLE
					ld			(ix+SPLAYER.time), 0
					;jr			.idle

.idle:				ld			hl, Input.left
					xor			a
					cp			(hl)
					jr			z, .goLeft

					inc			hl
					cp			(hl)
					jr			z, .goRight

					inc			hl
					cp			(hl)
					jr			z, .goUp

					inc			hl
					cp			(hl)
					jp			z, .goDown

					ret

.goLeft:			PLAYERGO	PLAYER_GO_LEFT, PLAYER_SHIFT_LEFT
.goRight:			PLAYERGO	PLAYER_GO_RIGHT, PLAYER_SHIFT_RIGHT
.goUp:				PLAYERGO	PLAYER_GO_UP, PLAYER_SHIFT_UP
.goDown:			PLAYERGO	PLAYER_GO_DOWN, PLAYER_SHIFT_DOWN
