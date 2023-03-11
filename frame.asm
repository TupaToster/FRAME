.model tiny
.186

.code
org 100h
locals @@


; Macros to exit
EXIT 		macro
		mov ax, 4c00h
		int 21h
		endm

; just to test my git abilities
start:

		mov bx, 0b800h
		mov es, bx

		call ClearScr

		mov bx, 160d*5d + 60d
		mov cx, 9d
		mov ax, wallX

		mov es:[bx], 09c9h
		add bx, 2

		call DrawX

		mov es:[bx], 09bbh

		mov bx, 160d * 6d + 60d
		mov cx, 9d
		mov ax, wallY

		call DrawY

		mov es:[bx], 09c8h

		mov bx, 160d * 15d + 62d
		mov cx, 9d
		mov ax, wallX

		call DrawX

		mov es:[bx], 09bch

		mov bx, 160d * 6d + 80d
		mov cx, 9d
		mov ax, wallY

		call DrawY

		EXIT
; -------------------------------------
; Clears the screen
; -------------------------------------
; Expects : Es->video seg

; Exit : none

; Destroys : bx, ax, CX
; ------------------------------------

ClearScr	proc

		mov al, 0dbh
		mov ah, 00000000b
		xor bx, bx
		mov cx, 80d * 25d
@@Next:		mov es:[bx], ax
		add bx, 2
		loop @@Next
		ret
		endp
; -------------------------------------

; -------------------------------------
; Draws horizontal line 
; -------------------------------------
; Expects : ES -> video seg

; Exit : bx - position after the last drawn symbol

; Needs : BX (starting pos), AX (symbol to draw), CX (count)

; Destroys : cx
; -------------------------------------

DrawX		proc

@@Next:		mov es:[bx], ax
		add bx, 2d
		loop @@Next
		ret

		endp


; -------------------------------------
; Draws vertical line
; -------------------------------------
; Expects : ES -> video seg

; Exit : bx - position after the last drawn symbol

; Needs : BX (starting pos), AX (symbol to draw), CX (count)

; Destroys : all that it Needs
; -------------------------------------

DrawY		proc

@@Next:		mov es:[bx], ax
		add bx, 160d
		loop @@Next
		ret

		endp

.data

		wallX dw 09cdh
		wallY dw 09bah

end start