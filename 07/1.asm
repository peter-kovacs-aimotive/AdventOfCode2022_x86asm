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
	xor ebp, ebp
	call parseDir

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


parseDir:
	xor ebx,ebx
nextLine:
	lodsb
	cmp al, '$'
	je parseCommand
	cmp al, 'd'
	je dir
	cmp al, 0
	je endOfDir
	dec si ; go back to the first number
	jmp file

parseCommand:
	inc si ; skip space
	lodsb
	cmp al, 'c'
	je cd
	cmp al, 'l'
	je ls
	hlt ; this should not happen
	
cd:
	add si, 2 ; skip 'd '
	lodsb
	cmp al, '.'
	je endOfDir
	xor cx, cx
	dec cx
	mov al, 0ah
	mov di, si
	repne scasb ; run until newline
	mov si, di
	push ebx
	call parseDir
	mov eax, ebx
	pop ebx
	add ebx, eax ; add the size of the dir to the total
	jmp nextLine
	
ls:
	add si, 3 ; ls id don't care, just skip to the next line
	jmp nextLine

dir:
	xor cx, cx
	dec cx
	mov al, 0ah
	mov di, si
	repne scasb ; dir entry is also don't care, we will cd into it anyway. just run until newline
	mov si, di
	jmp nextLine

file:
	call scanNumber
	add ebx, eax ; add it to the total size of the directory
	xor cx, cx
	dec cx
	mov al, 0ah
	mov di, si
	repne scasb ; file name is don't care. just run until newline
	mov si, di
	jmp nextLine

endOfDir:
	add si, 3 ; skip '.\r\n'
	
	; check total dir size
	cmp ebx, 100000
	jg doNotAddToTotal
	add ebp, ebx
	
doNotAddToTotal:	
	ret


fileName	db "input.txt"
bytesRead	dw 0

buf:
