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

	mov ax, word[matrixWidth]
	add ax, 2 ; to account for the newlines
	mov word[matrixStride], ax
	
	mov ax, word[matrixWidth]
	dec ax
	mov word[matrixWidthMinus1], ax
	
	mov ax, word[matrixHeight]
	dec ax
	mov word[matrixHeightMinus1], ax
	
	xor ebp, ebp ; init ebp with the edge trees which are visible by default
	mov bp, word[matrixHeight]
	shl bp, 1
	mov ax, word[matrixWidth]
	shl ax, 1
	add bp, ax
	sub bp, 4

	mov bx, 1 ; y coordinate
loopY:
	mov cx, 1 ; x coordinate
loopX:
	call getHeight
	mov byte[referenceHeight], al
	
	push bx
	push cx
	
goUp:
	dec bx
	call getHeight
	cmp al, byte[referenceHeight]
	jae tooHighUp
	cmp bx, 0
	jg goUp	
	jmp visible
tooHighUp:
	mov bx, [esp+2]
	
goDown:	
	inc bx
	call getHeight
	cmp al, byte[referenceHeight]
	jae tooHighDown
	cmp bx, word[matrixHeightMinus1]
	jb goDown
	jmp visible
tooHighDown:
	mov bx, [esp+2]

goLeft:
	dec cx
	call getHeight
	cmp al, byte[referenceHeight]
	jae tooHighLeft
	cmp cx, 0
	jg goLeft	
	jmp visible
tooHighLeft:
	mov cx, [esp]

goRight:	
	inc cx
	call getHeight
	cmp al, byte[referenceHeight]
	jae tooHighRight
	cmp cx, word[matrixWidthMinus1]
	jb goRight
	jmp visible
tooHighRight:
	mov cx, [esp]

	jmp notVisible

visible:
	inc ebp

notVisible:	
	pop cx
	pop bx
	
	inc cx
	cmp cx, word[matrixWidthMinus1]
	jne loopX

	inc bx
	cmp bx, word[matrixHeightMinus1]
	jne loopY


printResult:
	xor cx, cx ; cx = number of digits written to the buffer
	lea si, buf
	mov eax, ebp
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


;in: bx= y, cx=x
;out: al=height
getHeight:
	lea si, buf
	mov ax, bx
	mul word[matrixStride]
	add si, ax
	add si, cx 
	mov al, [si]
	ret


fileName	db "input.txt"
bytesRead	dw 0

matrixWidth		dw 99
matrixHeight	dw 99
matrixStride	resw 1

matrixWidthMinus1		resw 1
matrixHeightMinus1		resw 1

referenceHeight resb 1


buf:
