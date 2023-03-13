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
		xor dx, dx	; clearing regs of trash
		xor bx, bx

		mov ax, offset style

		call GetArgs

		push cx
		push bx		; saving bx, cx, ax
		push ax

		mov bx, 0b800h	; setting es to video mem
		mov es, bx

		call ClearScr

		pop ax
		pop bx
		pop cx		;restoring bx, cx, ax

		; mov bx, 3005h
		; mov cx, 0a0ah

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

; destroys : si, di
; ====================================
GetArgs 	proc

		mov di, ax 			; For use in getting style part
		xor ax, ax

		mov si, 82h

		cmp byte ptr [si], '-'
		jne @@noHelp
		cmp byte ptr [si + 1], 'h'
		jne @@noHelp			; If user typed -h it means that he needs help + bios wipe
		mov ah, 09h
		mov dx, offset help_message
		int 21h
		EXIT

@@noHelp:	call Get2H	; Generally gets initial coords of da frame

		push ax 	; Saves ax temporarily

		call Get2H

		xor bx, bx
		mov bl, al
		xor ax, ax
		pop ax		; Puts second al -> bl and first al -> bh
		mov bh, al
		xor ax, ax

		push bx		; Saves bx
		xor bx, bx
;--------------------------------------------------------
		call Get2H	; Gets Inside size of a frame

		push ax		; Saves ax temporarily

		call Get2H

		xor cx, cx
		mov ch, al
		xor ax, ax	; Puts al from first and al from second to ch and cl respectively
		pop ax
		mov cl, al
		xor ax, ax

		push cx		; Saves cx
		xor cx, cx
;--------------------------------------------------------
				; Gets style characters

@@Next:		call Get2H

		mov byte ptr [di + bx], al
		xor ax, ax			;Reads byte to ax, incs bx
		inc bx

		call Get2H

		mov byte ptr [di + bx], al
		xor ax, ax			; Reads next byter to ax, incs bx
		inc bx

		mov ax, [di + bx - 2]
		xchg ah, al			; xchgs 2 byter in memory
		mov [di + bx - 2], ax

		cmp bx, 12d			; loop for all the styles (which is 6 words) to be read
		jb @@Next

		push di			; Saves result for it to be placed back to ax right before ret
		xor di, di

;----------------------------------------------------
				;Gets style byte of the text

		call Get2H

		mov textStyleByte, al

		xor ax, ax

;-----------------------------------------------------

				; Gets text that is to be written

		xor ax, ax
		lodsb

		mov cx, 127d

@@skipSpace: 	cmp al, ' '
		jne @@noSkipSpace
		xor ax, ax
		lodsb
		loop @@skipSpace

@@noSkipSpace:	sub si, 1

		mov dx, si		;moves text beginning ptr to dx

;-----------------------------------------------------
		pop ax
		pop cx
		pop bx

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
		add al, 0ah
		jmp @@endOfConvAl

@@upCaseAl:	sub al, 'A'
		add al, 0ah

@@endOfConvAl:	cmp ah, 'a'
		jae @@lowCaseAh

		cmp ah, 'A'
		jae @@upCaseAh

		sub ah, '0'
		jmp @@endOfConvAh

@@lowCaseAh:	sub ah, 'a'
		add ah, 0ah
		jmp @@endOfConvAh

@@upCaseAh:	sub ah, 'A'
		add ah, 0ah

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

		mov di, dx 		; saves dx in di cause dx is somehow changed (QUICK FIX!!!!)

		push bx
		push ax			; temp save ax, bx

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
		mov cl, ch		; cl = ch, ch = 0
		xor ch, ch

		mov si, ax		; Saves ax to si
		mov ax, [si + 4]	; Draw top left angle
		mov es:[bx], ax
		add bx, 2d
		mov ax, [si]		; Do delta one right

		call DrawX		; Draw upper horizontal line

		mov ax, [si + 6]
		mov es:[bx], ax		; Draw top right angle

		pop cx
		pop bx			; move 1 row down
		push bx
		add bx, 160d

		push ax
		push cx
		xor ax, ax
		mov ax, 160d
		xor ch, ch
		mul cx			; Add 160d * cl to bx, move cl rows down
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

		call DrawX		; Draw low horizontal line

		mov ax, [si + 10]
		mov es:[bx], ax		; Bottom right angle

		pop cx
		pop bx			; restore bx and cx

		push bx
		push cx			; Save bx and cx

		xor ch, ch

		add bx, 160d		; one row down

		mov ax, [si + 2]	; Set current draw symbol to vert line

		call DrawY		; draw left line

		xor cx, cx
		xor bx, bx		; Restore bx and cx
		pop cx
		pop bx
		push bx			; and save them again
		push cx

		xor cl, cl
		mov cl, ch		; cx = chcl -> cx = 00ch
		xor ch, ch

		add bx, 162d
		add bx, cx		;moves bx one right + one down
		add bx, cx

		pop cx
		push cx			;restore cx, and save

		xor ch, ch

		mov ax, [si + 2]	;current draw symbol to vert line

		call DrawY		; draw right vert line

		pop cx			; restore cx, bx
		pop bx

		add bx, 162d		; move bx right + down

		push bx
		push cx			; save bx and cx

		mov si, di		; si points to text beginning
		xor dx, dx

		mov dh, textStyleByte

@@Next:		cmp byte ptr [si], '$'		; Check if the text ended. break if true
		je @@endLoop

		cmp byte ptr [si], '\'
		jne @@noNewLine
		cmp byte ptr [si + 1], 'n'
		jne @@noNewLine
		add si, 2
		pop ax
		push ax
		mov al, ah
		sub al, ch
		mov ch, ah
		xor ah, ah
		dec cl
		add bx, 160d
		sub bx, ax
		sub bx, ax
		cmp cl, 0d
		ja @@Next
		jmp @@endLoop
@@noNewLine:	mov dl, byte ptr [si]
		mov es:[bx], dx			;print symbol via [si]->dl and move right
		add bx, 2d
		inc si
		sub ch, 1d			; dec ch that counts amount of space left on x
		cmp ch, 0d
		ja @@Next
		pop ax
		mov ch, ah ; if ch == 0: ch = ch0, cl--
		push ax
		dec cl
		add bx, 160d
		mov al, ah
		xor ah, ah		; Sets bx on a new line
		sub bx, ax
		sub bx, ax
		cmp cl, 0d		; if cl == 0 break
		ja @@Next

@@endLoop:

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
		xor ah, ah
		xor bx, bx
		mov cx, 80d * 23d
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
		textStyleByte db 09
		; style dw ?, ?, ?, ?, ?, ?
		help_message db 'usage: (length of name represents required amount of digits, except for the text. All numbers are hex.)', 0ah, 0dh, 'frame.com X0 Y0 LX LY FRXL FRYL FLTC FRTC FLBC FRBC TS TEXT_TO_BE_DISPLAYED', 0ah, 0dh, 'Where  : ', 0ah, 0dh, 'X0 - left top X coord in range [00h, 50h]', 0ah, 0dh, 'Y0 - left top Y coord in range [00h, 1Eh]', 0ah, 0dh, 'LX - X length of working zone', 0ah, 0dh, 'LY - Y length of working zone', 0ah, 0dh, 'FRXL, FRYL - hex codes of horizontal and vertical line symbols', 0ah, 0dh, "FLTC, FRTC, FLBC, FRBC - left top, right top, left bottom and right bottom angles' codes", 0ah, 0dh, 'TS - text style, a 2 digit hex', 0ah, 0dh, 'TEXT_TO_BE_DISPLAYED - the text, ending in dollar sign$'

end start