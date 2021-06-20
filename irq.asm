
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

.drawEnabled:		ld			a, 0
					or			a
					jr			z, .skipDraw

					; рисуем спрайты

					call		DrawTargets
					ld			a, c
					ld			(NumCorrectTargets), a

					ld			ix, player1
					call		DrawPlayer

					; рисуем статус

					ld			a, (NumCorrectTargets)
					ld			bc, 0x1502
					ld			de, 0x4700
					call		DrawNumber

					ld			a, (NumTargets)
					ld			bc, 0x1506
					ld			de, 0x4700
					call		DrawNumber

.skipDraw:

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

DrawEnabled = .drawEnabled + 1
