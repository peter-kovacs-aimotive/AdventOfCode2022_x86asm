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
	xor edi, edi ; all time high
	xor ebp, ebp ; sum of actual record
	xor cx, cx ; number of non-number characters
newNumber:
	xor ebx, ebx ; actual number
newDigit:	
	lodsb
	
	push bx
	mov bx, si
	sub bx, buf
	cmp bx, word[bytesRead]
	pop bx
	ja endOfFile
	
	cmp al, '0'
	jb notDigit
	cmp al, '9'
	ja notDigit
	sub al, '0'
	xor ah, ah
	push ax
	xor cx, cx ; reset non-number counter

	mov eax, ebx
	mov ebx, 10
	mul ebx ; eax = eax*10
	mov ebx, eax
	xor eax,eax
	pop ax
	add ebx, eax
	jmp newDigit
notDigit:
	inc cx
	cmp cx, 2
	jz newNumber
	cmp cx, 4
	jz newRecord
	add ebp, ebx
	jmp newDigit

newRecord:	
	cmp edi, ebp
	ja notHigher
	mov edi, ebp ; set all time high
notHigher:
	xor ebp, ebp
	jmp newNumber
	
endOfFile:	
	xor cx, cx ; cx = number of digits written to the buffer
	lea si, buf
	mov eax, edi
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

	inc cx
printNextDigit:	
	mov ah, 02h
	mov dl, [si]
	int 21h
	dec si
	loop printNextDigit
	
	ret

fileName	db "input.txt"
bytesRead	dw 0
buf:
