
                ; Input:
                ;   A = number to convert
                ;   C = X координата
                ;   B = Y координата
                ;   D = атрибут
                ;   E = 1=пропустить незначащие нули, 0=не пропускать

DrawNumber: 	ld			hl, .attr+1
				ld			(hl), d
				; преобразование число->строка
				exx
				ld          hl, .buffer
                ld          c, -100
                call        .divide
                ld          c, -10
                call        .divide
                ld          c, -1
                call        .divide
                exx
				; пропускаем незначащие нули
                ld          hl, .buffer
                xor         a
                cp			e
                jr			z, .draw
                ; пропускаем ли первый символ?
                or          (hl)
                jr          nz, .draw
                inc         hl
                ; пропускаем ли второй символ?
                or          (hl)
                jr          nz, .draw
                inc         hl
.draw:        	ex			de, hl
.drawLoop:		ld          a, (de)
                cp          0xff
                ret         z
                push		de
                push		bc
				add			a, '0'
                ld			l, a
.attr:			ld			a, 0
                call		DrawChar
                pop			bc
                pop			de
                inc			c			; увеличили X
                inc         de			; следующий символ в буфере
                jr          .drawLoop
                ret

				; деление циклом
				; вход: A - делимое, С - делитель
				; результат: B - частное, A - остаток
.divide:        ld          b, -1
.divideLoop:    inc         b
                add         a, c
                jr          c, .divideLoop
                sub         c
				; записываем результат в буфер
                ld          (hl), b
                inc         hl
                ret

.buffer:        db          '???',0xff
