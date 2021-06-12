
					ds			0xc000-$
					org			0xc000

UndoHead:			defs		2
UndoTail:			defs		2
UndoBuffer:			defs		UNDO * MAX_UNDO
UndoBufferEnd:
