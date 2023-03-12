.model tiny

.code
org 100h
locals @@


; Macros to exit
EXIT 		macro
		nop
		mov ax, 4c00h
		int 21h
		nop
		endm

start:

		mov bx, 0b800h
		mov es, bx

		call ClearScr

		mov bx, 3005h
		mov cx, 0a0ah
		mov ax, offset default_style
		mov dx, offset some_text

		push ax		; saving registers
		push bx		; saving registers
		push cx		; saving registers
		push dx		; saving registers
		push si		; saving registers

		call DrawFrame

		EXIT

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
; Draws the frame and its contents
; -------------------------------------
; Expects : ES->video seg

; Exit : none

; Needs : bx - left top angle coords in format (XXYYh), cx - dimensions of work area in format (XXYYh), ax - ptr to 6 chars of full format (CCCCh), dx - ptr to text ending in an $

; Destroys : ax, bx, cx, dx
; =====================================
DrawFrame	proc

		push bx
		push ax
		xor ax, ax
		mov al, bl
		mov si, 160d
		mul si
		mov bx, ax
		xor ax, ax
		xor si, si
		pop ax
		mov si, bx
		pop bx			;bx = bh + bl * 160d
		xor bl, bl
		mov bl, bh
		xor bh, bh
		add bx, si
		xor si, si
		push bx 		;saves initial coords in a good form

		push cx
		xor cl, cl
		mov cl, ch
		xor ch, ch

		mov si, ax
		mov ax, [si + 4]	; Draw top left angle
		mov es:[bx], ax


		add bx, 2d
		mov ax, [si]

		call DrawX		; Draw upper horizontal line

		mov ax, [si + 6]
		mov es:[bx], ax		; Draw top right angle

		pop cx
		pop bx
		push bx
		add bx, 160d

		push ax
		push cx
		xor ax, ax
		mov ax, 160d
		xor ch, ch
		mul cx			; Add 160d * cl to bx
		mov cx, ax
		xor ax, ax
		add bx, cx
		xor cx, cx
		pop cx
		pop ax

		push cx
		xor cl, cl
		mov cl, ch		; set cl = ch
		xor ch, ch

		mov ax, [si + 8]
		mov es:[bx], ax 	; Bottom left angle
		add bx, 2d

		mov ax, [si]		; Set horizontal line symbol

		call DrawX

		mov ax, [si + 10]
		mov es:[bx], ax		; Bottom right angle

		pop cx
		pop bx			; restore bx and cx

		push bx
		push cx			; Save bx and cx

		xor ch, ch

		add bx, 160d

		mov ax, [si + 2]	; Set current draw symbol to vert line

		call DrawY

		xor cx, cx
		xor bx, bx		; Restore bx and cx
		pop cx
		pop bx
		push bx
		push cx

		xor cl, cl
		mov cl, ch		; cx = chcl -> cx = 00ch
		xor ch, ch

		add bx, 162d
		add bx, cx
		add bx, cx

		pop cx
		push cx

		xor ch, ch

		mov ax, [si + 2]

		call DrawY

		pop cx
		pop bx

		EXIT

		ret
		endp


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

; Destroys : cx
; -------------------------------------

DrawY		proc

@@Next:		mov es:[bx], ax
		add bx, 160d
		loop @@Next
		ret

		endp

.data

		default_style dw 09cdh, 09bah, 09c9h, 09bbh, 09c8h, 09bch
		some_text db 'i am gae$'
		wallX dw 09cdh
		wallY dw 09bah

end start