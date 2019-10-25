masm
model small
.data
	handle	dw	0 
	filename	db	100 dup (0)
	buffer db 1000 dup ('$')
	errMsg db 'Can not open file.$'
	inputErrMsg db 13,10,'Your input is not valid!',13,10,'$'
	startMsg db 'Insert a digit:',13,10,'1-to find a word',13,10,'2-to find number of sentences',13,10,'3-to find punctuation signs',13,10,'$'
	caseSens db 13,10,'Insert a digit:',13,10,'0 for case insensitive search',13,10,'1 for case sensitive search',13,10,'$'
	whole db 13,10,'Insert a digit:',13,10,'0 for whole word search',13,10,'1 for substring search',13,10,'$'
	punctSign db 13,10,'Insert a punctuation sign to search for:',13,10,'$'
	fileMsg db 'Insert filename: $'
	wordMsg db 13,10,'Insert a word to find: $'
	wordToFind db 100 dup('$')
	signToFind db ' '
	wordLen dw 0
	prev db ' '
	rowCopy dw 0
	wordNumCopy dw 0
	row dw 1
	wordNum dw 1
	total dw 0
	punctCounter dw 0
	sentCounter dw 0
	divis db 10
	r db 'Row: $'
	w db 'Word number: $'
	t db 13,10,'Total: $'
	
.stack	256
.code
main:
	mov ax, @data
	mov ds, ax
	xor cx, cx

lea dx, fileMsg
mov ah, 09h
int 21h
xor di,di
fileInput:		
	mov ah, 01h
	int 21h
	cmp al, 13
	je open
	cmp al, 10
	je open
	mov filename[di],al
	inc di
	jmp fileInput

open:
	lea dx, filename
	mov al, 02h
	mov ah, 3dh
	mov cx, 0h
	int 21h
	mov handle, ax
	jc error2

read:
	xor ax,ax
	mov ah, 3fh
	mov bx, handle
	mov cx, 1000h
	lea dx, buffer
	int 21h
	mov handle, ax

