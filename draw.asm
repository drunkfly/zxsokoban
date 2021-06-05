
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

                ; Input:
                ;	A = атрибут
                ;   E = дополнительный сдвиг по X (-7..7)
                ;   D = дополнительный сдвиг по Y (-7..7)
                ;   L = X спрайта (знакоместо)
                ;   H = Y спрайта (знакоместо)
                ;   C = X (знакоместо)
                ;   B = Y (знакоместо)

DrawChar:    	; Сохраняем А
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
				ld      (hl), a
                call	DownHL
                djnz    .empty
                jp		.charDone

.shiftM7:       ld      a, (de)
				rrca
				and		0x80
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shiftM7
                jp		.charDone

.shiftM6:       ld      a, (de)
				rrca
				rrca
				and		0xc0
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
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shiftM3
                jp		.charDone

.shiftM2:       ld      a, (de)
				rlca
				rlca
				and		0xfc
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shiftM2
                jr		.charDone

.shiftM1:       ld      a, (de)
				sla		a
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shiftM1
                jr		.charDone

.noShift:       ld      a, (de)
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .noShift
                jr		.charDone

.shift1:       	ld      a, (de)
				srl		a
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shift1
                jr		.charDone

.shift2:       	ld      a, (de)
				rrca
				rrca
				and		0x3f
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
                ld      (hl), a
                inc     d
                call	DownHL
                djnz    .shift6
                jr		.charDone

.shift7:       	ld      a, (de)
				rlca
				and		0x01
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
