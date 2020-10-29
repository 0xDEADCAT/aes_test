SubBytes macro reg
	push rbx
	push rcx				; Push address of the state array on the stack
	mov rcx, 8				; Initialize SubBytes counter
LoopHead:
	pextrw eax, reg, 0		; extract word from reg (state) into eax
	xor ebx, ebx
	mov bl, al				; move first byte of word into bl
	lea rsi, [sbox]			; get address of the sbox array
	mov al, [ rsi + rbx ]	; substitute first byte of word
	xor ebx, ebx
	mov bl, ah				; move second byte of word into bl
	mov ah, [ rsi + rbx ]	; substitute second byte of word
	psrldq reg, 2			; shift state to the right by two bytes
	pinsrw reg, eax, 7		; insert substituted bytes into two most significant bytes of state
	dec rcx
	jnz	LoopHead
	pop rcx					; Retrieve address of the state array from the stack
	pop rbx
endm

ShiftRows macro reg
	pshufb	xmm0, [srMask]		; Shuffle bytes according to srMask
endm

MixColumns macro reg
	push rcx				; Push address of the state array on the stack

	mov rcx, 4

MixColumnsLoop:
	; Extract column from state
	pextrb r8, reg, 0
	pextrb r9, reg, 1		
	pextrb r10, reg, 2
	pextrb r11, reg, 3

	lea r13, [gf2]			; Get address of Galois Field multiplication by 2 lookup table
	mov r12b, [r13 + r8]	; Move first byte multiplied by 2 in GF into r12b

	lea r13, [gf3]			; Get address of Galois Field multiplication by 3 lookup table
	xor r12b, [r13 + r9]	; XOR second byte multiplied by 3 in GF with r12b

	xor r12b, r10b			; XOR Third byte of column with intermediate result in r12b
	xor r12b, r11b			; XOR Fourth byte of column with intermediate result in r12b
	psrldq reg, 1
	pinsrb reg, r12d, 15

	; First byte done

	mov r12b, r8b			; First byte

	lea r13, [gf2]
	xor r12b, [r13 + r9]	; xor with gf2 second byte

	lea r13, [gf3]
	xor r12b, [r13 + r10]	; xor with gf3 third byte

	xor r12b, r11b			; xor with fourth byte
	psrldq reg, 1
	pinsrb reg, r12d, 15

	; Second byte done

	mov r12b, r8b			; First byte

	xor r12b, r9b			; xor with second byte

	lea r13, [gf2]
	xor r12b, [r13 + r10]	; xor with gf2 third byte

	lea r13, [gf3]
	xor r12b, [r13 + r11]	; xor with gf3 fourth byte
	psrldq reg, 1
	pinsrb reg, r12d, 15

	; Third byte done

	lea r13, [gf3]
	mov r12b, [r13 + r8]	; First byte gf3 

	xor r12b, r9b			; xor with second byte

	xor r12b, r10b			; xor with  third byte

	lea r13, [gf2]
	xor r12b, [r13 + r11]	; xor with gf3 fourth byte
	psrldq reg, 1
	pinsrb reg, r12d, 15

	; Fourth byte done

	dec rcx
	jnz	MixColumnsLoop

	pop rcx					; Retrieve address of the state array from the stack
endm

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

;-------------------------------------------
; mask for ShiftRows
srMask db 00H, 5H, 0aH, 0fH, 04H, 09H, 0eH, 03H, 08H, 0dH, 02H, 07H, 0cH, 01H, 06H, 0bH
;-------------------------------------------

;-------------------------------------------
; Galois Field Multiplication by 2
gf2 db 00H, 02H, 04H, 06H, 08H, 0aH, 0cH, 0eH, 10H, 12H, 14H, 16H, 18H, 1aH, 1cH, 1eH
db 20H, 22H, 24H, 26H, 28H, 2aH, 2cH, 2eH, 30H, 32H, 34H, 36H, 38H, 3aH, 3cH, 3eH
db 40H, 42H, 44H, 46H, 48H, 4aH, 4cH, 4eH, 50H, 52H, 54H, 56H, 58H, 5aH, 5cH, 5eH
db 60H, 62H, 64H, 66H, 68H, 6aH, 6cH, 6eH, 70H, 72H, 74H, 76H, 78H, 7aH, 7cH, 7eH
db 80H, 82H, 84H, 86H, 88H, 8aH, 8cH, 8eH, 90H, 92H, 94H, 96H, 98H, 9aH, 9cH, 9eH
db 0a0H, 0a2H, 0a4H, 0a6H, 0a8H, 0aaH, 0acH, 0aeH, 0b0H, 0b2H, 0b4H, 0b6H, 0b8H, 0baH, 0bcH, 0beH
db 0c0H, 0c2H, 0c4H, 0c6H, 0c8H, 0caH, 0ccH, 0ceH, 0d0H, 0d2H, 0d4H, 0d6H, 0d8H, 0daH, 0dcH, 0deH
db 0e0H, 0e2H, 0e4H, 0e6H, 0e8H, 0eaH, 0ecH, 0eeH, 0f0H, 0f2H, 0f4H, 0f6H, 0f8H, 0faH, 0fcH, 0feH
db 1bH, 19H, 1fH, 1dH, 13H, 11H, 17H, 15H, 0bH, 09H, 0fH, 0dH, 03H, 01H, 07H, 05H
db 3bH, 39H, 3fH, 3dH, 33H, 31H, 37H, 35H, 2bH, 29H, 2fH, 2dH, 23H, 21H, 27H, 25H
db 5bH, 59H, 5fH, 5dH, 53H, 51H, 57H, 55H, 4bH, 49H, 4fH, 4dH, 43H, 41H, 47H, 45H
db 7bH, 79H, 7fH, 7dH, 73H, 71H, 77H, 75H, 6bH, 69H, 6fH, 6dH, 63H, 61H, 67H, 65H
db 9bH, 99H, 9fH, 9dH, 93H, 91H, 97H, 95H, 8bH, 89H, 8fH, 8dH, 83H, 81H, 87H, 85H
db 0bbH, 0b9H, 0bfH, 0bdH, 0b3H, 0b1H, 0b7H, 0b5H, 0abH, 0a9H, 0afH, 0adH, 0a3H, 0a1H, 0a7H, 0a5H
db 0dbH, 0d9H, 0dfH, 0ddH, 0d3H, 0d1H, 0d7H, 0d5H, 0cbH, 0c9H, 0cfH, 0cdH, 0c3H, 0c1H, 0c7H, 0c5H
db 0fbH, 0f9H, 0ffH, 0fdH, 0f3H, 0f1H, 0f7H, 0f5H, 0ebH, 0e9H, 0efH, 0edH, 0e3H, 0e1H, 0e7H, 0e5H
;-------------------------------------------


;-------------------------------------------
; Galois Field Multiplication by 3
gf3 db 00H, 03H, 06H, 05H, 0cH, 0fH, 0aH, 09H, 18H, 1bH, 1eH, 1dH, 14H, 17H, 12H, 11H
db 30H, 33H, 36H, 35H, 3cH, 3fH, 3aH, 39H, 28H, 2bH, 2eH, 2dH, 24H, 27H, 22H, 21H
db 60H, 63H, 66H, 65H, 6cH, 6fH, 6aH, 69H, 78H, 7bH, 7eH, 7dH, 74H, 77H, 72H, 71H
db 50H, 53H, 56H, 55H, 5cH, 5fH, 5aH, 59H, 48H, 4bH, 4eH, 4dH, 44H, 47H, 42H, 41H
db 0c0H, 0c3H, 0c6H, 0c5H, 0ccH, 0cfH, 0caH, 0c9H, 0d8H, 0dbH, 0deH, 0ddH, 0d4H, 0d7H, 0d2H, 0d1H
db 0f0H, 0f3H, 0f6H, 0f5H, 0fcH, 0ffH, 0faH, 0f9H, 0e8H, 0ebH, 0eeH, 0edH, 0e4H, 0e7H, 0e2H, 0e1H
db 0a0H, 0a3H, 0a6H, 0a5H, 0acH, 0afH, 0aaH, 0a9H, 0b8H, 0bbH, 0beH, 0bdH, 0b4H, 0b7H, 0b2H, 0b1H
db 90H, 93H, 96H, 95H, 9cH, 9fH, 9aH, 99H, 88H, 8bH, 8eH, 8dH, 84H, 87H, 82H, 81H
db 9bH, 98H, 9dH, 9eH, 97H, 94H, 91H, 92H, 83H, 80H, 85H, 86H, 8fH, 8cH, 89H, 8aH
db 0abH, 0a8H, 0adH, 0aeH, 0a7H, 0a4H, 0a1H, 0a2H, 0b3H, 0b0H, 0b5H, 0b6H, 0bfH, 0bcH, 0b9H, 0baH
db 0fbH, 0f8H, 0fdH, 0feH, 0f7H, 0f4H, 0f1H, 0f2H, 0e3H, 0e0H, 0e5H, 0e6H, 0efH, 0ecH, 0e9H, 0eaH
db 0cbH, 0c8H, 0cdH, 0ceH, 0c7H, 0c4H, 0c1H, 0c2H, 0d3H, 0d0H, 0d5H, 0d6H, 0dfH, 0dcH, 0d9H, 0daH
db 5bH, 58H, 5dH, 5eH, 57H, 54H, 51H, 52H, 43H, 40H, 45H, 46H, 4fH, 4cH, 49H, 4aH
db 6bH, 68H, 6dH, 6eH, 67H, 64H, 61H, 62H, 73H, 70H, 75H, 76H, 7fH, 7cH, 79H, 7aH
db 3bH, 38H, 3dH, 3eH, 37H, 34H, 31H, 32H, 23H, 20H, 25H, 26H, 2fH, 2cH, 29H, 2aH
db 0bH, 08H, 0dH, 0eH, 07H, 04H, 01H, 02H, 13H, 10H, 15H, 16H, 1fH, 1cH, 19H, 1aH
;-------------------------------------------

.code
asmEncrypt proc
	movdqu	xmm0, [rcx]		; Move state to xmm0
	movdqu	xmm1, [rdx]		; Move first key to xmm1
	pxor	xmm0, xmm1		; Perform XOR on state with the key (AddRoundKey)

	SubBytes xmm0
	ShiftRows xmm0
	MixColumns xmm0

	

	ret
asmEncrypt endp
end