
MAX_UNDO 			equ			16

					struct 		UNDO
x 					byte
y 					byte
proc				word
					ends

					; Input:
					;   HL => undo buffer address
					; Output:
					;   HL => wrapped buffer address

WrapUndo:			ld			a, low UndoBufferEnd
					cp			l
					ret			nz
					ld			a, high UndoBufferEnd
					cp			h
					ret			nz
					ld			hl, UndoBuffer
					ret

					; Input:
					;   HL => undo buffer address
					; Output:
					;   HL => wrapped buffer address

WrapUndoBackwards:	ld			a, low UndoBuffer
					cp			l
					ret			nz
					ld			a, high UndoBuffer
					cp			h
					ret			nz
					ld			hl, UndoBufferEnd
					ret

					; Input:
					;   C = X
					;   B = Y
					;   DE => undo procedure

AddUndo:			ld			hl, (UndoHead)
					ld			(hl), c
					inc			hl
					ld			(hl), b
					inc			hl
					ld			(hl), e
					inc			hl
					ld			(hl), d
					inc			hl
					call		WrapUndo
					ld			(UndoHead), hl
					ld			de, (UndoTail)
					ld			a, e
					cp			l
					ret			nz
					ld			a, d
					cp			h
					ret			nz
					ld			de, 4
					add			hl, de
					call		WrapUndo
					ld			(UndoTail), hl
					ret

UndoPlayerShiftLeft:ld			a, PLAYER_UNDO_SHIFT_LEFT
					jr			UndoPlayerMove
UndoPlayerShiftRight:ld			a, PLAYER_UNDO_SHIFT_RIGHT
					jr			UndoPlayerMove
UndoPlayerShiftUp:	ld			a, PLAYER_UNDO_SHIFT_UP
					jr			UndoPlayerMove
UndoPlayerShiftDown:ld			a, PLAYER_UNDO_SHIFT_DOWN
					jr			UndoPlayerMove
UndoPlayerMoveLeft:	ld			a, PLAYER_UNDO_GO_LEFT
					jr			UndoPlayerMove
UndoPlayerMoveRight:ld			a, PLAYER_UNDO_GO_RIGHT
					jr			UndoPlayerMove
UndoPlayerMoveUp:	ld			a, PLAYER_UNDO_GO_UP
					jr			UndoPlayerMove
UndoPlayerMoveDown:	ld			a, PLAYER_UNDO_GO_DOWN
					;jr			UndoPlayerMove
UndoPlayerMove:		ld			(ix+SPLAYER.y), b
					ld			(ix+SPLAYER.x), c
					ld			(ix+SPLAYER.state), a
					ld			(ix+SPLAYER.time), (8<<PLAYER_MOVE_DELAY_BITS)-1
					ret

					; Input
					;   IX => Player

UndoLastMove:		ld			de, (UndoTail)
					ld			hl, (UndoHead)
					ld			a, e
					cp			l
					jr			nz, .notEmpty
					ld			a, d
					cp			h
					ret			z
.notEmpty:			call		WrapUndoBackwards
					dec			hl
					ld			d, (hl)
					dec			hl
					ld			e, (hl)
					dec			hl
					ld			b, (hl)
					dec			hl
					ld			c, (hl)
					ld			(UndoHead), hl
					ex			de, hl
					jp			(hl)
