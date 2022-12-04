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
	
	xor ebp, ebp ; sum of priorities
	lea si, buf
nextRecord:
	xor cx, cx ; number of characters in the line
nextChar:
	lodsb
	inc cx
	cmp al, 0dh
	jz endOfLine
	jmp nextChar
endOfLine:	
	mov word[endOfLinePtr], si
	dec cx ; come back to the last character
	dec si
	mov word[lineLength], cx
	sub si, cx ; si points to the beginning of the line
	mov di, si 
	shr cx, 1
	add di, cx ; di points to the middle of the line
	mov word[middleOfLine], di
	
nextCharToCheckInFirstLine:
	lodsb ; load char from the first half
	mov bl, al
	mov di, word[middleOfLine]
	push cx ; outer loop counter
	mov cx, word[lineLength] ; inner loop counter
	shr cx, 1
nextCharToCheckInSecondLine:
	mov al, [di]
	cmp al, bl
	jz foundMatch
	inc di
	loop nextCharToCheckInSecondLine
	pop cx
	loop nextCharToCheckInFirstLine
	
foundMatch: ; di points to the matched character
	pop cx
	;mov ah, 02h
	;mov dl, [di]
	;int 21h

	; convert character to priority
	xor eax, eax
	mov al, [di]
	cmp al, 61h
	jb notLowCase 
	sub al, 61h
	add al, 1
	jmp endOfPriorityConversion
notLowCase:
	sub al, 41h
	add al, 27
endOfPriorityConversion:
	add ebp, eax
	

	mov si, word[endOfLinePtr]
	inc si

	mov bx, si
	sub bx, buf
	cmp bx, word[bytesRead]
	jae endOfFile
	jmp nextRecord

endOfFile:
	
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
lineLength   dw 0
middleOfLine dw 0
endOfLinePtr dw 0
buf:
