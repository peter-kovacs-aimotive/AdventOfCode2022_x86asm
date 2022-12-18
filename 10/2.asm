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

	lea si, buf
	mov edx, 0 ; cycle
	mov ebx, 1 ; X register

nextLine:
	lodsb
	cmp al, 'n'
	je noop

	cmp al, 'a'
	je addx
	
	hlt ; this should not happen

noop:
	mov al, 0ah
	push di
	mov di, si
	repne scasb ; run until newline
	mov si, di
	pop di
	
	call nextCycle
	jmp checkEndOfFile
	
addx:
	mov al, ' '
	push di
	mov di, si
	repne scasb ; run until space
	mov si, di
	pop di

	call nextCycle
	call nextCycle
	
	call scanNumber
	add ebx, eax
	add si, 1 ; skip newline

checkEndOfFile:
	push bx
	mov bx, si
	sub bx, buf
	cmp bx, word[bytesRead]
	pop bx
	jae endOfFile

	jmp nextLine
endOfFile:
	ret


nextCycle:
	push edx
	sub edx, ebx
	cmp edx, -1
	je drawPixel
	cmp edx, 0
	je drawPixel
	cmp edx, 1
	je drawPixel
	jmp drawNoPixel
drawPixel:
	mov ah, 2h
	mov dl, '#'
	int 21h
	jmp endDrawPixel
drawNoPixel:
	mov ah, 2h
	mov dl, '.'
	int 21h
	jmp endDrawPixel
endDrawPixel:	
	pop edx
	push edx
	mov eax, edx
	mov dl, 40
	div dl
	pop edx
	cmp ah, 0
	jne noNewLine
printNewLine:
	mov ah, 2h
	mov dl, 10
	int 21h
	mov dl, 13
	int 21h	

	mov edx, 0 ; reset the register
	; the first row does not show properly, but it is readable anyway
noNewLine:
	inc edx
	ret

; in: si=pointer to number
; out: eax = number
scanNumber:
newNumber:
	push ebx
	push edx
	push ecx
	xor ebx, ebx ; actual number
	xor ecx, ecx ; sign
newDigit:	
	lodsb
		
	cmp al, '-'
	je negative
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
negative:
	mov ecx, 1
	jmp newDigit
notDigit:
	cmp ecx, 0
	je positive
	neg ebx
positive:
	mov eax, ebx
	pop ecx
	pop edx
	pop ebx
	ret


fileName	db "input.txt"
bytesRead	dw 0

buf:
