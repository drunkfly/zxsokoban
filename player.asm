
PLAYER_IDLE			equ			0
PLAYER_GO_LEFT		equ			3
PLAYER_GO_RIGHT		equ			6
PLAYER_GO_UP		equ			9
PLAYER_GO_DOWN		equ			12
PLAYER_SHIFT_LEFT	equ			15
PLAYER_SHIFT_RIGHT	equ			18
PLAYER_SHIFT_UP		equ			21
PLAYER_SHIFT_DOWN	equ			24
PLAYER_UNDO_GO_LEFT	equ			27
PLAYER_UNDO_GO_RIGHT equ		30
PLAYER_UNDO_GO_UP	equ			33
PLAYER_UNDO_GO_DOWN equ			36
PLAYER_UNDO_SHIFT_LEFT	equ		39
PLAYER_UNDO_SHIFT_RIGHT equ		42
PLAYER_UNDO_SHIFT_UP	equ		45
PLAYER_UNDO_SHIFT_DOWN equ		48

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

					macro		DRAWHORZ left, shift

					ld			a, (ix+SPLAYER.time)
					dup			PLAYER_MOVE_DELAY_BITS
					rrca
					edup
					and			(1<<(8-PLAYER_MOVE_DELAY_BITS))-1
					inc			a
				if left
					neg
				endif
					ld			e, a

				if shift
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
				  if left
					dec			c
					ld			a, 8
					add			a, e
				  else
					inc			c
					ld			a, e
					sub			8
				  endif
					ld			e, a
					ld			a, SPHERE_ATTR
					call		DrawChar
					pop			de
					pop			bc

					pop			af
				endif ; shift

					rrca
					and			1
				if left
					inc			a
				else
					add			a, 3
				endif
					ld			l, a
					ld			h, 0
					ld			d, h

					push		hl
					push		de
					push		bc
					ld			a, PLAYER_ATTR
				if left
					inc			c
				else
					dec			c
				endif
					call		DrawChar
					pop			bc
					pop			de
					pop			hl

				if shift
					ld			a, DRAW_OR
					call		SetDrawCharMode
				endif

					ld			a, e
				if left
					add			a, 8
				else
					sub			8
				endif
					ld			e, a
					ld			a, PLAYER_ATTR
				if shift
					call		DrawChar
					ld			a, DRAW_REPLACE
					jp			SetDrawCharMode
				else
					jp			DrawChar
				endif

					endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

					macro		DRAWVERT up, shift

					ld			a, (ix+SPLAYER.time)
					dup			PLAYER_MOVE_DELAY_BITS
					rrca
					edup
					and			(1<<(8-PLAYER_MOVE_DELAY_BITS))-1
					inc			a
				if up
					neg
				endif
					ld			d, a
					ld			e, 0

					and			3

				if shift
					push		af
					push		de
					push		bc
					ld			h, 1
					ld			l, a
					ld			a, SPHERE_ATTR
					call		DrawChar
					pop			bc
					pop			de
					pop			af
			 	endif ; shift

					add			a, 5
					ld			l, a
					ld			h, e

					ld			a, PLAYER_ATTR
				if up
					inc			b
				else
					dec			b
				endif	
					push		de
					push		bc
					call		DrawChar
					pop			bc
					pop			de

;				if shift
;					ld			a, (ix+SPLAYER.state)
;					cp			PLAYER_UNDO_SHIFT_DOWN
;					jr			z, .goDown
;					cp			PLAYER_UNDO_SHIFT_UP
;					ret			nz
;.goUp:
;					ld			a, d
;					jr			.doneGo
;.goDown:
;					ld			a, d
;					sub			8
;.doneGo:
;				else
				if !up
					ld			a, (ix+SPLAYER.state)
					cp			PLAYER_UNDO_GO_DOWN
					ret			nz
					ld			a, d
					and			7
					ret			z
				endif

					ld			a, d
					add			a, 8
					ld			d, a
					jp			DrawEmptyByte

					endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

.drawShiftLeft:		DRAWHORZ 	1, 1
.drawShiftRight:	DRAWHORZ 	0, 1
.drawShiftUp:		DRAWVERT	1, 1
.drawShiftDown:		DRAWVERT	0, 1

.drawRight:			DRAWHORZ	0, 0
.drawLeft:			DRAWHORZ	1, 0
.drawDown:			DRAWVERT	0, 0
.drawUp:			DRAWVERT	1, 0

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
				if state == PLAYER_GO_UP
					ld			de, UndoPlayerMoveUp
				elseif state == PLAYER_GO_DOWN
					ld			de, UndoPlayerMoveDown
				elseif state == PLAYER_GO_LEFT
					ld			de, UndoPlayerMoveLeft
				elseif state == PLAYER_GO_RIGHT
					ld			de, UndoPlayerMoveRight
				endif
					call		AddUndo
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
					ld			de, UndoPlayerShiftUp
				elseif state == PLAYER_GO_DOWN
					dec			b
					ld			de, -32
					add			hl, de
					ld			de, UndoPlayerShiftDown
				elseif state == PLAYER_GO_LEFT
					inc			c
					inc			hl
					ld			de, UndoPlayerShiftLeft
				elseif state == PLAYER_GO_RIGHT
					dec			c
					dec			hl
					ld			de, UndoPlayerShiftRight
				endif
					ld			(hl), ' '
					call		AddUndo
					ld			a, shift
					jr			.doGo

					endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

					macro		UNDOMOVE state

					ld			a, (ix+SPLAYER.time)
					dec			a
					cp			0xff
					jr			z, .undoMoveDone
					ld			(ix+SPLAYER.time), a
					ret
.undoMoveDone:		ld			(ix+SPLAYER.state), PLAYER_IDLE
					ld			(ix+SPLAYER.time), 0
				if state == PLAYER_UNDO_GO_LEFT
					inc			(ix+SPLAYER.x)
					jp			.idle
				elseif state == PLAYER_UNDO_GO_RIGHT
					dec			(ix+SPLAYER.x)
					jp			.idle
				elseif state == PLAYER_UNDO_GO_UP
					inc			(ix+SPLAYER.y)
					jp			.idle
				elseif state == PLAYER_UNDO_GO_DOWN
					ld			c, (ix+SPLAYER.x)
					ld			b, (ix+SPLAYER.y)
					dec			b
					ld			(ix+SPLAYER.y), b
					ld			d, 8
					jp			DrawEmptyByte
				elseif state == PLAYER_UNDO_SHIFT_LEFT || state == PLAYER_UNDO_SHIFT_RIGHT || state == PLAYER_UNDO_SHIFT_UP || state == PLAYER_UNDO_SHIFT_DOWN
					ld			c, (ix+SPLAYER.x)
					ld			b, (ix+SPLAYER.y)
					push		bc
					ld			a, SPHERE_ATTR
					ld			de, 0
					ld			hl, 0x100
					call		DrawChar
					pop			bc
				  if state == PLAYER_UNDO_SHIFT_LEFT	
					inc			c
				  elseif state == PLAYER_UNDO_SHIFT_RIGHT
					dec			c
				  elseif state == PLAYER_UNDO_SHIFT_UP
					inc			b
				  elseif state == PLAYER_UNDO_SHIFT_DOWN
					dec			b
				  endif	
					ld			(ix+SPLAYER.x), c
				  if state == PLAYER_UNDO_SHIFT_LEFT	
					dec			c
					dec			c
				  elseif state == PLAYER_UNDO_SHIFT_RIGHT
					inc			c
					inc			c
				  elseif state == PLAYER_UNDO_SHIFT_UP
					dec			b
					dec			b
				  elseif state == PLAYER_UNDO_SHIFT_DOWN
					inc			b
					inc			b
				  endif	
					call		GetLevelAddr
					ld			(hl), ' '
				  if state == PLAYER_UNDO_SHIFT_LEFT
					inc			hl
				  elseif state == PLAYER_UNDO_SHIFT_RIGHT
				  	dec			hl
				  elseif state == PLAYER_UNDO_SHIFT_UP
				  	ld			de, 32
					add			hl, de
				  elseif state == PLAYER_UNDO_SHIFT_DOWN
				  	ld			de, -32
					add			hl, de
				  endif	
					ld			(hl), 'O'
					ld			a, FLOOR_ATTR
					ld			de, 0
					ld			hl, 0x201
					call		DrawChar
					jp			.idle
				endif

					endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
					jp			.undoMoveLeft
					jp			.undoMoveRight
					jp			.undoMoveUp
					jp			.undoMoveDown
					jp			.undoShiftLeft
					jp			.undoShiftRight
					jp			.undoShiftUp
					jp			.undoShiftDown

.undoMoveLeft:		UNDOMOVE	PLAYER_UNDO_GO_LEFT
.undoMoveRight:		UNDOMOVE	PLAYER_UNDO_GO_RIGHT
.undoMoveUp:		UNDOMOVE	PLAYER_UNDO_GO_UP
.undoMoveDown:		UNDOMOVE	PLAYER_UNDO_GO_DOWN

.undoShiftLeft:		UNDOMOVE	PLAYER_UNDO_SHIFT_LEFT
.undoShiftRight:	UNDOMOVE	PLAYER_UNDO_SHIFT_RIGHT
.undoShiftUp:		UNDOMOVE	PLAYER_UNDO_SHIFT_UP
.undoShiftDown:		UNDOMOVE	PLAYER_UNDO_SHIFT_DOWN

.move:				ld			a, (ix+SPLAYER.time)
					inc			a
					cp			(8<<PLAYER_MOVE_DELAY_BITS)
					jr			z, .moveDone
					ld			(ix+SPLAYER.time), a
					ret
.moveDone:			ld			(ix+SPLAYER.state), PLAYER_IDLE
					ld			(ix+SPLAYER.time), 0
					;jr			.idle

.idle:				ld			hl, Input.undo
					xor			a
					cp			(hl)
					jp			z, UndoLastMove

					inc			hl
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