start:	
	lea dx, startMsg
	mov ah, 09h
	int 21h

	insertNum:
		mov ah, 01h
		int 21h
		cmp al, '1'
		je one
		cmp al, '2'
		je two2
		cmp al, '3'
		je three2
		jmp inputErr

	one:
		lea dx, wordMsg
		mov ah, 09h
		int 21h
		xor di,di
	wordInput:		
		mov ah, 01h
		int 21h
		cmp al, 13
		je sensChoice
		cmp al, 10
		je sensChoice
		mov wordToFind[di],al
		inc di
		jmp wordInput

	sensChoice:
		cmp di, 0
		je inputErr2
		mov wordLen,di
		lea dx, caseSens
		mov ah, 09h
		int 21h
		mov ah, 01h
		int 21h
		cmp al,'0'
		je caseInsensitive
		cmp al,'1'
		je caseSensitive
		jmp inputErr

		caseInsensitive:
			lea dx, whole
			mov ah, 09h
			int 21h
			mov ah, 01h
			int 21h
			cmp al,'0'
			je insWhole2
			cmp al,'1'
			je insSub
			jmp inputErr2

	error2:
		jmp error
	two2:
		jmp two	
	three2:
		jmp three

	inputErr2:
		lea dx, inputErrMsg
		mov ah, 09h
		int 21h
		jmp exit	

		caseSensitive:
			lea dx, whole
			mov ah, 09h
			int 21h
			mov ah, 01h
			int 21h
			cmp al,'0'
			je sensWhole2
			cmp al,'1'
			je sensSub2
			jmp inputErr

			insSub:	
				lea bx, buffer
				checkFileIS:
					mov dx, [bx]
					jmp handleSymbolIS
				incrementIS:
					inc bx
					jmp checkFileIS

				handleSymbolIS:
					cmp dl, '$'
					je totalHandleIS
					cmp dl,10
					je rowHandleIS
					cmp dl,' '
					je wordHandleIS
					cmp dl,'A'
					jae isUpperIS
					jb normalIS2

				insWhole2:
					jmp insWhole	

				rowHandleIS:
					inc row
					mov wordNum,1
					jmp incrementIS

				wordHandleIS:
					inc	wordNum
					jmp incrementIS

				totalHandleIS:
					lea dx, t
					mov ah, 09h
					int 21h
					xor cx,cx	
				totalLoopIS:
					mov ax, total	
					cmp ax, 9
					jbe totalDigitIS
					div divis
					mov dl,ah
					xor ah,ah
					mov total,ax
					push dx
					inc cx 
					jmp totalLoopIS

				totalDigitIS:
					push ax
					inc cx
					jmp totalPrintIS

				totalPrintIS:
					pop dx
					add dl, '0'
					mov ah, 02h
					int 21h
					loop totalPrintIS
					jmp close

				normalIS2:
					jmp normalIS
				sensSub2:
					jmp sensSub	
				close2:
					jmp close 
				sensWhole2:
					jmp sensWhole		

				isUpperIS:
					cmp dl, 'Z'
					jbe upperIS
					ja isLowerIS

				isLowerIS:
					cmp dl, 'a'
					jae isLower2IS
					jb normalIS

				isLower2IS:	
					cmp dl, 'z'
					jbe lowerIS
					ja normalIS	

				upperIS:
					cmp dl, wordToFind[0]
					je checkWordIS
					add dl, 32
					cmp dl, wordToFind[0]
					je checkWordIS
					jmp incrementIS		

				lowerIS:
					cmp dl, wordToFind[0]
					je checkWordIS
					sub dl, 32
					cmp dl, wordToFind[0]
					je checkWordIS
					jmp incrementIS
	

				normalIS:
					cmp dl, wordToFind[0]
					je checkWordIS
					jmp incrementIS

				isUpper_IS:
					cmp dl, 'Z'
					jbe upper_IS
					ja isLower_IS

				isLower_IS:
					cmp dl, 'a'
					jae isLower2_IS
					jb normal_IS

				isLower2_IS:	
					cmp dl, 'z'
					jbe lower_IS
					ja normal_IS	

				upper_IS:
					cmp dl, [si]
					je check2IS
					add dl, 32
					cmp dl, [si]
					je check2IS
					jmp incrementIS

				lower_IS:
					cmp dl, [si]
					je check2IS
					sub dl, 32
					cmp dl, [si]
					je check2IS
					jmp incrementIS

				normal_IS:
					cmp dl, [si]
					je check2IS
					jmp incrementIS	

				checkWordIS:
					xor cx,cx 
					mov cx,wordLen
					lea si, wordToFind
				loopCheckWordIS:
					mov dx,[bx]
				check1IS:
					cmp dl, 'A'
					jae isUpper_IS
					jb normal_IS
				check2IS:	
					inc si
					inc bx
					loop loopCheckWordIS

				printTrueIS:
					call printTrue
					jmp checkFileIS

			insWhole:
				lea bx, buffer
				checkFileIW:
					mov dx, [bx]
					jmp handleSymbolIW
				incrementIW:
					mov prev,dl
					inc bx
					jmp checkFileIW

				handleSymbolIW:
					cmp dl,'$'
					je totalHandleIW
					cmp dl,10
					je rowHandleIW
					cmp dl,' '
					je wordHandleIW	
					cmp dl,'A'
					jae isUpperIW
					jb normalIW2

				rowHandleIW:
					inc row
					mov wordNum,1
					jmp incrementIW

				wordHandleIW:
					inc	wordNum
					jmp incrementIW

				totalHandleIW:
					lea dx, t
					mov ah, 09h
					int 21h
					xor cx,cx	
				totalLoopIW:
					mov ax, total	
					cmp ax, 9
					jbe totalDigitIW
					div divis
					mov dl,ah
					xor ah,ah
					mov total,ax
					push dx
					inc cx 
					jmp totalLoopIW

				totalDigitIW:
					push ax
					inc cx
					jmp totalPrintIW

				totalPrintIW:
					pop dx
					add dl, '0'
					mov ah, 02h
					int 21h
					loop totalPrintIW
					jmp close

				isUpperIW:
					cmp dl, 'Z'
					jbe upperIW
					ja isLowerIW

				isLowerIW:
					cmp dl, 'a'
					jae isLower2IW
					jb normalIW

				isLower2IW:	
					cmp dl, 'z'
					jbe lowerIW
					ja normalIW	

				normalIW2:
					jmp normalIW
				checkWordIW2:
					jmp checkWordIW	

				lowerIW:
					cmp dl, wordToFind[0]
					je checkPrevIW
					sub dl, 32
					cmp dl, wordToFind[0]
					je checkPrevIW
					jmp incrementIW

				upperIW:
					cmp dl, wordToFind[0]
					je checkPrevIW	
					add dl, 32
					cmp dl, wordToFind[0]
					je checkPrevIW
					jmp incrementIW	

				checkPrevIW:
					cmp prev,' '
					je checkWordIW2
					cmp prev, '.'
					je checkWordIW2
					cmp prev, ','
					je checkWordIW2
					cmp prev, '!'
					je checkWordIW2
					cmp prev, '?'
					je checkWordIW2
					cmp prev, '-'
					je checkWordIW2
					cmp prev, 13
					je checkWordIW2
					cmp prev, 10
					je checkWordIW2
					jmp incrementIW

				normalIW:
					cmp dl, wordToFind[0]
					je checkPrevIW
					jmp incrementIW		

				isUpper_IW:
					cmp dl, 'Z'
					jbe upper_IW
					ja isLower_IW	

				isLower_IW:
					cmp dl, 'a'
					jae isLower2_IW
					jb normal_IW

				isLower2_IW:	
					cmp dl, 'z'
					jbe lower_IW
					ja normal_IW	

				upper_IW:
					cmp dl, [si]
					je check2IW
					add dl, 32
					cmp dl, [si]
					je check2IW
					jmp incrementIW

				lower_IW:
					cmp dl, [si]
					je check2IW
					sub dl, 32
					cmp dl, [si]
					je check2IW
					jmp incrementIW

				normal_IW:
					cmp dl, [si]
					je check2IW
					jmp incrementIW	

				checkWordIW:
					xor cx,cx 
					mov cx,wordLen
					lea si, wordToFind
				loopCheckWordIW:
					mov dx,[bx]
				check1IW:
					cmp dl, 'A'
					jae isUpper_IW
					jb normal_IW
				check2IW:
					mov prev,dl		
					inc si
					inc bx
					loop loopCheckWordIW

				checkNextIW:
					mov dx,[bx]
					cmp dl,' '
					je printTrueIW
					cmp dl, '.'
					je printTrueIW
					cmp dl, ','
					je printTrueIW
					cmp dl, '!'
					je printTrueIW
					cmp dl, '?'
					je printTrueIW
					cmp dl, '-'
					je printTrueIW
					cmp dl, 13
					je printTrueIW
					cmp dl, 10
					je printTrueIW
					cmp dl, '$'
					je printTrueIW
					jmp checkFileIW		

				printTrueIW:
					call printTrue
					jmp checkFileIW

