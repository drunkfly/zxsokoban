
					ds			0xc000-$
					org			0xc000

					; don't move, code expects alignment 256 for Targets
					align		256
MAX_TARGETS = 8
NumTargets:			defs		1
NumCorrectTargets:	defs		1
Targets:			defs		2 * MAX_TARGETS

UndoHead:			defs		2
UndoTail:			defs		2
UndoBuffer:			defs		UNDO * MAX_UNDO
UndoBufferEnd:

Level:				defs		LEVEL_WIDTH * LEVEL_HEIGHT
LevelEnd:

CurrentLevel:		defs		1
