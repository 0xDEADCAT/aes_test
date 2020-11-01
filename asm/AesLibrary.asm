SubBytes macro reg, sbox
	LOCAL SubBytesLoop
	push rbx
	push rcx				; Push address of the state array on the stack
	mov rcx, 8				; Initialize SubBytes counter
SubBytesLoop:
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
	jnz	SubBytesLoop
	pop rcx					; Retrieve address of the state array from the stack
	pop rbx
endm

ShiftRows macro reg
	pshufb reg, [srMask]		; Shuffle bytes according to srMask
endm

MixColumns macro reg
	LOCAL MixColumnsLoop
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

InvShiftRows macro reg
	pshufb reg, [invSrMask]		; Shuffle bytes according to srMask
endm

InvMixColumns macro reg
	LOCAL InvMixColumnsLoop
	push rcx				; Push address of the state array on the stack

	mov rcx, 4				; Initialize loop counter for InvMixColumnsLoop

InvMixColumnsLoop:
	; Extract column from state
	pextrb r8, reg, 0
	pextrb r9, reg, 1		
	pextrb r10, reg, 2
	pextrb r11, reg, 3
	
	; Begin first byte calculation

	lea r13, [gf14]			; Get address of Galois Field multiplication by 14 lookup table
	mov r12b, [r13 + r8]	; Move first byte multiplied by 14 in GF into r12b

	lea r13, [gf11]			; Get address of Galois Field multiplication by 11 lookup table
	xor r12b, [r13 + r9]	; XOR second byte multiplied by 11 in GF with r12b

	lea r13, [gf13]			; Get address of Galois Field multiplication by 13 lookup table
	xor r12b, [r13 + r10]	; XOR Third byte multiplied by 13 in GF with r12b

	lea r13, [gf9]			; Get address of Galois Field multiplication by 9 lookup table
	xor r12b, [r13 + r11]	; XOR Fourth byte multiplied by 9 in GF with r12b
	psrldq reg, 1			; Shift state register one byte to the right
	pinsrb reg, r12d, 15	; Insert calculated byte at most significant byte

	; First byte done

	; Begin second byte calculation

	mov r12b, [r13 + r8]	; Move first byte multiplied by 9 in GF into r12b (r13 already contains gf9 address)

	lea r13, [gf14]			; Get address of Galois Field multiplication by 14 lookup table
	xor r12b, [r13 + r9]	; XOR second byte multiplied by 14 in GF with r12b

	lea r13, [gf11]			; Get address of Galois Field multiplication by 11 lookup table
	xor r12b, [r13 + r10]	; XOR Third byte multiplied by 11 in GF with r12b

	lea r13, [gf13]			; Get address of Galois Field multiplication by 13 lookup table
	xor r12b, [r13 + r11]	; XOR Fourth byte multiplied by 13 in GF with r12b
	psrldq reg, 1			; Shift state register one byte to the right
	pinsrb reg, r12d, 15	; Insert calculated byte at most significant byte

	; Second byte done

	; Begin third byte calculation

	mov r12b, [r13 + r8]	; Move first byte multiplied by 13 in GF into r12b (r13 already contains gf13 address)

	lea r13, [gf9]			; Get address of Galois Field multiplication by 9 lookup table
	xor r12b, [r13 + r9]	; XOR second byte multiplied by 9 in GF with r12b

	lea r13, [gf14]			; Get address of Galois Field multiplication by 14 lookup table
	xor r12b, [r13 + r10]	; XOR Third byte multiplied by 14 in GF with r12b

	lea r13, [gf11]			; Get address of Galois Field multiplication by 11 lookup table
	xor r12b, [r13 + r11]	; XOR Fourth byte multiplied by 11 in GF with r12b
	psrldq reg, 1			; Shift state register one byte to the right
	pinsrb reg, r12d, 15	; Insert calculated byte at most significant byte

	; Third byte done

	; Begin fourth byte calculation
	
	mov r12b, [r13 + r8]	; Move first byte multiplied by 11 in GF into r12b (r13 already contains gf11 address)

	lea r13, [gf13]			; Get address of Galois Field multiplication by 13 lookup table
	xor r12b, [r13 + r9]	; XOR second byte multiplied by 13 in GF with r12b

	lea r13, [gf9]			; Get address of Galois Field multiplication by 9 lookup table
	xor r12b, [r13 + r10]	; XOR Third byte multiplied by 9 in GF with r12b

	lea r13, [gf14]			; Get address of Galois Field multiplication by 14 lookup table
	xor r12b, [r13 + r11]	; XOR Fourth byte multiplied by 14 in GF with r12b
	psrldq reg, 1			; Shift state register one byte to the right
	pinsrb reg, r12d, 15	; Insert calculated byte at most significant byte

	; Fourth byte done

	dec rcx
	jnz	InvMixColumnsLoop

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
; inverse sbox for InvSubBytes
invSbox db 52H, 09H, 6aH, 0d5H, 30H, 36H, 0a5H, 38H, 0bfH, 40H, 0a3H, 9eH, 81H, 0f3H, 0d7H, 0fbH
db 7cH, 0e3H, 39H, 82H, 9bH, 2fH, 0ffH, 87H, 34H, 8eH, 43H, 44H, 0c4H, 0deH, 0e9H, 0cbH
db 54H, 7bH, 94H, 32H, 0a6H, 0c2H, 23H, 3dH, 0eeH, 4cH, 95H, 0bH, 42H, 0faH, 0c3H, 4eH
db 08H, 2eH, 0a1H, 66H, 28H, 0d9H, 24H, 0b2H, 76H, 5bH, 0a2H, 49H, 6dH, 8bH, 0d1H, 25H
db 72H, 0f8H, 0f6H, 64H, 86H, 68H, 98H, 16H, 0d4H, 0a4H, 5cH, 0ccH, 5dH, 65H, 0b6H, 92H
db 6cH, 70H, 48H, 50H, 0fdH, 0edH, 0b9H, 0daH, 5eH, 15H, 46H, 57H, 0a7H, 8dH, 9dH, 84H
db 90H, 0d8H, 0abH, 00H, 8cH, 0bcH, 0d3H, 0aH, 0f7H, 0e4H, 58H, 05H, 0b8H, 0b3H, 45H, 06H
db 0d0H, 2cH, 1eH, 8fH, 0caH, 3fH, 0fH, 02H, 0c1H, 0afH, 0bdH, 03H, 01H, 13H, 8aH, 6bH
db 3aH, 91H, 11H, 41H, 4fH, 67H, 0dcH, 0eaH, 97H, 0f2H, 0cfH, 0ceH, 0f0H, 0b4H, 0e6H, 73H
db 96H, 0acH, 74H, 22H, 0e7H, 0adH, 35H, 85H, 0e2H, 0f9H, 37H, 0e8H, 1cH, 75H, 0dfH, 6eH
db 47H, 0f1H, 1aH, 71H, 1dH, 29H, 0c5H, 89H, 6fH, 0b7H, 62H, 0eH, 0aaH, 18H, 0beH, 1bH
db 0fcH, 56H, 3eH, 4bH, 0c6H, 0d2H, 79H, 20H, 9aH, 0dbH, 0c0H, 0feH, 78H, 0cdH, 5aH, 0f4H
db 1fH, 0ddH, 0a8H, 33H, 88H, 07H, 0c7H, 31H, 0b1H, 12H, 10H, 59H, 27H, 80H, 0ecH, 5fH
db 60H, 51H, 7fH, 0a9H, 19H, 0b5H, 4aH, 0dH, 2dH, 0e5H, 7aH, 9fH, 93H, 0c9H, 9cH, 0efH
db 0a0H, 0e0H, 3bH, 4dH, 0aeH, 2aH, 0f5H, 0b0H, 0c8H, 0ebH, 0bbH, 3cH, 83H, 53H, 99H, 61H
db 17H, 2bH, 04H, 7eH, 0baH, 77H, 0d6H, 26H, 0e1H, 69H, 14H, 63H, 55H, 21H, 0cH, 7dH
;-------------------------------------------

;-------------------------------------------
; mask for ShiftRows
srMask db 00H, 5H, 0aH, 0fH, 04H, 09H, 0eH, 03H, 08H, 0dH, 02H, 07H, 0cH, 01H, 06H, 0bH
;-------------------------------------------

;-------------------------------------------
; mask for InvShiftRows
invSrMask db 00H, 0dH, 0aH, 07H, 04H, 01H, 0eH, 0bH, 08H, 05H, 02H, 0fH, 0cH, 09H, 06H, 03H
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

;-------------------------------------------
; Galois Field Multiplication by 9
gf9 db 00H, 09H, 12H, 1bH, 24H, 2dH, 36H, 3fH, 48H, 41H, 5aH, 53H, 6cH, 65H, 7eH, 77H
db 90H, 99H, 82H, 8bH, 0b4H, 0bdH, 0a6H, 0afH, 0d8H, 0d1H, 0caH, 0c3H, 0fcH, 0f5H, 0eeH, 0e7H
db 3bH, 32H, 29H, 20H, 1fH, 16H, 0dH, 04H, 73H, 7aH, 61H, 68H, 57H, 5eH, 45H, 4cH
db 0abH, 0a2H, 0b9H, 0b0H, 8fH, 86H, 9dH, 94H, 0e3H, 0eaH, 0f1H, 0f8H, 0c7H, 0ceH, 0d5H, 0dcH
db 76H, 7fH, 64H, 6dH, 52H, 5bH, 40H, 49H, 3eH, 37H, 2cH, 25H, 1aH, 13H, 08H, 01H
db 0e6H, 0efH, 0f4H, 0fdH, 0c2H, 0cbH, 0d0H, 0d9H, 0aeH, 0a7H, 0bcH, 0b5H, 8aH, 83H, 98H, 91H
db 4dH, 44H, 5fH, 56H, 69H, 60H, 7bH, 72H, 05H, 0cH, 17H, 1eH, 21H, 28H, 33H, 3aH
db 0ddH, 0d4H, 0cfH, 0c6H, 0f9H, 0f0H, 0ebH, 0e2H, 95H, 9cH, 87H, 8eH, 0b1H, 0b8H, 0a3H, 0aaH
db 0ecH, 0e5H, 0feH, 0f7H, 0c8H, 0c1H, 0daH, 0d3H, 0a4H, 0adH, 0b6H, 0bfH, 80H, 89H, 92H, 9bH
db 7cH, 75H, 6eH, 67H, 58H, 51H, 4aH, 43H, 34H, 3dH, 26H, 2fH, 10H, 19H, 02H, 0bH
db 0d7H, 0deH, 0c5H, 0ccH, 0f3H, 0faH, 0e1H, 0e8H, 9fH, 96H, 8dH, 84H, 0bbH, 0b2H, 0a9H, 0a0H
db 47H, 4eH, 55H, 5cH, 63H, 6aH, 71H, 78H, 0fH, 06H, 1dH, 14H, 2bH, 22H, 39H, 30H
db 9aH, 93H, 88H, 81H, 0beH, 0b7H, 0acH, 0a5H, 0d2H, 0dbH, 0c0H, 0c9H, 0f6H, 0ffH, 0e4H, 0edH
db 0aH, 03H, 18H, 11H, 2eH, 27H, 3cH, 35H, 42H, 4bH, 50H, 59H, 66H, 6fH, 74H, 7dH
db 0a1H, 0a8H, 0b3H, 0baH, 85H, 8cH, 97H, 9eH, 0e9H, 0e0H, 0fbH, 0f2H, 0cdH, 0c4H, 0dfH, 0d6H
db 31H, 38H, 23H, 2aH, 15H, 1cH, 07H, 0eH, 79H, 70H, 6bH, 62H, 5dH, 54H, 4fH, 46H
;-------------------------------------------

;-------------------------------------------
; Galois Field Multiplication by 11
gf11 db 00H, 0bH, 16H, 1dH, 2cH, 27H, 3aH, 31H, 58H, 53H, 4eH, 45H, 74H, 7fH, 62H, 69H
db 0b0H, 0bbH, 0a6H, 0adH, 9cH, 97H, 8aH, 81H, 0e8H, 0e3H, 0feH, 0f5H, 0c4H, 0cfH, 0d2H, 0d9H
db 7bH, 70H, 6dH, 66H, 57H, 5cH, 41H, 4aH, 23H, 28H, 35H, 3eH, 0fH, 04H, 19H, 12H
db 0cbH, 0c0H, 0ddH, 0d6H, 0e7H, 0ecH, 0f1H, 0faH, 93H, 98H, 85H, 8eH, 0bfH, 0b4H, 0a9H, 0a2H
db 0f6H, 0fdH, 0e0H, 0ebH, 0daH, 0d1H, 0ccH, 0c7H, 0aeH, 0a5H, 0b8H, 0b3H, 82H, 89H, 94H, 9fH
db 46H, 4dH, 50H, 5bH, 6aH, 61H, 7cH, 77H, 1eH, 15H, 08H, 03H, 32H, 39H, 24H, 2fH
db 8dH, 86H, 9bH, 90H, 0a1H, 0aaH, 0b7H, 0bcH, 0d5H, 0deH, 0c3H, 0c8H, 0f9H, 0f2H, 0efH, 0e4H
db 3dH, 36H, 2bH, 20H, 11H, 1aH, 07H, 0cH, 65H, 6eH, 73H, 78H, 49H, 42H, 5fH, 54H
db 0f7H, 0fcH, 0e1H, 0eaH, 0dbH, 0d0H, 0cdH, 0c6H, 0afH, 0a4H, 0b9H, 0b2H, 83H, 88H, 95H, 9eH
db 47H, 4cH, 51H, 5aH, 6bH, 60H, 7dH, 76H, 1fH, 14H, 09H, 02H, 33H, 38H, 25H, 2eH
db 8cH, 87H, 9aH, 91H, 0a0H, 0abH, 0b6H, 0bdH, 0d4H, 0dfH, 0c2H, 0c9H, 0f8H, 0f3H, 0eeH, 0e5H
db 3cH, 37H, 2aH, 21H, 10H, 1bH, 06H, 0dH, 64H, 6fH, 72H, 79H, 48H, 43H, 5eH, 55H
db 01H, 0aH, 17H, 1cH, 2dH, 26H, 3bH, 30H, 59H, 52H, 4fH, 44H, 75H, 7eH, 63H, 68H
db 0b1H, 0baH, 0a7H, 0acH, 9dH, 96H, 8bH, 80H, 0e9H, 0e2H, 0ffH, 0f4H, 0c5H, 0ceH, 0d3H, 0d8H
db 7aH, 71H, 6cH, 67H, 56H, 5dH, 40H, 4bH, 22H, 29H, 34H, 3fH, 0eH, 05H, 18H, 13H
db 0caH, 0c1H, 0dcH, 0d7H, 0e6H, 0edH, 0f0H, 0fbH, 92H, 99H, 84H, 8fH, 0beH, 0b5H, 0a8H, 0a3H
;-------------------------------------------

;-------------------------------------------
; Galois Field Multiplication by 13
gf13 db 00H, 0dH, 1aH, 17H, 34H, 39H, 2eH, 23H, 68H, 65H, 72H, 7fH, 5cH, 51H, 46H, 4bH
db 0d0H, 0ddH, 0caH, 0c7H, 0e4H, 0e9H, 0feH, 0f3H, 0b8H, 0b5H, 0a2H, 0afH, 8cH, 81H, 96H, 9bH
db 0bbH, 0b6H, 0a1H, 0acH, 8fH, 82H, 95H, 98H, 0d3H, 0deH, 0c9H, 0c4H, 0e7H, 0eaH, 0fdH, 0f0H
db 6bH, 66H, 71H, 7cH, 5fH, 52H, 45H, 48H, 03H, 0eH, 19H, 14H, 37H, 3aH, 2dH, 20H
db 6dH, 60H, 77H, 7aH, 59H, 54H, 43H, 4eH, 05H, 08H, 1fH, 12H, 31H, 3cH, 2bH, 26H
db 0bdH, 0b0H, 0a7H, 0aaH, 89H, 84H, 93H, 9eH, 0d5H, 0d8H, 0cfH, 0c2H, 0e1H, 0ecH, 0fbH, 0f6H
db 0d6H, 0dbH, 0ccH, 0c1H, 0e2H, 0efH, 0f8H, 0f5H, 0beH, 0b3H, 0a4H, 0a9H, 8aH, 87H, 90H, 9dH
db 06H, 0bH, 1cH, 11H, 32H, 3fH, 28H, 25H, 6eH, 63H, 74H, 79H, 5aH, 57H, 40H, 4dH
db 0daH, 0d7H, 0c0H, 0cdH, 0eeH, 0e3H, 0f4H, 0f9H, 0b2H, 0bfH, 0a8H, 0a5H, 86H, 8bH, 9cH, 91H
db 0aH, 07H, 10H, 1dH, 3eH, 33H, 24H, 29H, 62H, 6fH, 78H, 75H, 56H, 5bH, 4cH, 41H
db 61H, 6cH, 7bH, 76H, 55H, 58H, 4fH, 42H, 09H, 04H, 13H, 1eH, 3dH, 30H, 27H, 2aH
db 0b1H, 0bcH, 0abH, 0a6H, 85H, 88H, 9fH, 92H, 0d9H, 0d4H, 0c3H, 0ceH, 0edH, 0e0H, 0f7H, 0faH
db 0b7H, 0baH, 0adH, 0a0H, 83H, 8eH, 99H, 94H, 0dfH, 0d2H, 0c5H, 0c8H, 0ebH, 0e6H, 0f1H, 0fcH
db 67H, 6aH, 7dH, 70H, 53H, 5eH, 49H, 44H, 0fH, 02H, 15H, 18H, 3bH, 36H, 21H, 2cH
db 0cH, 01H, 16H, 1bH, 38H, 35H, 22H, 2fH, 64H, 69H, 7eH, 73H, 50H, 5dH, 4aH, 47H
db 0dcH, 0d1H, 0c6H, 0cbH, 0e8H, 0e5H, 0f2H, 0ffH, 0b4H, 0b9H, 0aeH, 0a3H, 80H, 8dH, 9aH, 97H
;-------------------------------------------

;-------------------------------------------
; Galois Field Multiplication by 14
gf14 db 00H, 0eH, 1cH, 12H, 38H, 36H, 24H, 2aH, 70H, 7eH, 6cH, 62H, 48H, 46H, 54H, 5aH
db 0e0H, 0eeH, 0fcH, 0f2H, 0d8H, 0d6H, 0c4H, 0caH, 90H, 9eH, 8cH, 82H, 0a8H, 0a6H, 0b4H, 0baH
db 0dbH, 0d5H, 0c7H, 0c9H, 0e3H, 0edH, 0ffH, 0f1H, 0abH, 0a5H, 0b7H, 0b9H, 93H, 9dH, 8fH, 81H
db 3bH, 35H, 27H, 29H, 03H, 0dH, 1fH, 11H, 4bH, 45H, 57H, 59H, 73H, 7dH, 6fH, 61H
db 0adH, 0a3H, 0b1H, 0bfH, 95H, 9bH, 89H, 87H, 0ddH, 0d3H, 0c1H, 0cfH, 0e5H, 0ebH, 0f9H, 0f7H
db 4dH, 43H, 51H, 5fH, 75H, 7bH, 69H, 67H, 3dH, 33H, 21H, 2fH, 05H, 0bH, 19H, 17H
db 76H, 78H, 6aH, 64H, 4eH, 40H, 52H, 5cH, 06H, 08H, 1aH, 14H, 3eH, 30H, 22H, 2cH
db 96H, 98H, 8aH, 84H, 0aeH, 0a0H, 0b2H, 0bcH, 0e6H, 0e8H, 0faH, 0f4H, 0deH, 0d0H, 0c2H, 0ccH
db 41H, 4fH, 5dH, 53H, 79H, 77H, 65H, 6bH, 31H, 3fH, 2dH, 23H, 09H, 07H, 15H, 1bH
db 0a1H, 0afH, 0bdH, 0b3H, 99H, 97H, 85H, 8bH, 0d1H, 0dfH, 0cdH, 0c3H, 0e9H, 0e7H, 0f5H, 0fbH
db 9aH, 94H, 86H, 88H, 0a2H, 0acH, 0beH, 0b0H, 0eaH, 0e4H, 0f6H, 0f8H, 0d2H, 0dcH, 0ceH, 0c0H
db 7aH, 74H, 66H, 68H, 42H, 4cH, 5eH, 50H, 0aH, 04H, 16H, 18H, 32H, 3cH, 2eH, 20H
db 0ecH, 0e2H, 0f0H, 0feH, 0d4H, 0daH, 0c8H, 0c6H, 9cH, 92H, 80H, 8eH, 0a4H, 0aaH, 0b8H, 0b6H
db 0cH, 02H, 10H, 1eH, 34H, 3aH, 28H, 26H, 7cH, 72H, 60H, 6eH, 44H, 4aH, 58H, 56H
db 37H, 39H, 2bH, 25H, 0fH, 01H, 13H, 1dH, 47H, 49H, 5bH, 55H, 7fH, 71H, 63H, 6dH
db 0d7H, 0d9H, 0cbH, 0c5H, 0efH, 0e1H, 0f3H, 0fdH, 0a7H, 0a9H, 0bbH, 0b5H, 9fH, 91H, 83H, 8dH
;-------------------------------------------

;-------------------------------------------
; Round constant
rcon db 8dH, 01H, 02H, 04H, 08H, 10H, 20H, 40H, 80H, 1bH, 36H, 6cH, 0d8H, 0abH, 4dH, 9aH
;-------------------------------------------

.code
asmEncrypt proc
	movdqu	xmm0, [rcx]		; Move state to xmm0
	movdqu	xmm1, [rdx]		; Move first key to xmm1
	pxor	xmm0, xmm1		; Perform XOR on state with the round key (AddRoundKey)

	push rcx				; Push address of the state array on the stack

	xor rcx, rcx
	inc rcx 
	inc rcx					; Initialize LoopHead counter (9 rounds)

LoopHead:
	SubBytes xmm0, sbox
	ShiftRows xmm0
	MixColumns xmm0
	movdqu xmm1, [rdx + rcx * 8] ; Move round key to xmm1
	pxor   xmm0, xmm1		; Perform XOR on state with the round key (AddRoundKey)

	inc rcx
	inc rcx
	cmp rcx, 18
	jle	LoopHead

	pop rcx					; Retrieve address of the state array from the stack

	; Final Round
	SubBytes xmm0, sbox
	ShiftRows xmm0
	movdqu xmm1, [rdx + 160] ; Move last expanded key to xmm1
	pxor xmm0, xmm1			 ; Perform XOR on state with the round key (AddRoundKey)

	movdqu	[rcx], xmm0		; Move cipherkey to memory

	ret
asmEncrypt endp

asmDecrypt proc
	movdqu xmm0, [rcx]			; Move state to xmm0
	movdqu xmm1, [rdx + 160]	; Move last key to xmm1
	pxor	xmm0, xmm1			; Perform XOR on state with the round key (AddRoundKey)

	push rcx					; Push address of the state array on the stack
	mov rcx, 18					; Initialize DecryptLoopHead counter (9 rounds, multiplied by two because of addressing the key)

DecryptLoopHead:
	InvShiftRows xmm0
	SubBytes xmm0, invSbox
	movdqu		xmm1, [rdx + rcx * 8]	; Move round key to xmm1
	pxor		xmm0, xmm1	; Perform XOR on state with the round key (AddRoundKey)
	InvMixColumns xmm0

	dec rcx
	dec rcx
	jnz DecryptLoopHead

	pop rcx						; Retrieve address of the state array from the stack

	InvShiftRows xmm0
	SubBytes xmm0, invSbox
	movdqu xmm1, [rdx]			; Move first key to xmm1
	pxor	xmm0, xmm1			; Perform XOR on state with the round key (AddRoundKey)

	movdqu [rcx], xmm0			; Move plaintext to memory

	ret
asmDecrypt endp

asmKeyExpansion proc
	movdqu xmm0, [rcx]		; Move original key to xmm0
	movdqu [rdx], xmm0		; Copy original key to beginning of expandedKeys array
	add rdx, 16				; Move to next key in expandedKeys
	
	push rbx
	push rcx
	mov rcx, 10				; Initialize KeyExpLoop counter for number of generated round keys
	mov r8, 1				; rcon Iteration
	
KeyExpLoop:
	pextrd eax, xmm0, 3		; Extract last column from previous key
	ror eax, 8				; RotWord

	push rcx				; Preserve KeyExpLoop counter
	mov rcx, 2				; Initialize SubBytesLoop counter
SubBytesLoop:
	xor ebx, ebx
	mov bl, al				; move first byte of word into bl
	lea rsi, [sbox]			; get address of the sbox array
	mov al, [ rsi + rbx ]	; substitute first byte of word
	xor ebx, ebx
	mov bl, ah				; move second byte of word into bl
	mov ah, [ rsi + rbx ]	; substitute second byte of word
	ror eax, 16				; shift state to the right by two bytes
	dec rcx
	jnz	SubBytesLoop
	
	; RCon
	xor ebx, ebx
	mov bl, al				; move first byte of word into bl
	lea rsi, [rcon]			; get address of the sbox array
	xor al, [ rsi + r8 ]	; substitute first byte of word
	inc r8					; increment Rcon iteration

	mov rcx, 4				; Initialize ColumnsXor counter
	pxor xmm1, xmm1			; Clear xmm1 register

ColumnsXor:
	pextrd ebx, xmm0, 0		; Extract first column from previous key
	xor eax, ebx			; Perform xor operation between columns from current and previous key
	pinsrd xmm1, eax, 0		; Insert newly generated column into xmm1
	pshufd xmm0, xmm0, 57	; Shift previous key columns right
	pshufd xmm1, xmm1, 57	; Shift current key columns right
	dec rcx
	jnz ColumnsXor

	pop rcx					; Retrieve KeyExpLoop counter from stack

	movdqu xmm0, xmm1		; Copy newly generated key into previous key register
	movdqu [rdx], xmm0		; Move newly generated key to expandedKeys array
	add rdx, 16				; Move to next key address in expandedKeys array

	dec rcx
	jnz KeyExpLoop

	pop rcx					; Retrieve original array address from the stack
	pop rbx

	ret
asmKeyExpansion endp
end