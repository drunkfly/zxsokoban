
					org			8000h
						
INTERRUPT = 81h

irq_vectors:		dup			257
					db			INTERRUPT
					edup

					ds			(INTERRUPT*256+INTERRUPT)-$

					org			(INTERRUPT*256+INTERRUPT)

interrupt:			push		af
					push		bc
					push		de
					push		hl
					ex			af, af'
					exx
					push		af
					push		bc
					push		de
					push		hl
					push		ix
					push		iy

					ld			hl, FramesPending
					inc			(hl)

					; рисуем спрайты

					ld			ix, player1
					call		DrawPlayer

					; готово

					pop			iy
					pop			ix
					pop			hl
					pop			de
					pop			bc
					pop			af
					ex			af, af'
					exx
					pop			hl
					pop			de
					pop			bc
					pop			af
					ei
					ret
