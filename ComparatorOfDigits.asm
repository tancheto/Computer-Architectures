masm
model small
.data

	b db 0
	oper db 0
	idx db 0

.code
main:
	mov ax, @data
	mov ds, ax

input:
	mov ah, 01h
	int 21h

	cmp al, 13
	je cont

	push ax
	inc idx
	jmp input	

cont:
	cmp idx, 3
	je three

	cmp idx, 4
	je four

three:
	pop dx
	mov b, dl
	pop dx
	mov oper, dl
	pop dx

	cmp oper, '<'
	je Below
	cmp oper, '>'
	je Above

four:
	pop dx
	mov b, dl
	pop dx
	mov oper, dl
	pop dx
	mov oper, dl
	pop dx

	cmp oper, '='
	je Equal
	cmp oper, '<'
	je BelowOrEqual
	cmp oper, '>'
	je AboveOrEqual
	cmp oper, '!'
	je NotEqual
	
Below:
	cmp dl, b ;dl==a
	jb printOne
	jnb printZero

Above:
	cmp dl, b
	ja printOne
	jna printZero
	
Equal:
	cmp dl, b
	je printOne
	jne printZero

BelowOrEqual:
	cmp dl, b
	jbe printOne
	jnbe printZero

AboveOrEqual:
	cmp dl, b
	jae printOne
	jnae printZero

NotEqual:
	cmp dl, b
	jne printOne
	je printZero

printOne:
	mov dl, 31h
	mov ah, 02h
	int 21h
	jmp exit

printZero:
	mov dl, 30h
	mov ah, 02h
	int 21h

	;exit
exit:
    mov ax, 4c00h
    int 21h

end main
