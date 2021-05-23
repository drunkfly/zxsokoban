
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
                ;	A = атрибут
                ;   E = сдвиг (-7..7)
                ;   L = X спрайта (знакоместо)
                ;   H = Y спрайта (знакоместо)
                ;   C = X (знакоместо)
                ;   B = Y (знакоместо)
                ; Output:
                ;   DE => sprite address
                ;   HL => screen address

DrawChar:    	; Сохраняем А
                ex      af, af'
                ; Патчим код
                ld		a, e
                ld		(.hotPatch+2), a
				; Расчитываем адрес назначения
                ld		iyh, 0x40
                call    CalcScreenAddr
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
                inc     h
                djnz    .empty
                jp		.charDone

.shiftM7:       ld      a, (de)
				rrca
				and		0x80
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shiftM7
                jp		.charDone

.shiftM6:       ld      a, (de)
				rrca
				rrca
				and		0xc0
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shiftM6
                jp		.charDone

.shiftM5:       ld      a, (de)
				dup		3
				rrca
				edup
				and		0xe0
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shiftM5
                jp		.charDone

.shiftM4:       ld      a, (de)
				dup		4
				rlca
				edup
				and		0xf0
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shiftM4
                jr		.charDone

.shiftM3:       ld      a, (de)
				dup		3
				rlca
				edup
				and		0xf8
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shiftM3
                jr		.charDone

.shiftM2:       ld      a, (de)
				rlca
				rlca
				and		0xfc
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shiftM2
                jr		.charDone

.shiftM1:       ld      a, (de)
				sla		a
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shiftM1
                jr		.charDone

.noShift:       ld      a, (de)
                ld      (hl), a
                inc     d
                inc     h
                djnz    .noShift
                jr		.charDone

.shift1:       	ld      a, (de)
				srl		a
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shift1
                jr		.charDone

.shift2:       	ld      a, (de)
				rrca
				rrca
				and		0x3f
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shift2
                jr		.charDone

.shift3:       	ld      a, (de)
				dup		3
				rrca
				edup
				and		0x1f
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shift3
                jr		.charDone

.shift4:       	ld      a, (de)
				dup		4
				rrca
				edup
				and		0x0f
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shift4
                jr		.charDone

.shift5:       	ld      a, (de)
				dup		3
				rlca
				edup
				and		0x07
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shift5
                jr		.charDone

.shift6:       	ld      a, (de)
				dup		2
				rlca
				edup
				and		0x03
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shift6
                jr		.charDone

.shift7:       	ld      a, (de)
				rlca
				and		0x01
                ld      (hl), a
                inc     d
                inc     h
                djnz    .shift7
                ;jr		.charDone

.charDone: 		; Расчитываем адрес в области атрибутов
     			dec     h
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
                ret
