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
	
nextMonkey:
	mov di, si
	xor cx, cx
	dec cx
	mov al, ':'
	repne scasb
	repne scasb ; find the second :
	inc di
	mov si, di
	
	lea di, items
	mov ax, word[monkeyNumber]
	shl ax, 8 ; maxItems * 4
	add di, ax 
newItem:
	call scanNumber
	stosd
	dec si	
	lodsb
	inc si
	cmp al, ',' 
	je newItem
	
	mov di, si
	mov al, 'd' ; from old
	repne scasb
	mov si, di
	inc si
	lodsb
	lea di, operation
	add di, word[monkeyNumber]
	stosb
	inc si
	call scanNumber
	lea di, operand
	add di, word[monkeyNumber]
	stosb

	mov di, si
	mov al, 'y' ; from by
	repne scasb
	mov si, di
	inc si
	call scanNumber
	lea di, divisible
	add di, word[monkeyNumber]
	stosb
	
	mov di, si
	mov al, 'y' ; from monkey
	repne scasb
	mov si, di
	inc si
	call scanNumber
	lea di, throwTrue
	add di, word[monkeyNumber]
	stosb
	
	mov di, si
	mov al, 'y' ; from monkey
	repne scasb
	mov si, di
	inc si
	call scanNumber
	lea di, throwFalse
	add di, word[monkeyNumber]
	stosb

	inc word[monkeyNumber]
	cmp word[monkeyNumber], numberOfMonkeys
	je endOfFile
	jmp nextMonkey
endOfFile:

	
	mov eax, 1
	mov cx, numberOfMonkeys
	lea si, divisible
nextDivisible:
	xor ebx, ebx
	mov bl, [si]
	inc si
	mul ebx
	loop nextDivisible
	mov dword[commonMultiplier], eax
	

	mov word[roundNumber], 0
nextRound:
	mov word[monkeyNumber], 0
inspection:
	lea si, items
	mov ax, word[monkeyNumber]
	shl ax, 8 ; maxItems * 4
	add si, ax 
inspectNextItem:
	lodsd
	cmp eax, 0
	je lastItem
	push si
	mov edx, eax ; dx: original number
	
	lea si, numberOfInspections
	mov ax, word[monkeyNumber]
	shl ax, 2 ; dword size
	add si, ax
	inc dword[si]
	
	lea si, operation
	add si, word[monkeyNumber]
	lodsb
	mov bl, al
	
	lea si, operand
	add si, word[monkeyNumber]
	xor eax, eax
	lodsb
	cmp al, 0
	jnz oldIsNotOperand2
	mov eax, edx
oldIsNotOperand2:
	
	cmp bl, '*'
	je multiplication
	cmp bl, '+'
	je addition
	hlt

multiplication:
	mul edx
	jmp modByCommonMultiplier

addition:
	add eax, edx
	xor edx, edx
	jmp modByCommonMultiplier

modByCommonMultiplier:
	mov ebx, dword[commonMultiplier]
	div ebx
	mov eax, edx
	xor edx, edx

division:
	push eax ; store original number until it is stored
	lea si, divisible
	add si, word[monkeyNumber]
	mov ebx, 0
	mov bl, byte[si]
	xor edx, edx
	div ebx
	
	cmp edx, 0
	je divisableTrue
	jne divisableFalse
divisableTrue:
	lea si, throwTrue
	add si, word[monkeyNumber]
	xor ax, ax
	lodsb
	jmp storeItem
divisableFalse:
	lea si, throwFalse
	add si, word[monkeyNumber]
	xor ax, ax
	lodsb
	jmp storeItem

storeItem:
	lea di, items
	shl ax, 8 ; maxItems * 4
	add di, ax 
	xor eax, eax
	xor cx, cx
	dec cx
	repne scasd ; find the zero element at the end
	sub di, 4
	pop eax
	stosd ; store it there

	pop si
	jmp inspectNextItem

lastItem:
	; clear all items from the monkey just finished
	lea di, items
	mov ax, word[monkeyNumber]
	shl ax, 8 ; maxItems * 4
	add di, ax 
	mov cx, maxItems
	xor eax, eax
	rep stosd
	
	inc word[monkeyNumber]
	mov ax, word[monkeyNumber]
	cmp ax, numberOfMonkeys
	jne inspection

	; print status at the end of the round
;	push cx
;	push si
;	push ax
;	push dx
;	mov cx, 0
;printNextMonkey:	
;	lea si, items
;	mov ax, cx
;	shl ax, 8
;	add si, ax
;
;	push cx
;	mov cx, maxItems
;printItems:
;	lodsd
;	cmp eax, 0
;	je endPrintItems
;	call printResult
;	mov ah, 02h
;	mov dl, ' '
;	int 21h
;	loop printItems
;endPrintItems:
;	call printNewLine
;	pop cx
;	inc cx
;	cmp cx, numberOfMonkeys
;	jne printNextMonkey
;	
;	pop dx
;	pop ax
;	pop si
;	pop cx
	
	inc word[roundNumber]
	cmp word[roundNumber], 10000
	jb nextRound

	lea si, numberOfInspections
	mov cx, numberOfMonkeys
	call sortDwordsDesc

;	mov eax, dword[numberOfInspections]
;	mov ebx, dword[numberOfInspections+4]
;	mul ebx
	
;	call printResult
;	call printNewLine
;	call printNewLine

	xor eax, eax
	mov eax, dword[numberOfInspections]
	call printResult
	call printNewLine
	mov eax, dword[numberOfInspections+4]
	call printResult
	call printNewLine
;	xor eax, eax
;	mov eax, dword[numberOfInspections+8]
;	call printResult
;	call printNewLine
;	mov eax, dword[numberOfInspections+12]
;	call printResult
;	call printNewLine
;	mov eax, dword[numberOfInspections+16]
;	call printResult
;	call printNewLine
;	mov eax, dword[numberOfInspections+20]
;	call printResult
;	call printNewLine
;	mov eax, dword[numberOfInspections+24]
;	call printResult
;	call printNewLine
;	mov eax, dword[numberOfInspections+28]
;	call printResult
;	call printNewLine
	
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

; in: eax=number
printResult:
	push eax
	push ebx
	push ecx
	push edx
	push esi
	
	xor cx, cx ; cx = number of digits written to the buffer
	lea si, buf
	;mov eax, ebp
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

	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

printNewLine:
	push ax
	push dx
	
	mov ah, 02h
	mov dl, 10
	int 21h

	mov ah, 02h
	mov dl, 13
	int 21h
	
	pop dx
	pop ax
	
	ret


; in: si=start pointer cx=number of items
sortDwordsDesc:
	push si
	push di
	push eax
	push ebx
	push ecx
	push edx
	
	
	dec cx
	mov word[sortItemCount], cx
	mov word[sortStartPtr], si
	
nextSortIteration:
	mov dx, 0
	mov cx, word[sortItemCount]
	mov si, word[sortStartPtr]

nextSortItem:
	lodsd
	mov ebx, eax
	lodsd
	cmp eax, ebx
	jng noSwap 
swap:	
	sub si, 8
	mov di, si
	stosd
	mov eax, ebx
	stosd
	mov si, di
	mov dx, 1
noSwap:	
	sub si, 4
	loop nextSortItem
	
	cmp dx, 1
	je nextSortIteration
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop di
	pop si
	
	ret


fileName	db "input.txt"
bytesRead	dw 0
numberOfMonkeys	equ 8
maxItems	equ 64
monkeyNumber	dw 0
itemNumber		dw 0
roundNumber		dw 0

sortItemCount	dw 0
sortStartPtr	dw 0

commonMultiplier dd 0

items		resd numberOfMonkeys*64
operation	resb numberOfMonkeys
operand		resb numberOfMonkeys
divisible	resb numberOfMonkeys
throwTrue	resb numberOfMonkeys
throwFalse	resb numberOfMonkeys
numberOfInspections resd numberOfMonkeys



buf:
