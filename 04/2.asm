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

	xor ebp, ebp ; number of fully contained intervals
	lea si, buf

nextRecord:
	call readNumberFromBuffer
	mov dx, ax
	call readNumberFromBuffer
	mov cx, ax
	call readNumberFromBuffer
	mov bx, ax
	call readNumberFromBuffer
	inc si

;DX-CX
;       BX-AX
;
;DX-CX
;   BX-AX
;
;DX---CX
; BX-AX
;
;BX-AX
;       DX-CX
;
;BX-AX
;   DX-CX
;
;BX---AX
; DX-CX

	cmp dx, bx
	jg reverse
	cmp cx, bx
	jge overlap
	jmp noOverlap
reverse:
	cmp ax, dx
	jge overlap
	jmp noOverlap

overlap:
	inc ebp

noOverlap:
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


fileName	db "input.txt"
bytesRead	dw 0

buf:
