
PLAYER_IDLE			equ			0
PLAYER_GO_LEFT		equ			2
PLAYER_GO_RIGHT		equ			4
PLAYER_GO_UP		equ			6
PLAYER_GO_DOWN		equ			8

PLAYER_MAX_X		equ 		31
PLAYER_MAX_Y		equ			23

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
.jumpTable:			jr			.drawIdle
					jr			.drawLeft
					jr			.drawRight
					jr			.drawUp
					jr			.drawDown

.drawIdle:			ld			hl, 0x0000
					ld			d, h
					ld			e, h
					ld			a, PLAYER_ATTR
					jp			DrawChar

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

HandlePlayer:		ld			l, (ix+SPLAYER.state)
					ld			h, 0
					ld			bc, .jumpTable
					add			hl, bc
					jp			(hl)
.jumpTable:			jr			.idle
					jr			.move
					jr			.move
					jr			.move
					jr			.move

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
					jr			z, .goDown

					ret

.goLeft:			ld			c, (ix+SPLAYER.x)
					ld			b, (ix+SPLAYER.y)
					dec			c
					call		CheckBlocked
					ret			nz
					dec			(ix+SPLAYER.x)
					ld			(ix+SPLAYER.state), PLAYER_GO_LEFT
					ld			(ix+SPLAYER.time), 0
					ret

.goRight:			ld			c, (ix+SPLAYER.x)
					ld			b, (ix+SPLAYER.y)
					inc			c
					call		CheckBlocked
					ret			nz
					inc			(ix+SPLAYER.x)
					ld			(ix+SPLAYER.state), PLAYER_GO_RIGHT
					ld			(ix+SPLAYER.time), 0
					ret

.goUp:				ld			c, (ix+SPLAYER.x)
					ld			b, (ix+SPLAYER.y)
					dec			b
					call		CheckBlocked
					ret			nz
					dec			(ix+SPLAYER.y)
					ld			(ix+SPLAYER.state), PLAYER_GO_UP
					ld			(ix+SPLAYER.time), 0
					ret

.goDown:			ld			c, (ix+SPLAYER.x)
					ld			b, (ix+SPLAYER.y)
					inc			b
					call		CheckBlocked
					ret			nz
					inc			(ix+SPLAYER.y)
					ld			(ix+SPLAYER.state), PLAYER_GO_DOWN
					ld			(ix+SPLAYER.time), 0
					ret
