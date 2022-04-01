; Ubuntu mainline kernel version 5.4.8, NASM

global	main
extern	printf
extern	scanf
extern	fflush
extern	srand
extern	rand
extern	time

section .data
	; str
	sft	db "%u", 0
	
	prolog 	db "Guess the number between 0 and 100", 0xa, 0
	greater	db "The number is greater than %u", 0xa, 0
	less	db "The number is less than %u", 0xa, 0

	remain	db "%u guesses remaining: ", 0
	
	winner	db "You win! The number was %u", 0xa, 0
	loser	db "You lose! The number was %u", 0xa, 0

	; int
	nguess	db 5,0,0,0			; little endian hack (5 guesses)

section	.bss
	; int
	guess	resb 4
	answer	resb 4

section .text
main:
	sub	rsp, 8

	xor	rax, rax
	xor	rdi, rdi
	call	time
	mov	rdi, rax
	call	srand
	call	rand				; generate random number

	xor	rdx, rdx
	mov	rcx, 100
	div	rcx
	mov	[answer], rdx

	xor	rax, rax
	mov	rdi, prolog
	call	printf WRT ..plt		; Initial print call
	
	xor	edi, edi
	call	fflush				; flush output

check:
	push	rbp
	call	ncheck
	pop	rbp
	
	cmp	rax, 0
	je	WIN
	
	mov	rbx, [nguess]
	dec	rbx
	cmp	rbx, 0
	jle	LOSE				; Out of guesses, loser

	mov	[nguess], rbx

	cmp	rax, 0
	jne	check

	add	rsp, 8
	ret


; returns -1 if >, 0 if =, 1 if <, rax
ncheck:	
	xor	rax, rax
	mov	rdi, remain
	mov	DWORD rsi, [nguess]
	call	printf WRT ..plt

	xor	rax, rax
	mov	rdi, sft			; int buffer
	mov	rsi, guess
	call	scanf

	mov	rax, [guess]
	cmp	eax, [answer]			; compare the guess (lower 4 bits) to the correct number
	
						; setup print call
	mov	rax, 0				; xor rax, rax will set 0 flag and render the cmp useless
	mov	rsi, [guess]

	jl	_LT
	jg	_GT
	
	xor	rax, rax			; if the user guesses correctly they reach this point
	ret

; Called by ncheck

_LT:	
	mov	rdi, greater
	call	printf WRT ..plt
	mov	rax, -1
	ret

_GT:
	mov	rdi, less
	call	printf WRT ..plt
	mov	rax, 1
	ret


; Called by main

WIN:
	xor	rax, rax
	mov	rdi, winner
	mov	DWORD rsi, [answer]
	call	printf WRT ..plt
	ret

LOSE:
	xor	rax, rax
	mov	rdi, loser
	mov	DWORD rsi, [answer]
	call	printf WRT ..plt
	ret
