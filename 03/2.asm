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
	mov word[startOfLine1Ptr], si
nextChar1:
	lodsb
	inc cx
	cmp al, 0dh
	jz endOfLine1
	jmp nextChar1
endOfLine1:	
	dec cx ; come back to the last character
	dec si
	mov word[endOfLine1Ptr], si
	mov word[line1Length], cx

	add si, 2

	xor cx, cx ; number of characters in the line
	mov word[startOfLine2Ptr], si
nextChar2:
	lodsb
	inc cx
	cmp al, 0dh
	jz endOfLine2
	jmp nextChar2
endOfLine2:	
	dec cx ; come back to the last character
	dec si
	mov word[endOfLine2Ptr], si
	mov word[line2Length], cx

	add si, 2

	xor cx, cx ; number of characters in the line
	mov word[startOfLine3Ptr], si
nextChar3:
	lodsb
	inc cx
	cmp al, 0dh
	jz endOfLine3
	jmp nextChar3
endOfLine3:	
	dec cx ; come back to the last character
	dec si
	mov word[endOfLine3Ptr], si
	mov word[line3Length], cx


	mov si, word[startOfLine1Ptr]
	mov cx, word[line1Length]
nextCharToCheckInFirstLine:
	lodsb ; load char from the first line
	mov dl, al
	
	push si
	push cx
	mov si, word[startOfLine2Ptr]
	mov cx, word[line2Length]

nextCharToCheckInSecondLine:
	lodsb
	mov bl, al
	
	push si
	push cx
	mov si, word[startOfLine3Ptr]
	mov cx, word[line3Length]
nextCharToCheckInThirdLine:
	lodsb
	
	cmp al, bl
	jnz noMatch
	cmp bl, dl
	jnz noMatch
	jmp foundMatch

noMatch:
	loop nextCharToCheckInThirdLine
	pop cx
	pop si
	loop nextCharToCheckInSecondLine
	pop cx
	pop si
	loop nextCharToCheckInFirstLine
	
foundMatch: ; di points to the matched character
	pop cx
	pop si
	pop cx
	pop si
	
	;mov ah, 02h
	;int 21h

	; convert character to priority
	xor eax, eax
	mov al, dl
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
	

	mov si, word[endOfLine3Ptr]
	add si, 2

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

startOfLine1Ptr dw 0
line1Length   dw 0
endOfLine1Ptr dw 0

startOfLine2Ptr dw 0
line2Length   dw 0
endOfLine2Ptr dw 0

startOfLine3Ptr dw 0
line3Length   dw 0
endOfLine3Ptr dw 0

buf:
