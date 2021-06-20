
CHARS = 23606

				; Input:
				;   A = attribute

ClearScreen:	; очищаем пиксели
				ld		hl, 4000h
				ld      e, l
				ld		d, h
				ld		(hl), 0
				inc		de
				ld		bc, 1800h
				ldir
				; очищаем атрибуты
				ld		(hl), a
				ld		bc, 300h-1
				ldir
				ret

                ; Input:
                ;   C = X
                ;   B = Y (знакоместо)
                ;   IYH = старший байт адреса
                ; Output:
                ;   DE => screen addr

CalcScreenAddr: ; Преобразуем координату Y в пикселях в значение в знакоместах
                ld		a, b
                rla
                rla
                rla
                and		0xf8
; альтернативная точка входа, A = Y (пиксели)
CalcScreenAddrPix:
                ld		b, a
                ; Расчитываем адрес на экране
                rla                                 ; A = ? |Y5|Y4|Y3| ?| ?| ?| ?
                rla                                 ; A = Y5|Y4|Y3| ?| ?| ?| ?| ?
                and     0xe0            ; 1110 0000 ; A = Y5|Y4|Y3| 0| 0| 0| 0| 0
                or      c               ;             A = Y5|Y4|Y3|X4|X3|X2|X1|X0
                ld      e, a
                ld      a, b
                rra                           
                rra
                rra                                 ; A =  ?| ?| ?|Y7|Y6| ?| ?| ?
                and     0x18                        ; A =  0| 0| 0|Y7|Y6| 0| 0| 0
                ld      d, a
                ld      a, b
                and     0x07                        ; A =  0| 0| 0| 0| 0|Y2|Y1|Y0
                or      d                           ; A =  0| 0| 0|Y7|Y6|Y2|Y1|Y0
                or      iyh                         ; A =  0| 1| 0|Y7|Y6|Y2|Y1|Y0
                ld      d, a
                ret

                ; Input:
                ;   C = X (знакоместо)
                ;   B = Y (знакоместо)
                ;   D = дополнительный сдвиг по Y (-7..7)

DrawEmptyByte:	; Расчитываем адрес назначения
                ld		iyh, 0x40
                ld		a, b
                add		a, a		; *2
                add		a, a		; *4
                add		a, a		; *8
                add		a, d
    			call    CalcScreenAddrPix
    			; Записываем нулевой байт
    			xor		a
    			ld		(de), a
    			ret

DRAW_REPLACE 	equ		0			; nop
DRAW_OR			equ		0xB6		; or (hl)

                ; Input:
                ;   A = mode (DRAW_OR или DRAW_REPLACE)

SetDrawSpriteMode:
				ld		(DrawSprite.hotPatch1), a
				ld		(DrawSprite.hotPatch2), a
				ld		(DrawSprite.hotPatch3), a
				ld		(DrawSprite.hotPatch4), a
				ld		(DrawSprite.hotPatch5), a
				ld		(DrawSprite.hotPatch6), a
				ld		(DrawSprite.hotPatch7), a
				ld		(DrawSprite.hotPatch8), a
				ld		(DrawSprite.hotPatch9), a
				ld		(DrawSprite.hotPatch10), a
				ld		(DrawSprite.hotPatch11), a
				ld		(DrawSprite.hotPatch12), a
				ld		(DrawSprite.hotPatch13), a
				ld		(DrawSprite.hotPatch14), a
				ld		(DrawSprite.hotPatch15), a
				ld		(DrawSprite.hotPatch16), a
				ret

                ; Input:
                ;	A = атрибут
                ;   E = дополнительный сдвиг по X (-7..7)
                ;   D = дополнительный сдвиг по Y (-7..7)
                ;   L = X спрайта (знакоместо)
                ;   H = Y спрайта (знакоместо)
                ;   C = X (знакоместо)
                ;   B = Y (знакоместо)

DrawSprite:    	; Сохраняем А
                ex      af, af'
                ; Патчим код
                ld		a, e
                ld		(.hotPatch+2), a
				; Расчитываем адрес назначения
                ld		iyh, 0x40
                ld		a, b
                add		a, a		; *2
                add		a, a		; *4
                add		a, a		; *8
                add		a, d
    			call    CalcScreenAddrPix
                push	de
                ; Преобразуем координату Y спрайта в адрес в SCR
                ld		b, h
                ld		c, l
                ex		de, hl		; сохраню DE в HL
                ; Расчитываем адрес спрайта
                ld		iyh, high gfx
                call	CalcScreenAddr
				
				ld		iy, .table
.hotPatch:		ld		c, (iy+0)
				ld		b, 0
				add		iy, bc
                ld      b, 8		; счетчик для цикла
				jp		(iy)

				db		.empty-.table
				db		.shiftM7-.table
				db		.shiftM6-.table
				db		.shiftM5-.table
				db		.shiftM4-.table
				db		.shiftM3-.table
				db		.shiftM2-.table
				db		.shiftM1-.table
.table:			db		.noShift-.table
				db		.shift1-.table
				db		.shift2-.table
				db		.shift3-.table
				db		.shift4-.table
				db		.shift5-.table
				db		.shift6-.table
				db		.shift7-.table
				db		.empty-.table

.empty:       	xor		a
.hotPatch1:		nop
				ld      (hl), a
                call	DownHL
                djnz    .empty
                jp		.charDone

.shiftM7:       ld      a, (de)
				rrca
				and		0x80
.hotPatch2:		nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shiftM7
                jp		.charDone

.shiftM6:       ld      a, (de)
				rrca
				rrca
				and		0xc0
.hotPatch3:		nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shiftM6
                jp		.charDone

.shiftM5:       ld      a, (de)
				dup		3
				rrca
				edup
				and		0xe0
.hotPatch4:		nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shiftM5
                jp		.charDone

.shiftM4:       ld      a, (de)
				dup		4
				rlca
				edup
				and		0xf0
.hotPatch5:		nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shiftM4
                jp		.charDone

.shiftM3:       ld      a, (de)
				dup		3
				rlca
				edup
				and		0xf8
.hotPatch6:		nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shiftM3
                jp		.charDone

.shiftM2:       ld      a, (de)
				rlca
				rlca
				and		0xfc
.hotPatch7:		nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shiftM2
                jp		.charDone

.shiftM1:       ld      a, (de)
				sla		a
.hotPatch8:		nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shiftM1
                jr		.charDone

.noShift:       ld      a, (de)
.hotPatch9:		nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .noShift
                jr		.charDone

.shift1:       	ld      a, (de)
				srl		a
.hotPatch10:	nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shift1
                jr		.charDone

.shift2:       	ld      a, (de)
				rrca
				rrca
				and		0x3f
.hotPatch11:	nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shift2
                jr		.charDone

.shift3:       	ld      a, (de)
				dup		3
				rrca
				edup
				and		0x1f
.hotPatch12:	nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shift3
                jr		.charDone

.shift4:       	ld      a, (de)
				dup		4
				rrca
				edup
				and		0x0f
.hotPatch13:	nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shift4
                jr		.charDone

.shift5:       	ld      a, (de)
				dup		3
				rlca
				edup
				and		0x07
.hotPatch14:	nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shift5
                jr		.charDone

.shift6:       	ld      a, (de)
				dup		2
				rlca
				edup
				and		0x03
.hotPatch15:	nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shift6
                jr		.charDone

.shift7:       	ld      a, (de)
				rlca
				and		0x01
.hotPatch16:	nop
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shift7
                ;jr		.charDone

.charDone: 		; Получаем из стека начальный адрес на экране
				pop		hl
				ld		c, h				; сохраняем старший байт в C для проверки внизу
				; Расчитываем адрес в области атрибутов
                ld      a, h
       			rra
                rra
                rra
                and     0x03
                or      0x58
                ld      h, a
                ; Восстанавливаем A
                ex      af, af'
                ; Записываем атрибут
                ld      (hl), a
                ; Сохраняем атрибут в B
                ld		b, a
                ; Проверяем, нужно ли рисовать второй атрибут
                ld		a, 7
                and		c
                ret		z				; мы на границе знакоместа, второй атрибут не нужен
				; Переходим на следующую строку в атрибутах
                ld		de, 32
                add		hl, de
				; Записываем второй атрибут
                ld		(hl), b
                ret

                ; Input:
                ;	HL => адрес байта (8 пикселей) на экране
                ; Output:
                ;   HL => адрес байта (8 пикселей) в следующей строке (Y = Y + 1)

DownHL:			inc		h
				ld		a, 00000111b	; 7=8-1;  остаток от деления на 8 
				and		h
				ret		nz
				ld		a, l			; L = L + 32
				sub		-32
				ld		l, a
				sbc		a, a			; 0 = no carry, -1 (0xff 11111111) = was carry
				and		-8				; 0 = no carry, -8 (0xf8 11111000) = was carry
				add		a, h
				ld		h, a
				ret

                ; Input:
                ;   L = symbol
                ;   A = attribute
                ;   C = X (знакоместо)
                ;   B = Y (знакоместо)

DrawChar:       ; Сохраняем А
                ex      af, af'
                ; Расчитываем адрес назначения
                ld		iyh, 0x40
                call    CalcScreenAddr
                ; Расчитываем адрес символа
                ld      h, 0
                add     hl, hl          ; HL+HL = HL*2
                add     hl, hl          ; (HL*2)+(HL*2) = HL*4
                add     hl, hl          ; HL*8
                ld      bc, (CHARS)
                add     hl, bc          ; HL => адрес пикселей символа
                ; Рисуем
                ld      b, 8
.loop:          ld      a, (hl)
                ld      (de), a
                inc     d
                inc     hl
                djnz    .loop
                ; Расчитываем адрес в области атрибутов
                dec     d
                ld      a, d
                rra
                rra
                rra
                and     0x03
                or      0x58
                ld      d, a
                ; Восстанавливаем A
                ex      af, af'
                ; Записываем атрибут
                ld      (de), a
                ret

                ; Input:
                ;   DE = строка
                ;	IXH = атрибут
                ;   C = X (знакоместо)
                ;   B = Y (знакоместо)

DrawString:		ld          a, (de)
                or			a
                ret         z
                push		de
                push		bc
                ld			l, a
				ld			a, ixh
                call		DrawChar
                pop			bc
                pop			de
                inc			c			; увеличили X
                inc         de			; следующий символ в буфере
                jr          DrawString
                ret
