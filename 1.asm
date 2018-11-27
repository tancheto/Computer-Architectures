model small
stack 256

.data
a db 1
b db 2
c db 3
			
.code

main:	
	mov ax, @data
	mov ds, ax

	xor ax, ax
	xor dx, dx

	mov al, a
	mov dl, c
	xor al, dl

	xor dx,dx 

	mov dl, b
	and al, dl

	not al

	xor dx,dx

	mov  dx, ax

	mov ah, 02h
	int 21h

exit:
	mov ax, 4c00h
	int 21h
end	main
