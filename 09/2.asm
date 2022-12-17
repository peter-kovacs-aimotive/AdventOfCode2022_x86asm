; Advent Of Code 2022
; Works on DosBox 0.74-3
; Compile with "nasm.exe fileName.asm -fbin -o fileName.com"

org 100h

	mov ax, 3d00h ; open file
	push cs
	pop ds
	lea dx, fileName
	int 21h ; ax = file handle
	
	mov bx, ax
	push bx
	mov ax, 3f00h ; read from file handle
	xor cx, cx
	dec cx
	lea dx, buf
	int 21h ; ax = number of bytes read from file
	mov word[bytesRead], ax

	pop bx
	mov ah, 3eh ; close file
	int 21h

	mov ax, 13h
	int 10h

;	mov ax, 0b800h
;	mov es, ax
;	mov di, 0
;	mov cx, 80*25
;	mov ax, 072eh
;	rep stosw

	mov ax, 0a000h ; clear the tail visited buffer
	mov es, ax
	xor di, di
	xor cx, cx
	dec cx
	rep stosb
	mov ax, 0b000h ; clear the tail visited buffer
	mov es, ax
	xor di, di
	xor cx, cx
	dec cx
	rep stosb
	
	mov ax, 201
	mov word[headX], ax ; starting position
	lea bp, tailX
	mov cx, 9
initTailX:
	mov word[bp], ax
	add bp, 4
	loop initTailX
	
	mov word[minTailX], ax
	mov word[maxTailX], ax

	mov ax, 310 ; 310 is high enough not to underflow
	mov word[headY], ax
	lea bp, tailY
	mov cx, 9
initTailY:
	mov word[bp], ax
	add bp, 4
	loop initTailY

	mov word[minTailY], ax
	mov word[maxTailY], ax

	lea si, buf

nextLine:
	lodsb
	mov bl, al
	inc si
	call scanNumber
	mov cx, ax
	inc si ; skip newLine

nextMove:	
	; clear screen
;	push cx
;	mov ax, 0a000h
;	mov es, ax
;	xor di, di
;	xor cx, cx
;	dec cx
;	xor ax, ax
;	rep stosb
;	pop cx

;	; draw head and tail in graphic mode
;	push cx
;	mov ax, 0a000h
;	mov es, ax
;	lea bp, headX
;	mov cx, 10
;drawLoopGfx:
;	mov ax, word[bp+2]
;	mov dx, 320
;	mul dx
;	add ax, word[bp]
;	mov di, ax
;	mov ax, 15h
;	add ax, cx
;	mov byte[es:di], al
;	add bp, 4
;	loop drawLoopGfx
;	pop cx

	; draw head and tail in text mode
;	push cx
;	mov ax, 0b800h
;	mov es, ax
;	mov di, 0
;	mov cx, 80*25
;	mov ax, 072eh
;	rep stosw
;
;	mov ax, 0b800h
;	mov es, ax
;	lea bp, headX
;	add bp, 9*4
;	mov cx, 10
;drawLoopText:
;	mov ax, word[bp+2]
;	mov dx, 80
;	mul dx
;	add ax, word[bp]
;	shl ax, 1
;	mov di, ax
;	mov ax, '/'
;	add ax, cx
;	mov byte[es:di], al
;	sub bp, 4
;	loop drawLoopText
;	pop cx


	cmp bl, 'L'
	je left	
	cmp bl, 'R'
	je right	
	cmp bl, 'U'
	je up	
	cmp bl, 'D'
	je down	
	hlt ; this should not happen

left:
	dec word[headX]
	jmp endMove

right:
	inc word[headX]
	jmp endMove

up:
	dec word[headY]
	jmp endMove

down:
	inc word[headY]
	jmp endMove

endMove:

	; udate tails
	mov bp, headX
	push cx
	push bx
	mov cx, 9
updatenextTail:	
	mov ax, word[bp] ; headX
	sub ax, word[bp+4] ; tailX
	mov bx, word[bp+2] ; headY
	sub bx, word[bp+6] ; tailY

	cmp ax, 0
	jnl xDiffnotNegative
	neg ax
xDiffnotNegative:	

	cmp bx, 0
	jnl yDiffnotNegative
	neg bx
yDiffnotNegative:	

	cmp ax, 2
	je updateX
	cmp bx, 2
	je updateX
	jmp updateTailEnd

