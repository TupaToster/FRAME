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

		xor ax, ax
		xor cx, cx
		xor dx, dx
		xor bx, bx

		call GetArgs

		push cx
		push bx
		mov bx, 0b800h
		mov es, bx

		call ClearScr

		pop bx
		pop cx

		; mov bx, 3005h
		mov cx, 0a0ah
		mov ax, offset style
		mov dx, offset text

		push ax		; saving registers
		push bx		; saving registers
		push cx		; saving registers
		push dx		; saving registers
		push si		; saving registers

		call DrawFrame

		pop si		; restoring regs
		pop dx		; restoring regs
		pop cx		; restoring regs
		pop bx		; restoring regs
		pop ax		; restoring regs

		EXIT

; ------------------------------------
; Reads all the args from command line args
; ------------------------------------
; Expects : none

; Exit : everything that DrawFrame needs in a proper format

; Needs : none

; destroys : si
; ====================================
GetArgs 	proc

		mov si, 82h

		cmp byte ptr [si], '-'
		jne @@noHelp
		cmp byte ptr [si + 1], 'h'
		jne @@noHelp
		mov ah, 09h
		mov dx, offset help_message
		int 21h
		EXIT

@@noHelp:	call Get2H

		push ax 	; Saves ax

		call Get2H

		xor dx, dx
		mov dl, al
		xor ax, ax
		pop ax		; Makes ax into desired format of XXYYh to move to bx
		xchg ah, al
		add al, dl
		xor dx, dx

		mov bx, ax
		xor ax, ax

		ret
		endp
; ------------------------------------
; Gets a 2 - digit hex number from com line
; ------------------------------------
; Expects : si -> current com line position

; Exit : al = read number

; Needs : none

; Destroys : ax, dx
; ====================================
Get2H		proc

		xor ax, ax
		lodsb		;Reads one by one to skip excess spaces

@@skipSpace:	cmp al, ' '
		jne @@noSkipSpace
		xor ax, ax
		lodsb
		jmp @@skipSpace

@@noSkipSpace:	sub si, 1
		xor ax, ax
		lodsw 		;Reads to digit hex num to ax
		xchg al, ah

		cmp al, 'a'
		jae @@lowCaseAl

		cmp al, 'A'
		jae @@upCaseAl

		sub al, '0'
		jmp @@endOfConvAl

@@lowCaseAl:	sub al, 'a'
		jmp @@endOfConvAl

@@upCaseAl:	sub al, 'A'

@@endOfConvAl:	cmp ah, 'a'
		jae @@lowCaseAh

		cmp ah, 'A'
		jae @@upCaseAh

		sub ah, '0'
		jmp @@endOfConvAh

@@lowCaseAh:	sub ah, 'a'
		jmp @@endOfConvAh

@@upCaseAh:	sub ah, 'A'

@@endOfConvAh:

		push ax
		xor al, al
		mov dx, 10h
		mul dx
		pop dx
		mov al, dl
		add al, ah
		xor ah, ah

		ret
		endp

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

		style dw 09cdh, 09bah, 09c9h, 09bbh, 09c8h, 09bch
		text db 'i am gae$'
		wallX dw 09cdh
		wallY dw 09bah
		help_message db 'usage: (length of name represents required amount of digits, except for the text. All numbers are hex.)', 0ah, 0dh, 'frame.com X0 Y0 LX LY FRXL FRYL FLTC FRTC FLBC FRBC TEXT_TO_BE_DISPLAYED', 0ah, 0dh, 'Where  : ', 0ah, 0dh, 'X0 - left top X coord in range [00h, 50h]', 0ah, 0dh, 'Y0 - left top Y coord in range [00h, 1Eh]', 0ah, 0dh, 'LX - X length of working zone', 0ah, 0dh, 'LY - Y length of working zone', 0ah, 0dh, 'FRXL, FRYL - hex codes of horizontal and vertical line symbols', 0ah, 0dh, "FLTC, FRTC, FLBC, FRBC - left top, right top, left bottom and right bottom angles' codes", 0ah, 0dh, "TEXT_TO_BE_DISPLAYED - the text", 0ah, 0dh, '$'

end start