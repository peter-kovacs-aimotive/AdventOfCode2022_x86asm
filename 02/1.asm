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
	
	xor edi, edi
	lea si, buf
nextRecord:
	lodsb
	mov ah, al
	lodsb ; skip space
	lodsb
	
	cmp al, 'X'
	jnz notX
	add edi, 1
notX:
	cmp al, 'Y'
	jnz notY
	add edi, 2
notY:
	cmp al, 'Z'
	jnz notZ
	add edi, 3
notZ:

	cmp ax, 4158h ; AX
	jnz notAX
	add edi, 3
notAX:
	cmp ax, 4159h ; AY
	jnz notAY
	add edi, 6
notAY:
	cmp ax, 415Ah ; AZ
	jnz notAZ
	; no score
notAZ:
	cmp ax, 4258h ; BX
	jnz notBX
	; no score
notBX:
	cmp ax, 4259h ; BY
	jnz notBY
	add edi, 3
notBY:
	cmp ax, 425Ah ; BZ
	jnz notBZ
	add edi, 6
notBZ:
	cmp ax, 4358h ; CX
	jnz notCX
	add edi, 6
notCX:
	cmp ax, 4359h ; CY
	jnz notCY
	; no score
notCY:
	cmp ax,  435Ah ; CZ
	jnz notCZ
	add edi, 3
notCZ:

	lodsw ; skip new line
	
	mov bx, si
	sub bx, buf
	cmp bx, word[bytesRead]
	jae endOfFile
	jmp nextRecord

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
endOfSums   dw 0
buf:
