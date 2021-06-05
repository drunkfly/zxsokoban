
					device 		zxspectrum48

stack_top:

					include		"irq.asm"

start:				di
					ld			sp, stack_top
					ld			a, 80h
					ld			i, a
					im			2
					ei

					ld			a, 00h
					call		ClearScreen

					call		InitLevel
					call		DrawLevel

					ld			ix, player1
					call		InitPlayer

.mainLoop:			ld			hl, FramesPending
					xor			a
					cp			(hl)
					jr			z, .halt
					dec			(hl)

					call		ReadInput

					ld			ix, player1
					call		HandlePlayer

					jr			.mainLoop

.halt:				halt
					jr			.mainLoop

FramesPending:		db			0

					include		"draw.asm"
					include		"input.asm"
					include		"level.asm"
					include		"player.asm"

					ds			0xa000-$
					org			0xa000

gfx:				incbin		"gfx/gfx.scr"

					savesna 	"game.sna", start
					SLDOPT 		COMMENT WPMEM, LOGPOINT, ASSERTION
