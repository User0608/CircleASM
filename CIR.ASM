DATA SEGMENT
	X1 DW 340 ;coordenada x centro
	Y1 DW 240 ;coordenada x centro
	COLOR1 DB ? ;Color ...

	X2 DW 300;coordenada y centro	
	Y2 DW 240 ;coordenada y centro	
	COLOR2 DB ? ;Color ...
	

	RADIO DW 100;Radio ...
	X DW ?
	Y DW ?
	XC DW ?
	YC DW ?
	MODE DB ?
	COLOR DB ? ;Color ...
	LASTKEY DW "5" 
	TEMPO DW ?
	COL DB ? ;Color ...

DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE,DS:DATA, SS:PILA
INICIO:
	MOV AX,DATA
	MOV DS,AX

	;Petición de modo de video 
	MOV AH,0Fh	
	INT 10h		
	MOV MODE,AL 

	;http://ict.udlap.mx/people/oleg/docencia/Assembler/asm_interrup_10.html
	;establece el modo de video 640x480
	MOV AH,00h	
	MOV AL,12h	
	INT 10h	


	MOV RADIO,60	
	MOV COLOR1,0AH
	MOV COLOR2,0EH
	CALL DRAWING	


	;Espera una tecla
	MOV AH,0 
  	INT 16H

	;Restablece el modo
	MOV AH,00h	
	MOV AL,MODE
	INT 10h	

	;Terminación de Programa con Código de Retorno
	MOV AX,4C00h	
	INT 21h

	;pinta las figuras en la pantalla
	DRAWING PROC NEAR
	MOV AX,RADIO
	MOV TEMPO,AX
	CYCLE:	
		MOV X,0
		MOV AX,TEMPO
		MOV Y,AX
	CALC:
		CALL CALCULATE
		MOV AX,Y
		SUB AX,X
		CMP AX,1
		JA CALC
		CALL CALCULATE				
	DEC TEMPO
	CMP TEMPO,1
	JAE CYCLE
	RET
	DRAWING ENDP
	;Calcula los puntos a pintar
	CALCULATE PROC NEAR
		MOV AX,X
		MUL AX 			;X^2
		MOV BX,AX
		MOV AX,Y
		MUL AX 			;Y^2
		ADD BX,AX       ;X^2+Y^2
		MOV AX,RADIO 
		MUL AX 			;R^2

		CMP BX,AX
		JBE BLOCK
		DEC Y
		BLOCK:
		CALL PERXY
		CALL PERXY	

		INC X 
	RET
	CALCULATE ENDP

	PERXY PROC NEAR
		MOV CX,X1
		MOV XC,CX
		MOV CX,Y1
		MOV YC,CX
		MOV CL,COLOR1
		MOV COLOR,CL
		CALL PAINT

		MOV CX,X2
		MOV XC,CX
		MOV CX,Y2
		MOV YC,CX
		MOV CL,COLOR2
		MOV COLOR,CL
		CALL PAINT

		PUSH Y
		PUSH X
		POP Y
		POP X

	PERXY ENDP
	;Interpola los puntos y pinta en pantalla
	PAINT PROC NEAR	
		;I CUADRANTE
		MOV CX,XC
		ADD CX,X
		MOV DX,YC
		ADD DX,Y			
		CALL POINTER	
		;II CUADRANTE	
		MOV CX,XC
		SUB CX,X
		MOV DX,YC
		ADD DX,Y		
		CALL POINTER
		;III CUADRANTE
		MOV CX,XC
		SUB CX,X
		MOV DX,YC
		SUB DX,Y		
		CALL POINTER
		;IV CUADRANTE
		MOV CX,XC
		ADD CX,X
		MOV DX,YC
		SUB DX,Y		
		CALL POINTER
	RET
	PAINT ENDP
	;pinta un punto en pantalla (cx,dx)
	POINTER PROC NEAR	

		MOV AH,0DH
		MOV BH,00h
		INT 10H
		CMP AL,00H
		JNE CODEP		

		MOV AH,0Ch		; Petición para escribir un punto
		MOV AL,COLOR	; Color del pixel
		MOV BH,00h		; Página
		INT 10H			; Llamada al BIOS
		JMP QUITX
		CODEP:
		MOV AH,0Ch		; Petición para escribir un punto
		MOV AL,09H 	; Color del pixel
		MOV BH,00h		; Página
		INT 10H			; Llamada al BIOS
		QUITX:

	RET
	POINTER ENDP

CODE ENDS

PILA SEGMENT STACK
       DB 900 DUP(?)
PILA ENDS

END INICIO    
