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
	lea di, signalStrengthCheckpoints
	mov edx, 0 ; cycle
	mov ebx, 1 ; X register
	xor ebp, ebp ; sum of signal strengths

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


nextCycle:
	inc edx
	cmp edx, [di] ; compare to next signal streangth checkpoint
	je cycleMatch
	jmp nextCycleEnd
cycleMatch:
	push edx
	mov eax, edx
	imul ebx
	pop edx
	add ebp, eax
	add di, 4
nextCycleEnd:
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
signalStrengthCheckpoints dd 20, 60, 100, 140, 180, 220

buf:
