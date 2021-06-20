
LEVEL_WIDTH 		equ		 	32
LEVEL_HEIGHT 		equ 		20

FLOOR_ATTR 			equ 		01001111b
SPHERE_ATTR 		equ 		01001110b
WALL_ATTR  			equ 		00001101b
TARGET_ATTR			equ			01001010b

InitLevel:			xor			a
					ld			(NumTargets), a
					ld			(NumCorrectTargets), a

					ld			h, a	; H = 0
					ld			a, (CurrentLevel)
					add			a, a
					ld			l, a
					ld			bc, Levels
					add			hl, bc
					ld			a, (hl)	; читаем адрес данных уровня
					inc			hl
					ld			h, (hl)
					ld			l, a	; HL => указывает на данные уровня

					; копируем данные уровня
					ld			de, Level
					ld			bc, LEVEL_WIDTH * LEVEL_HEIGHT
					ldir

					ld			hl, LevelEnd
					ld			c, LEVEL_HEIGHT
.rowLoop:			ld			b, LEVEL_WIDTH
.colLoop:			dec			hl
					ld			a, (hl)
					cp			a, '1'
					call		z, .handlePlayerStart
					cp			a, '*'
					call		z, .handleTarget
					djnz		.colLoop
					dec			c
					jr			nz, .rowLoop
					ld			hl, UndoBuffer
					ld			(UndoHead), hl
					ld			(UndoTail), hl
					ret
.handlePlayerStart:	ld			(hl), ' '
					ld			a, b
					dec			a
					ld			(player1.x), a
					ld			a, c
					dec			a
					ld			(player1.y), a
					ret
.handleTarget:		ld			(hl), ' '
					ld			a, (NumTargets)
					cp			MAX_TARGETS
					ret			z
					inc			a
					ld			(NumTargets), a
					add			a, a
					ld			e, a
					ld			d, high Targets
					ld			a, b
					dec			a
					ld			(de), a			; target X
					inc			de
					ld			a, c
					dec			a
					ld			(de), a			; target Y
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
					jr			.drawSprite
.drawSphere:		ld			a, SPHERE_ATTR
					ld			de, 0x100
					jr			.drawSprite
.drawWall:			ld			a, WALL_ATTR
					ld			de, 0x200
					;jr			.drawSprite
.drawSprite:		push		bc
					push		hl
					dec			b
					dec			c
					ld			hl, 0
					ex			de, hl
					call		DrawSprite
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

					; Returns:
					;   C = количество точек, где уже есть шар

DrawTargets:		ld			a, (NumTargets)
					or			a
					ret			z
					ld			b, a
					ld			c, 0			; количество точек, на которых уже стоит шар
					ld			ix, Targets
					ld			de, 2
.loop:				exx
					ld			c, (ix+0)
					ld			b, (ix+1)
					call		CheckBlocked
					jr			nz, .blocked
					ld			hl, 0x202
.draw:				ld			a, TARGET_ATTR
					ld			de, 0
					call		DrawSprite
.skip:				exx
					add			ix, de
					djnz		.loop
					ret
.blocked:			cp			'O'
					jr			nz, .skip
					exx
					inc			c
					exx
					ld			hl, 0x100
					jr			.draw