printTrue:
	xor dx,dx
	mov dx,10
	mov ah, 02h
	int 21h
	inc total
	lea dx,r 
	mov ah, 09h
	int 21h
	xor cx, cx
	mov dx,row
	mov rowCopy,dx
	xor dx,dx
rowLoop:
	mov ax, row
	cmp ax, 9
	jbe rowDigit
	div divis
	mov dl,ah
	xor ah,ah
	mov row,ax
	push dx
	inc cx 
	jmp rowLoop
rowDigit:
	push ax
	inc cx
	jmp rowPrint
rowPrint:
	pop dx
	add dl, '0'
	mov ah, 02h
	int 21h
	loop rowPrint
	mov dx,rowCopy
	mov row,dx
	xor dx,dx
	mov dx,''
	mov ah, 02h
	int 21h
	lea dx,w
	mov ah, 09h
	int 21h
	xor cx, cx
	mov dx,wordNum
	mov wordNumCopy,dx
	xor dx,dx
wordLoop:
	mov ax, wordNum
	cmp ax, 9
	jbe wordDigit
	div divis
	mov dl,ah
	xor ah,ah
	mov wordNum,ax
	push dx
	inc cx 
	jmp wordLoop
wordDigit:
	push ax 
	inc cx
	jmp wordPrint
wordPrint:
	pop dx
	add dl, '0'
	mov ah, 02h
	int 21h
	loop wordPrint
	mov dx,wordNumCopy
	mov wordNum,dx
ret	


			sensWhole:
				lea bx, buffer
				checkFileSW:
					mov dx, [bx]
					jmp handleSymbolSW
				incrementSW:
					mov prev,dl
					inc bx
					jmp checkFileSW

				handleSymbolSW:
					cmp dl, '$'
					je totalHandleSW
					cmp dl,wordToFind[0]
					je checkPrevSW
					cmp dl,10
					je rowHandleSW
					cmp dl,' '
					je wordHandleSW
					jmp incrementSW

				rowHandleSW:
					inc row
					mov wordNum,1
					jmp incrementSW

				wordHandleSW:
					inc	wordNum
					jmp incrementSW

				totalHandleSW:
					lea dx, t
					mov ah, 09h
					int 21h
					xor cx,cx	
				totalLoopSW:
					mov ax, total	
					cmp ax, 9
					jbe totalDigitSW
					div divis
					mov dl,ah
					xor ah,ah
					mov total,ax
					push dx
					inc cx 
					jmp totalLoopSW

				totalDigitSW:
					push ax
					inc cx
					jmp totalPrintSW

				totalPrintSW:
					pop dx
					add dl, '0'
					mov ah, 02h
					int 21h
					loop totalPrintSW
					jmp close

				close3:
					jmp close

				incrementSW2:
					jmp incrementSW			

				checkPrevSW:
					cmp prev,' '
					je checkWordSW
					cmp prev, '.'
					je checkWordSW
					cmp prev, ','
					je checkWordSW
					cmp prev, '!'
					je checkWordSW
					cmp prev, '?'
					je checkWordSW
					cmp prev, '-'
					je checkWordSW
					cmp prev, 13
					je checkWordSW
					cmp prev, 10
					je checkWordSW
					jmp incrementSW	
					
				checkWordSW:
					xor cx,cx 
					mov cx,wordLen
					lea si, wordToFind
				loopCheckWordSW:
					mov dx,[bx]
					cmp dl,[si]
					jne incrementSW2	
					mov prev,dl
					inc si
					inc bx
					loop loopCheckWordSW

				checkNextSW:
					mov dx,[bx]
					cmp dl,' '
					je printTrueSW
					cmp dl, '.'
					je printTrueSW
					cmp dl, ','
					je printTrueSW
					cmp dl, '!'
					je printTrueSW
					cmp dl, '?'
					je printTrueSW
					cmp dl, '-'
					je printTrueSW
					cmp dl, 13
					je printTrueSW
					cmp dl, 10
					je printTrueSW
					cmp dl, '$'
					je printTrueSW	
					jmp checkFileSW

				printTrueSW:
					call printTrue
					jmp checkFileSW

				sensSub:
					lea bx, buffer
					checkFileSS:
						mov dx, [bx]
						jmp handleSymbolSS
					incrementSS:
						inc bx
						jmp checkFileSS	

					handleSymbolSS:
						cmp dl, '$'
						je totalHandleSS
						cmp dl,wordToFind[0]
						je checkWordSS
						cmp dl,10
						je rowHandleSS
						cmp dl,' '
						je wordHandleSS
						jmp incrementSS

					rowHandleSS:
						inc row
						mov wordNum,1
						jmp incrementSS
					wordHandleSS:
						inc	wordNum
						jmp incrementSS

					totalHandleSS:
						lea dx, t
						mov ah, 09h
						int 21h	
						xor cx,cx
					totalLoopSS:
						mov ax, total	
						cmp ax, 9
						jbe totalDigitSS
						div divis
						mov dl,ah
						xor ah,ah
						mov total,ax
						push dx
						inc cx 
						jmp totalLoopSS

					totalDigitSS:
						push ax
						inc cx
						jmp totalPrintSS

					totalPrintSS:
						pop dx
						add dl, '0'
						mov ah, 02h
						int 21h
						loop totalPrintSS
						jmp close

					checkWordSS:
						xor cx,cx 
						mov cx,wordLen
						lea si, wordToFind
					loopCheckWordSS:
						mov dx,[bx]
						cmp dl,[si]
						jne incrementSS
						inc si
						inc bx
						loop loopCheckWordSS

						call printTrue
						jmp checkFileSS

	two:
		lea bx, buffer
		checkFileSent:
			mov dx, [bx]
			cmp dl, '$'
			je printSent
			jmp checkSent
		checkSent:
			cmp dl, '.'
			je incrSent
			cmp dl, '!'
			je incrSent
			cmp dl, '?'
			je incrSent
		incrFileSent:
			inc bx
			jmp checkFileSent

		incrSent:
			inc sentCounter
			jmp incrFileSent	

		printSent:
			lea dx,t
			mov ah,09h
			int 21h
			xor cx,cx
		sentLoop:
			mov ax, sentCounter
			cmp ax, 9
			jbe sentDigit
			div divis
			mov dl,ah
			xor ah,ah
			mov sentCounter,ax
			push dx
			inc cx 
			jmp sentLoop

		sentDigit:
			push ax
			inc cx
			jmp sentPrint	

		sentPrint:
			pop dx
			add dl, '0'
			mov ah, 02h
			int 21h
			loop sentPrint
			jmp close

	three:
		lea dx, punctSign
		mov ah, 09h
		int 21h
		mov ah, 01h
		int 21h
		mov signToFind,al	
		jmp checkPunct

		checkPunct:
			cmp signToFind, '.'
			je ifPunct
			cmp signToFind, ','
			je ifPunct
			cmp signToFind, '!'
			je ifPunct
			cmp signToFind, '?'
			je ifPunct
			cmp signToFind, '-'
			je ifPunct
			jmp inputErr

		ifPunct: 
			lea bx, buffer
			checkFilePunct:
				mov dx, [bx]
				cmp dl, '$'
				je printPunct
				cmp dl, signToFind
				je incrPunct
			incrFilePunct:
				inc bx
				jmp checkFilePunct	
			incrPunct:
				inc punctCounter
				jmp incrFilePunct	
			printPunct:
				lea dx,t
				mov ah,09h
				int 21h
				xor cx,cx
			punctLoop:
				mov ax, punctCounter
				cmp ax, 9
				jbe punctDigit
				div divis
				mov dl,ah
				xor ah,ah
				mov punctCounter,ax
				push dx
				inc cx 
				jmp punctLoop

			punctDigit:
				push ax
				inc cx
				jmp punctPrint	

			punctPrint:
				pop dx
				add dl, '0'
				mov ah, 02h
				int 21h
				loop punctPrint
				jmp close

inputErr:
	lea dx, inputErrMsg
	mov ah, 09h
	int 21h
	jmp exit

error:	
	lea dx, errMsg
	mov ah, 09h
	int 21h

close:
	mov ah, 3eh
	mov bx, handle
	int 21h 
	jmp exit

exit:
    mov ax, 4c00h
    int 21h
end main