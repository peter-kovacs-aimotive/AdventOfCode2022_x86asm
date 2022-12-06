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
	
nextChar:
	push si
	mov cx, word[bytesToCompare]
	dec cx
outerLoop:
	mov dx, cx
	mov di, si
	inc di
innerLoop:
		mov al, [si]
		mov bl, [di]
		cmp al, bl
		je equal
		inc di
		dec dx
		jnz innerLoop
	inc si
	loop outerLoop
	
	jmp printResult

equal:
	pop si
	inc si
	inc bp
	jmp nextChar
	
	
printResult:
	pop si
	add bp, word[bytesToCompare]
	
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

bytesToCompare dw 14

buf:
