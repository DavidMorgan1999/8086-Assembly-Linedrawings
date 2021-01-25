; Second stage of the boot loader

BITS 16

ORG 9000h
	jmp 	Second_Stage

%include "functions_16.asm"

;	Start of the second stage of the boot loader

Second_Stage:
    mov 	si, second_stage_msg	; Output our greeting message
    call 	Console_WriteLine_16
	
	call SetVideoMode
	mov 	cx, 10 	;x0
	mov 	dx, 10 ;y0
	mov		si, 30	;x1
	mov 	di, 30 	;y1
	mov		byte [colour], 1
	call Drawline ;1
	mov 	cx, 10 	;x0
	mov 	dx, 30 ;y0
	mov		si, 30	;x1
	mov 	di, 10 	;y1
	mov		byte [colour], 2
	call Drawline ;2
	mov 	cx, 100 	;x0
	mov 	dx, 100 ;y0
	mov		si, 150	;x1
	mov 	di, 170 	;y1
	mov		byte [colour], 3
	call Drawline ;3
	mov 	cx, 100	;x0
	mov 	dx, 170 ;y0
	mov		si, 150	;x1
	mov 	di, 100 	;y1
	mov		byte [colour], 4
	call Drawline ;4
	mov 	cx, 200	;x0
	mov 	dx, 200 ;y0
	mov		si, 250	;x1
	mov 	di, 300	;y1
	mov		byte [colour], 5
	call Drawline ;5
	mov 	cx, 15	;x0
	mov 	dx, 20 ;y0
	mov		si, 150	;x1
	mov 	di, 300	;y1
	mov		byte [colour], 6
	call Drawline ;6
	mov 	cx, 26	;x0
	mov 	dx, 150 ;y0
	mov		si, 110 ;x1
	mov 	di, 105	;y1
	mov		byte [colour], 7
	call Drawline ;7
	mov 	cx, 150	;x0
	mov 	dx, 140 ;y0
	mov		si, 270 ;x1
	mov 	di, 80	;y1
	mov		byte [colour], 8
	call Drawline ;8
	mov 	cx, 150	;x0
	mov 	dx, 80 ;y0
	mov		si, 270 ;x1
	mov 	di, 140	;y1
	mov		byte [colour], 9
	call Drawline ;9
	mov 	cx, 200	;x0
	mov 	dx, 10 ;y0
	mov		si, 250 ;x1
	mov 	di, 50	;y1
	mov		byte [colour], 10
	call Drawline ;10
	jmp endloop

SetVideoMode:
	mov ah, 00h ;sets config
	mov al, 13h ;Changes video mode 
	int 10h ;System Interupt
	ret

PlotPixel:
	mov ah, 0Ch  ;sets config to drawing pixel
	mov bh, 00h ; Sets page number as 0
	mov al, [colour]
	int 10h
	ret

Drawline:
	mov ax, si 	;difx = x1 - x0
	sub ax, cx
	mov [difx], ax
	
	;make difx abs here

	mov ax, di	;dify = y1 - y0
	sub ax, dx
	mov [dify], ax

	;make dify abs ere

	mov ax, [dify]
	sar ax, 1			;e1 = absdify>>1 (x)
	mov [e1], ax

	mov ax, [difx]
	sar ax, 1			;e2 = absdifx>>1 (y)
	mov [e2], ax
	
IF01: 
	mov ax, [difx] 	;if difx > 0
 	cmp ax, 0  
 	jle ELSEIF01
	mov ax, 1
	mov [sx], ax		;then sx = 1
	jmp ENDIF01
ELSEIF01:
	mov ax, [difx]	;elseif difx < 0
	cmp ax, 0
	jge ELSE01
	mov ax, -1  ;then sx = -1
	mov [sx], ax
	jmp ENDIF01
ELSE01: 
	mov ax, 0  ;else sx = 0 as dx = 0
	mov [sx], ax
ENDIF01: 
	nop
	

IF02:
	mov ax, [dify]	;if dify > 0
	cmp ax, 0
	jle ELSEIF02
	mov ax, 1	
	mov [sy], ax	;then sy = 1
	jmp ENDIF02
ELSEIF02:
	mov ax, [dify]	;if dify < 0
	cmp ax, 0
	jge ELSEIF02
	mov ax, -1		;then sy = -1
	mov [sy], ax
	jmp ENDIF02
ELSE02:
	mov ax, 0
	mov [sy], ax		;else sy = 0 as dify = 0
ENDIF02:
	nop	
	
IF03:
	mov ax, [difx]
	cmp ax, dify		;if(absdifx >= absdify)
	jl ELSE03
	mov dword [forcount], 0
FOR01: 
	mov ax, [forcount]
	cmp ax, [difx]	;for(forcount = 0; forcount < absdifx; forcount++)
	jge ENDFOR01
	mov ax, [dify]		;e2 += absdify
	add [e2], ax
IF04:
	mov ax, [e2]
	cmp ax, difx		;if(e2 >= absdifx)
	jl ENDIF04
	mov ax, [difx]
	sub [e2], ax		;e2 -= absdifx
	mov ax, [sy]
	add dx, ax			;y0 += sy
ENDIF04:
	mov ax, [sx]
	add cx, ax			;x0 += sx
	call PlotPixel
	add dword [forcount], 1
	jmp FOR01
ENDFOR01:
	jmp ENDIF03
ELSE03:
	
FOR02: 
	mov ax, [forcount]	;for(forcount = 0; forcount < absdify; forcount++)
	cmp ax, dify
	jge ENDFOR02
	mov ax, [difx]
	add [e1], ax 		;e1 += absdifx
IF05:	
	mov ax, [e1]
	cmp ax, dify		;if(e1 >= absdify)
	jl ENDIF05
	mov ax, [dify] 
	sub [e1], ax 		;e1 -= absdify
	mov ax, [sx]
	add cx, ax			;x0 += sx
ENDIF05:
	mov ax, [sy]
	add dx, ax			;y0 += sy
	call PlotPixel
	add dword [forcount], 1
	jmp FOR02
ENDFOR02: nop
ENDIF03:
	ret


	; Put your test code here

	; This never-ending loop ends the code.  It replaces the hlt instruction
	; used in earlier examples since that causes some odd behaviour in 
	; graphical programs.
endloop:
	jmp		endloop


second_stage_msg	db 'Second stage loaded', 0
colour				db 0
difx				dw 0
dify				dw 0
absdifx				dw 0
absdify				dw 0
sx					dw 0
sy 					dw 0
e1 					dw 0
e2 					dw 0
forcount			dw 0
	times 3584-($-$$) db 0	