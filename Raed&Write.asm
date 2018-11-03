masm
model small
.code
main:
	mov AX, @data
	mov DS, AX
	mov AH, 01h
	int 21h
	push AX
	mov AH, 01h
	int 21h
	push AX
	mov AH, 01h
	int 21h
	mov DL, AL
	mov AH, 02h
	int 21h
	pop DX
	mov AH, 02h
	int 21h
	pop DX
	mov AH, 02h
	int 21h

	mov AX, 4c00h
	int 21h

end main
	
