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
	
	mov cx, word[initialHeight]
	mov bx, word[initialHeight]
nextInitialRow:
		push cx
		mov cx, word[numberOfColumns]
		mov di, word[tetrisBufferPtr]
		push bx
		shl bx, 4
		sub di, bx
		pop bx
	nextItem:
			inc si ; skip "["
			lodsb
			stosb
			add si, 2 ; skip "] "
		loop nextItem
		pop cx
		inc si ; skip second newline character
		dec bx
	loop nextInitialRow
	
	xor cx, cx ; column number
countRowHeights:
	xor ax, ax ; height counter
	mov di, word[tetrisBufferPtr]
	sub di, 10h
	add di, cx
nextRow:
		cmp byte[di], 20h
		jz emptyCell
		cmp byte[di], 00h
		jz emptyCell
		sub di, 10h
		inc ax
		jmp nextRow
emptyCell:
	mov di, word[tetrisBufferPtr]
	add di, cx
	stosb
	inc cx
	cmp cx, word[numberOfColumns]
	jl countRowHeights

	; find "m" from move
	xor cx, cx
	dec cx
	mov di, si
	mov al, 'm'
	repne scasb
	mov si, di
	add si, 4
	

nextRecord:	
	call readNumberFromBuffer
	mov cx, ax
	add si, 5
	call readNumberFromBuffer
	mov bx, ax
	add si, 3
	call readNumberFromBuffer
	mov dx, ax

	call moveNfromXtoZ

	add si, 6
	
	mov bx, si
	sub bx, buf
	cmp bx, word[bytesRead]
	jae endOfFile
	jmp nextRecord
endOfFile:


	xor cx, cx
printNextLetter:	
	mov di, word[tetrisBufferPtr]
	add di, cx
	xor ax, ax
	mov al, [di]
	shl ax, 4
	sub di, ax
	mov dl, [di] ; load letter in al
	mov ah, 02h
	int 21h
	inc cx
	cmp cx, word[numberOfColumns]
	jl printNextLetter
	
	ret
	

; in: source pointer in ds:si
; out: number in eax, si points to the fist non-number character
readNumberFromBuffer:
	push ebx
	push edx
	
	xor ebx, ebx ; actual number
	xor eax, eax
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
	pop edx
	mov eax, ebx
	pop ebx 	

	ret

; in: cx: how many; bx: from; dx: to
moveNfromXtoZ:
	dec bx ; columns are 1-indexed
	dec dx

	mov di, word[tetrisBufferPtr]
	add di, dx
	xor ax, ax
	mov al, [di] ; number of blocks in destination tower
	mov bp, ax
	add ax, cx
	mov [di], al ; update number of blocks in destination tower

	mov di, word[tetrisBufferPtr]
	add di, bx
	xor ax, ax
	mov al, [di] ; number of blocks in source tower
	sub bp, ax
	neg bp
	sub bp, cx
	shl bp, 4 ; bp = vertical offset during copy
	push ax
	sub ax, cx
	mov [di], al ; this tower is now N less
	pop ax	
	shl ax, 4
	sub di, ax
	
moveMore:
		mov al, [di] ; load a letter in al
		mov byte[di], 20h ; store space instead
		add di, dx
		sub di, bx ; find new place
		add di, bp
		mov [di], al
		sub di, dx
		add di, bx
		sub di, bp

		add di, 10h
		loop moveMore

	ret

fileName	db "input.txt"
bytesRead	dw 0

; too lazy to figure these out from the input file
initialHeight dw 9
numberOfColumns dw 9

tetrisBufferPtr dw 8000h

buf:
