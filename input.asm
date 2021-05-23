
ReadInput:			ld			bc, 0xfbfe
					in			a, (c)
					and			1					; Q
					ld			(Input.up), a

					ld			bc, 0xfdfe
					in			a, (c)
					and			1					; A
					ld			(Input.down), a

					ld			bc, 0xdffe
					in			a, (c)
					ld			b, a
					and			2					; O
					ld			(Input.left), a

					ld			a, b
					and			1					; P
					ld			(Input.right), a

					ld			bc, 0x7ffe
					in			a, (c)
					and			1					; Space
					ld			(Input.fire), a

					ret
					
Input:
.left:				db			1
.right:				db			1
.up:				db			1
.down:				db			1
.fire:				db			1