updateX:
	mov ax, word[bp] ; headX
	sub ax, word[bp+4] ; tailX
	cmp ax, 2
	je diffX2
	cmp ax, -2
	je diffXm2
	jmp noDivX
diffX2:
diffXm2:
	sar ax, 1
noDivX:
	add word[bp+4], ax
	
	mov bx, word[bp+2] ; headY
	sub bx, word[bp+6] ; tailY
	cmp bx, 2
	je diffY2
	cmp bx, -2
	je diffYm2
	jmp noDivY
diffY2:
diffYm2:
	sar bx, 1
noDivY:
	add word[bp+6], bx

	
updateTailEnd:
	add bp, 4
	loop updatenextTail
	pop bx
	pop cx
	
	; wait for keypress
;waitKey:
;	mov ah, 1
;	int 16h
;	jz waitKey
;	mov ah, 0
;	int 16h
	
;	mov ax, word[tailX]
;	cmp ax, word[minTailX]
;	jnb noUpdateMinTailX
;	mov word[minTailX], ax
;noUpdateMinTailX:	
;	cmp ax, word[maxTailX]
;	jna noUpdateMaxTailX
;	mov word[maxTailX], ax
;noUpdateMaxTailX:
;
;	mov ax, word[tailY]
;	cmp ax, word[minTailY]
;	jnb noUpdateMinTailY
;	mov word[minTailY], ax
;noUpdateMinTailY:	
;	cmp ax, word[maxTailY]
;	jna noUpdateMaxTailY
;	mov word[maxTailY], ax
;noUpdateMaxTailY:


	; draw tail in the visited buffer
	mov dx, 0a000h
	mov es, dx

	mov ax, word[tailY9]
	mov dx, 320
	mul dx
	cmp dx, 0
	jne switchBank
	jmp switchBankEnd
switchBank:
	mov dx, 0b000h
	mov es, dx
switchBankEnd:	
	
	add ax, word[tailX9]
	mov di, ax
	mov byte[es:di], 1


	
	dec cx
	jnz nextMove

	mov bx, si
	sub bx, buf
	cmp bx, word[bytesRead]
	jae endOfFile

	jmp nextLine
endOfFile:

	xor ebp, ebp

	mov ax, 0a000h
	mov es, ax
	xor cx, cx
	dec cx
	xor di, di
	xor eax, eax
countVisited:
	mov al, [es:di]
	add ebp, eax
	inc di
	dec cx
	jnz countVisited

	mov ax, 0b000h
	mov es, ax
	xor cx, cx
	dec cx
	xor di, di
	xor eax, eax
countVisited2:
	mov al, [es:di]
	add ebp, eax
	inc di
	dec cx
	jnz countVisited2


printResult:
	xor cx, cx ; cx = number of digits written to the buffer
	lea si, buf
	mov eax, ebp
	;xor eax, eax
	;mov ax, word[maxTailY]
	mov ebx, 10
printNextDigitToBuffer:
	xor edx, edx
	div ebx ; eax = quotient, edx = remainder
	push eax
	add dl, '0'
	mov [si], dl
	inc si
	inc cx
	pop eax
	test eax, eax
	jnz printNextDigitToBuffer

	dec si
printNextDigit:	
	mov ah, 02h
	mov dl, [si]
	int 21h
	dec si
	loop printNextDigit
	
	ret


; in: si=pointer to number
; out: eax = number
scanNumber:
newNumber:
	push ebx
	push edx
	xor ebx, ebx ; actual number
newDigit:	
	lodsb
		
	cmp al, '0'
	jb notDigit
	cmp al, '9'
	ja notDigit
	sub al, '0'
	xor ah, ah
	push ax

	mov eax, ebx
	mov ebx, 10
	mul ebx ; eax = eax*10
	mov ebx, eax
	xor eax,eax
	pop ax
	add ebx, eax
	jmp newDigit
notDigit:
	mov eax, ebx
	pop edx
	pop ebx
	ret


fileName	db "input.txt"
bytesRead	dw 0

minTailX resw 1
maxTailX resw 1
minTailY resw 1
maxTailY resw 1

headX	resw 1
headY	resw 1
tailX	resw 1
tailY	resw 1
tailX2to8 resw 7
tailY2to8 resw 7
tailX9	resw 1
tailY9	resw 1


buf:
