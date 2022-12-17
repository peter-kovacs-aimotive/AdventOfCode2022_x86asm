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
	mov word[tailX], ax
	mov word[minTailX], ax
	mov word[maxTailX], ax
	mov ax, 310
	mov word[headY], ax
	mov word[tailY], ax
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

	; draw head
;	mov ax, 0a000h
;	mov es, ax
;	mov ax, word[headY]
;	mov dx, 320
;	mul dx
;	add ax, word[headX]
;	mov di, ax
;	mov byte[es:di], 0fh
;
;	; draw tail
;	mov ax, word[tailY]
;	mov dx, 320
;	mul dx
;	add ax, word[tailX]
;	mov di, ax
;	mov byte[es:di], 0ch

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

	; udate tail
	mov ax, word[headX]
	sub ax, word[tailX]
	cmp ax, 2
	jge diff2X

	mov ax, word[headX]
	sub ax, word[tailX]
	cmp ax, -2
	jle diffm2X

	mov ax, word[headY]
	sub ax, word[tailY]
	cmp ax, 2
	jge diff2Y

	mov ax, word[headY]
	sub ax, word[tailY]
	cmp ax, -2
	jle diffm2Y

	jmp updateTailEnd

diff2X:
	mov ax, word[headY]
	cmp ax, word[tailY]
	je moveTailRight
	mov word[tailY], ax
	jmp moveTailRight

diffm2X:
	mov ax, word[headY]
	cmp ax, word[tailY]
	je moveTailLeft
	mov word[tailY], ax
	jmp moveTailLeft

diff2Y:
	mov ax, word[headX]
	cmp ax, word[tailX]
	je moveTailDown
	mov word[tailX], ax
	jmp moveTailDown

diffm2Y:
	mov ax, word[headX]
	cmp ax, word[tailX]
	je moveTailUp
	mov word[tailX], ax
	jmp moveTailUp

moveTailRight:
	inc word[tailX]
	jmp updateTailEnd
	
moveTailLeft:
	dec word[tailX]
	jmp updateTailEnd

moveTailDown:
	inc word[tailY]
	jmp updateTailEnd

moveTailUp:
	dec word[tailY]
	jmp updateTailEnd
	
updateTailEnd:
	; wait for keypress
;	mov ah, 1
;	int 16h
;	jz updateTailEnd
;	mov ah, 0
;	int 16h
	
	;hlt
	
	mov ax, word[tailX]
	cmp ax, word[minTailX]
	jnb noUpdateMinTailX
	mov word[minTailX], ax
noUpdateMinTailX:	
	cmp ax, word[maxTailX]
	jna noUpdateMaxTailX
	mov word[maxTailX], ax
noUpdateMaxTailX:

	mov ax, word[tailY]
	cmp ax, word[minTailY]
	jnb noUpdateMinTailY
	mov word[minTailY], ax
noUpdateMinTailY:	
	cmp ax, word[maxTailY]
	jna noUpdateMaxTailY
	mov word[maxTailY], ax
noUpdateMaxTailY:


	; draw tail in the visited buffer
	mov dx, 0a000h
	mov es, dx

	mov ax, word[tailY]
	mov dx, 320
	mul dx
	cmp dx, 0
	jne switchBank
	jmp switchBankEnd
switchBank:
	mov dx, 0b000h
	mov es, dx
switchBankEnd:	
	
	add ax, word[tailX]
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

headX	resw 1
headY	resw 1
tailX	resw 1
tailY	resw 1

minTailX resw 1
maxTailX resw 1
minTailY resw 1
maxTailY resw 1

buf:
