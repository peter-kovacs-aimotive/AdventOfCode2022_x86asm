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
	
	
	mov bp, 4
	
	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx

	mov dl, cl
	mov cl, bl
	mov bl, al
	lodsb
	
	mov dl, cl
	mov cl, bl
	mov bl, al
	lodsb

	mov dl, cl
	mov cl, bl
	mov bl, al
	lodsb	

nextChar:
	mov dl, cl
	mov cl, bl
	mov bl, al
	lodsb ; first char in al

	cmp al, bl
	je equal
	cmp al, cl
	je equal
	cmp al, dl
	je equal
	cmp bl, cl
	je equal
	cmp bl, dl
	je equal
	cmp cl, dl
	je equal
	
	; not equal
	jmp printResult
	
equal:
	inc bp
	jmp nextChar

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

fileName	db "input.txt"
bytesRead	dw 0

buf:
