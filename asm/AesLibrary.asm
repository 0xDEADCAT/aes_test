.data

; ------------------------------------------
; sbox for AES

sbox db 63H, 7cH, 77H, 7bH, 0f2H, 6bH, 6fH, 0c5H, 30H, 01H, 67H, 2bH, 0feH, 0d7H, 0abH, 76H
db 0caH, 82H, 0c9H, 7dH, 0faH, 59H, 47H, 0f0H, 0adH, 0d4H, 0a2H, 0afH, 9cH, 0a4H, 72H, 0c0H
db 0b7H, 0fdH, 93H, 26H, 36H, 3fH, 0f7H, 0ccH, 34H, 0a5H, 0e5H, 0f1H, 71H, 0d8H, 31H, 15H
db 04H, 0c7H, 23H, 0c3H, 18H, 96H, 05H, 9aH, 07H, 12H, 80H, 0e2H, 0ebH, 27H, 0b2H, 75H
db 09H, 83H, 2cH, 1aH, 1bH, 6eH, 5aH, 0a0H, 52H, 3bH, 0d6H, 0b3H, 29H, 0e3H, 2fH, 84H
db 53H, 0d1H, 00H, 0edH, 20H, 0fcH, 0b1H, 5bH, 6aH, 0cbH, 0beH, 39H, 4aH, 4cH, 58H, 0cfH
db 0d0H, 0efH, 0aaH, 0fbH, 43H, 4dH, 33H, 85H, 45H, 0f9H, 02H, 7fH, 50H, 3cH, 9fH, 0a8H
db 51H, 0a3H, 40H, 8fH, 92H, 9dH, 38H, 0f5H, 0bcH, 0b6H, 0daH, 21H, 10H, 0ffH, 0f3H, 0d2H
db 0cdH, 0cH, 13H, 0ecH, 5fH, 97H, 44H, 17H, 0c4H, 0a7H, 7eH, 3dH, 64H, 5dH, 19H, 73H
db 60H, 81H, 4fH, 0dcH, 22H, 2aH, 90H, 88H, 46H, 0eeH, 0b8H, 14H, 0deH, 5eH, 0bH, 0dbH
db 0e0H, 32H, 3aH, 0aH, 49H, 06H, 24H, 5cH, 0c2H, 0d3H, 0acH, 62H, 91H, 95H, 0e4H, 79H
db 0e7H, 0c8H, 37H, 6dH, 8dH, 0d5H, 4eH, 0a9H, 6cH, 56H, 0f4H, 0eaH, 65H, 7aH, 0aeH, 08H
db 0baH, 78H, 25H, 2eH, 1cH, 0a6H, 0b4H, 0c6H, 0e8H, 0ddH, 74H, 1fH, 4bH, 0bdH, 8bH, 8aH
db 70H, 3eH, 0b5H, 66H, 48H, 03H, 0f6H, 0eH, 61H, 35H, 57H, 0b9H, 86H, 0c1H, 1dH, 9eH
db 0e1H, 0f8H, 98H, 11H, 69H, 0d9H, 8eH, 94H, 9bH, 1eH, 87H, 0e9H, 0ceH, 55H, 28H, 0dfH
db 8cH, 0a1H, 89H, 0dH, 0bfH, 0e6H, 42H, 68H, 41H, 99H, 2dH, 0fH, 0b0H, 54H, 0bbH, 16H

;-------------------------------------------



.code
asmEncrypt proc
	movdqu	xmm0, [rcx]		; Move state to xmm0
	movdqu	xmm1, [rdx]		; Move first key to xmm1
	pxor	xmm0, xmm1		; Perform XOR on state with the key (AddRoundKey)

	push rbx
	
	pextrw eax, xmm0, 0		; extract word from XMM0 (state) into eax
	xor ebx, ebx
	mov bl, al				; move first byte of word into bl
	lea rsi, [sbox]			; get address of the sbox array
	mov al, [ rsi + rbx ]	; substitute first byte of word
	xor ebx, ebx
	mov bl, ah				; move second byte of word into bl
	mov ah, [ rsi + rbx ]	; substitute second byte of word
	psrldq xmm0, 2			; shift state to the right by two bytes

	pinsrw xmm0, eax, 7		; insert substituted bytes into two most significant bytes

	pop rbx

	ret
asmEncrypt endp
end