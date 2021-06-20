
					device 		zxspectrum48

stack_top:

					include		"irq.asm"

start:				di
					ld			sp, stack_top
					ld			a, 80h
					ld			i, a
					im			2
					ei

					xor			a
					ld			(CurrentLevel), a

.gameLoop:			call		PlayLevel
					jr			z, .gameLoop

					ld			a, (CurrentLevel)
					inc			a
					cp			TOTAL_LEVELS
					jr			z, .gameDone
					ld			(CurrentLevel), a

					call		IntermediateScreen

					jr			.gameLoop

.gameDone:			xor			a
					call		ClearScreen
					ld			bc, 0x0C0C
					ld			de, .winMessage
					ld			ixh, 0xC4
					call		DrawString
.haltGameDone:		halt
					jr			.haltGameDone

.winMessage			db			'YOU WIN!',0

IntermediateScreen:	xor			a
					call		ClearScreen

.waitNoAnyKey:		halt
					call		ReadInput
					ld			a, (AnyKey)
					cp			0x1f
					jr			nz, .waitNoAnyKey

					ld			bc, 0x0C09
					ld			de, .levelMessage
					ld			ixh, 0xC4
					call		DrawString

.waitAnyKey:		halt
					call		ReadInput
					ld			a, (AnyKey)
					cp			0x1f
					jr			z, .waitAnyKey

					ret

.levelMessage		db			'LEVEL COMPLETE',0
					ret

PlayLevel:			xor			a
					call		ClearScreen

					call		InitLevel
					call		DrawLevel

					ld			ix, player1
					call		InitPlayer

					ld			a, 1
					ld			(DrawEnabled), a

.mainLoop:			ld			hl, FramesPending
					xor			a
					cp			(hl)
					jr			z, .halt
					dec			(hl)

					; Проверка конца уровня
					ld			hl, (NumTargets)		; NumTargets и NumCorrectTargets
					ld			a, l
					cp			h
					jr			nz, .notNextLevel
					ld			a, (player1.state)
					cp			PLAYER_IDLE
					jr			z, .nextLevel
.notNextLevel:

					call		ReadInput

					; Проверка рестарта
					ld			hl, Input.restart
					xor			a
					cp			(hl)
					jr			z, .restartLevel

					ld			ix, player1
					call		HandlePlayer

					jr			.mainLoop

.halt:				halt
					jr			.mainLoop

.nextLevel:			xor			a
					ld			(DrawEnabled), a
					inc			a
					ret

.restartLevel:		xor			a
					ld			(DrawEnabled), a
					ret

FramesPending:		db			0

					include		"draw.asm"
					include		"input.asm"
					include		"level.asm"
					include		"levels.asm"
					include		"undo.asm"
					include		"util.asm"
					include		"player.asm"

					ds			0xa000-$
					org			0xa000

gfx:				incbin		"gfx/gfx.scr"

					include		"bss.asm"

					savesna 	"game.sna", start
					SLDOPT 		COMMENT WPMEM, LOGPOINT, ASSERTION
