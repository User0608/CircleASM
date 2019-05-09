DATA SEGMENT
	X1 DW 320 ;coordenada x centro
	Y1 DW 240 ;coordenada x centro
	R1 DW 50;Radio ...

	X2 DW 420;coordenada y centro	
	Y2 DW 240 ;coordenada y centro	
	R2 DW 50;Radio ...


	LASTKEY DW "5" 
	TEMPO DW ?
	HOR DW ?
	VER DW ?
	MODO DB ?
	COLOR DB ? ;Color ...

DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE,DS:DATA, SS:PILA
INICIO:
	MOV AX,DATA
	MOV DS,AX

	;Petición de modo de video 
	MOV AH,0Fh	
	INT 10h		
	MOV MODO,AL 

	;http://ict.udlap.mx/people/oleg/docencia/Assembler/asm_interrup_10.html
	;establece el modo de video 
	MOV AH,00h	
	MOV AL,12h	
	INT 10h	

	MOV CX,X1
	MOV DX,Y1
	MOV COLOR,0AH
	CALL PUNTEAR
		


	;Espera una tecla
	MOV AH,0 
  	INT 16H

	;Restablece el modo
	MOV AH,00h	
	MOV AL,MODO
	INT 10h	

	;Terminación de Programa con Código de Retorno
	MOV AX,4C00h	
	INT 21h

	PUNTEAR PROC NEAR	
		MOV AH,0Ch		; Petición para escribir un punto
		MOV AL,COLOR	; Color del pixel
		MOV BH,00h		; Página
		INT 10H			; Llamada al BIOS
	RET
	PUNTEAR ENDP


CODE ENDS

PILA SEGMENT STACK
       DB 900 DUP(?)
PILA ENDS

END INICIO    
