
LEVEL_WIDTH 		equ		 	32
LEVEL_HEIGHT 		equ 		20

FLOOR_ATTR 			equ 		01001111b
SPHERE_ATTR 		equ 		01001110b
WALL_ATTR  			equ 		00001101b

					; пробел - пустое место
					; X - стена
					; 1 - точка старта

Level:				db			"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
					db			"X                              X"
					db			"X                              X"
					db			"X                      O       X"
					db			"X   O                          X"
					db			"X                              X"
					db			"X        1                     X"
					db			"X                              X"
					db			"X           O                  X"
					db			"X                        O     X"
					db			"X              O               X"
					db			"X                              X"
					db			"X                              X"
					db			"X XXX XXX X X XXX XXX  X  XX X X"
					db			"X X   X X X X X X X X X X XX X X"
					db			"X XXX X X XX  X X XX  XXX X XX X"
					db			"X   X X X X X X X X X X X X XX X"
					db			"X XXX XXX X X XXX XXX X X X  X X"
					db			"X                              X"
					db			"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
LevelEnd:

InitLevel:			ld			hl, LevelEnd
					ld			c, LEVEL_HEIGHT
.rowLoop:			ld			b, LEVEL_WIDTH
.colLoop:			dec			hl
					ld			a, (hl)
					cp			a, '1'
					call		z, .handlePlayerStart
					djnz		.colLoop
					dec			c
					jr			nz, .rowLoop
					ret
.handlePlayerStart:	ld			(hl), ' '
					ld			a, b
					dec			a
					ld			(player1.x), a
					ld			a, c
					dec			a
					ld			(player1.y), a
					ret

DrawLevel:			ld			hl, LevelEnd
					ld			b, LEVEL_HEIGHT
.rowLoop:			ld			c, LEVEL_WIDTH
.colLoop:			dec			hl
					ld			a, (hl)
					cp			a, ' '
					call		z, .drawFloor
					cp			a, 'X'
					call		z, .drawWall
					cp			a, 'O'
					call		z, .drawSphere
					dec			c
					jr			nz, .colLoop
					djnz		.rowLoop
					ret
.drawFloor:			ld			a, FLOOR_ATTR
					ld			de, 0x201
					jr			.drawChar
.drawSphere:		ld			a, SPHERE_ATTR
					ld			de, 0x100
					jr			.drawChar
.drawWall:			ld			a, WALL_ATTR
					ld			de, 0x200
					;jr			.drawChar
.drawChar:			push		bc
					push		hl
					dec			b
					dec			c
					ld			hl, 0
					ex			de, hl
					call		DrawChar
					pop			hl
					pop			bc
					ret

					; Input:
	                ;   C = X (знакоместо)
    	            ;   B = Y (знакоместо)
    	            ; Output:
    	            ;	A = предмет на карте
    	            ;   ZF=0 если ходить нельзя, ZF=1 если ходить можно

CheckBlocked:		call		GetLevelAddr
					ld			a, (hl)
					cp			a, ' '
					ret

					; Input:
	                ;   C = X (знакоместо)
    	            ;   B = Y (знакоместо)
    	            ; Output:
    	            ;	HL => адрес внутри Level

GetLevelAddr:		; HL = B * 32 + C; 32 = LEVEL_WIDTH
					ld			l, b
					ld			h, 0
					ld			e, c
					ld			d, h
					add			hl, hl			; *2
					add			hl, hl			; *4
					add			hl, hl			; *8
					add			hl, hl			; *16
					add			hl, hl			; *32
					add			hl, de
					ld			de, Level
					add			hl, de
					ret
