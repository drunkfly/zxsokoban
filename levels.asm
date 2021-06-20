
Levels:				dw			Level1
					dw			Level2
LevelsEnd:
TOTAL_LEVELS = (LevelsEnd - Levels) / 2

					; пробел - пустое место
					; X - стена
					; 1 - точка старта
					; O - шарик (ящик)
					; * - куда привезти шарик, чтобы выиграть

Level1:				db			"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
					db			"X                              X"
					db			"X                              X"
					db			"X                              X"
					db			"X                              X"
					db			"X                              X"
					db			"X                              X"
					db			"X                              X"
					db			"X        *  O1                 X"
					db			"X                              X"
					db			"X           *  O               X"
					db			"X                              X"
					db			"X                              X"
					db			"X XXX XXX X X XXX XXX  X  XX X X"
					db			"X X   X X X X X X X X X X XX X X"
					db			"X XXX X X XX  X X XX  XXX X XX X"
					db			"X   X X X X X X X X X X X X XX X"
					db			"X XXX XXX X X XXX XXX X X X  X X"
					db			"X                              X"
					db			"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

Level2:				db			"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
					db			"X                              X"
					db			"X                              X"
					db			"X                              X"
					db			"X                              X"
					db			"X          1                   X"
					db			"X      XX              XX      X"
					db			"X      XX      *  O    XX      X"
					db			"X                              X"
					db			"X              O  *            X"
					db			"X                              X"
					db			"X     XX                XX     X"
					db			"X      XX              XX      X"
					db			"X        XXXXXXXXXXXXXX        X"
					db			"X                              X"
					db			"X                              X"
					db			"X                              X"
					db			"X                              X"
					db			"X                              X"
					db			"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
