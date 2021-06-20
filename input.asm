
ReadInput:			ld			hl, AnyKey
					ld			(hl), 0x1f

					ld			bc, 0xa6fe
					in			a, (c)
					and			(hl)				; обновляем AnyKey
					ld			(hl), a

					ld			bc, 0xfbfe
					in			a, (c)
					ld			b, a
					and			(hl)				; обновляем AnyKey
					ld			(hl), a

					ld			a, b
					and			1					; Q
					ld			(Input.up), a

					ld			a, b
					and			8					; R
					ld			(Input.restart), a

					ld			bc, 0xfdfe
					in			a, (c)
					ld			b, a
					and			(hl)				; обновляем AnyKey
					ld			(hl), a

					ld			a, b
					and			1					; A
					ld			(Input.down), a

					ld			bc, 0xdffe
					in			a, (c)
					ld			b, a
					and			(hl)				; обновляем AnyKey
					ld			(hl), a

					ld			a, b
					and			2					; O
					ld			(Input.left), a

					ld			a, b
					and			1					; P
					ld			(Input.right), a

					ld			a, b
					and			8					; U
					ld			(Input.undo), a

					ld			bc, 0x7ffe
					in			a, (c)
					ld			b, a
					and			(hl)				; обновляем AnyKey
					ld			(hl), a

					ld			a, b
					and			1					; Space
					ld			(Input.fire), a

					ret
					
Input:
.undo:				db			1
.left:				db			1
.right:				db			1
.up:				db			1
.down:				db			1
.fire:				db			1
.restart:			db			1

AnyKey				db			0x1f
