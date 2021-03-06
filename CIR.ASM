DATA SEGMENT

	UNI DB "UNIVERSIDAD NACIONAL DE TRUJILLO","$"
	ING DB "INGENIERIA DE SISTEMAS","$" 	
	VALLE DB "VALLE JEQUETEPEQUE","$"

	CORX1 DB "X1:","$"
	CORY1 DB "Y1:","$"

	CORX2 DB "X2:","$"
	CORY2 DB "Y2:","$"

	TAMRAD DB "RADIO:","$"

	BUFFER  DB 8			
	        DB 9 dup("$")

	X1 DW 340 
	Y1 DW 240 
	COLOR1 DB 0AH 

	X2 DW 300	
	Y2 DW 240
	COLOR2 DB 0EH

	RADIO DW 25
	X DW ?
	Y DW ?
	XC DW ?
	YC DW ?
	MODE DB ?
	COLOR DB ?
	LASTKEY DB "5" 	
	TEMPO DW ?
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

	CALL RECORRE
	CALL BIENBE	

	MOV DX,0500H
	CALL POSICION
	LEA DX,TAMRAD
	CALL MUESTRA
	CALL INGRESO
	MOV RADIO,DX

	MOV DX,0600H
	CALL POSICION
	LEA DX,CORX1
	CALL MUESTRA
	CALL INGRESO
	MOV X1,DX

	MOV DX,0700H
	CALL POSICION
	LEA DX,CORY1
	CALL MUESTRA
	CALL INGRESO
	MOV Y1,DX

	MOV DX,0610H
	CALL POSICION
	LEA DX,CORX2
	CALL MUESTRA
	CALL INGRESO
	MOV X2,DX

	MOV DX,0710H
	CALL POSICION
	LEA DX,CORY2
	CALL MUESTRA
	CALL INGRESO
	MOV Y2,DX
	
	MOV AH,0 
  	INT 16H

	MOV AH,00h	
	MOV AL,12h	
	INT 10h	
	
  	CALL BUCLE

	MOV AH,0 
  	INT 16H

	MOV AH,00h	
	MOV AL,MODE
	INT 10h	

	MOV AX,4C00h	
	INT 21h

	BIENBE PROC NEAR
	MOV DX,0015H
	CALL POSICION
	LEA DX,UNI
	CALL MUESTRA

	MOV DX,0119H
	CALL POSICION
	LEA DX,ING
	CALL MUESTRA

	MOV DX,021BH
	CALL POSICION
	LEA DX,VALLE
	CALL MUESTRA
	RET
	BIENBE ENDP

	POSICION PROC NEAR
		MOV AH,02H
		MOV BH,00
		INT 10H
	RET
	POSICION ENDP

	MUESTRA PROC NEAR
		MOV AH,09H
		INT 21H
	RET
	MUESTRA ENDP

	INGRESO PROC NEAR ; devuelve un numero den bx		
		MOV AH, 0AH
		LEA DX,BUFFER	
		INT 21H

		MOV DX,0
		MOV CX,0

		MOV DL,BUFFER[2]			
		SUB DL,48		

		MOV CL,BUFFER[3]		
		SUB CL,48
		JL SALIDA
		MOV AX,10 
		MUL DX
		MOV DX,AX
		ADD DX,CX

		MOV CL,BUFFER[4]	
		SUB CL,48
		JL SALIDA
		MOV AX,10 
		MUL DX
		MOV DX,AX
		ADD DX,CX

	SALIDA:
	RET
	INGRESO ENDP

	RECORRE PROC NEAR
		MOV AX,0600h	
		MOV BH,07h	
		MOV CX,0000h	
		MOV DX,184fh	
		INT 10h	
	RET
	RECORRE ENDP

	BUCLE PROC NEAR	
		HEAD:				
				CALL DRAWING
				CALL LISTEN 			
				JNZ E1
				MOV AL,LASTKEY				
			E1:
				CMP AL, "1"
				JNZ E2
				CALL MOV_SO
				JMP HEAD
			E2:	
				CMP AL, "2"
				JNZ E3
				CALL MOV_S	
				JMP HEAD
			E3:	
				CMP AL, "3"
				JNZ E4
				CALL MOV_SE
				JMP HEAD
			E4:	
				CMP AL, "4"
				JNZ E5
				CALL MOV_O
				JMP HEAD
			E5:	
				CMP AL, "5"
				JNZ E6
				CALL DONTMOVE
				JMP HEAD
			E6:
				CMP AL, "6"
				JNZ E7
				CALL MOV_E
				JMP	HEAD
			E7:	
				CMP AL, "7"
				JNZ E8
				CALL MOV_NO	
				JMP HEAD
			E8:	
				CMP AL, "8"
				JNZ E9
				CALL MOV_N	
				JMP HEAD
			E9:	
				CMP AL, "9"
				JNZ E10
				CALL MOV_NE
				JMP HEAD
			E10:
				CMP AL,"+"
				JNZ E11
				CALL INCREASE
				JMP HEAD
			E11:
				CMP AL,"-"
				JNZ CAMBIARC
				CALL DECREASE
				JMP HEAD			
			CAMBIARC:
				CMP AL,"0"
				JNZ QUIT
				CALL CCOLOR
				JMP HEAD			
			QUIT:	
				CMP AL, "q"
				JNZ BUCLE
		RET
	BUCLE ENDP

LISTEN  PROC NEAR
	MOV AH,06h    
 	MOV DL,0FFh   
 	INT 21h        
	RET
LISTEN ENDP	

INCREASE PROC NEAR
	CALL CLEAN
	MOV AX,X1
	ADD AX,RADIO
	SUB AX,640
	JZ DONTINC
	MOV AX,X1
	SUB AX,RADIO
	JZ DONTINC
	MOV AX,Y1
	SUB AX,RADIO
	JZ DONTINC
	MOV AX,Y1
	ADD AX,RADIO
	SUB AX,480
	JZ DONTINC
	INC RADIO
DONTINC:
	RET
INCREASE ENDP

DECREASE PROC NEAR
	CALL CLEAN
	CMP RADIO,10
	JE DONTDEC
	DEC RADIO
DONTDEC:
	RET
DECREASE ENDP	

CCOLOR PROC NEAR
	ADD COLOR1,27
	ADD COLOR2,27
	RET
CCOLOR ENDP

MOV_SO  PROC NEAR 
	MOV AX,X1
	SUB AX,RADIO
	JNZ NO1
	CALL MOV_SE
	RET
NO1:
	MOV AX,Y1
	ADD AX,RADIO
	SUB AX,480
	JNZ	NO2
	CALL MOV_NO
	RET
NO2:
	CALL CLEAN
	INC Y1
	DEC X1
	MOV LASTKEY ,"1"
	RET
MOV_SO ENDP

MOV_S PROC NEAR 
	MOV AX,Y1
	ADD AX,RADIO
	SUB AX,480
	JNZ NO3
	CALL MOV_N
	RET
NO3:
	CALL CLEAN
	INC Y1
	MOV LASTKEY ,"2"
	RET
MOV_S ENDP


MOV_SE PROC NEAR
	MOV AX,Y1
	ADD AX,RADIO
	SUB AX,480
	JNZ NO4
	CALL MOV_NE
	RET
NO4:
	MOV AX,X1
	ADD AX,RADIO
	SUB AX,640
	JNZ NO5
	CALL MOV_SO
	RET
NO5:
	CALL CLEAN
	INC Y1
	INC X1
	MOV LASTKEY ,"3"
	RET
MOV_SE ENDP

MOV_O PROC NEAR
	MOV AX,X1
	SUB AX,RADIO
	JNZ NO6
	CALL MOV_E
	RET
NO6:
	CALL CLEAN
	DEC X1
	MOV LASTKEY ,"4"
	RET
MOV_O ENDP


MOV_E PROC NEAR
	MOV AX,X1
	ADD AX,RADIO
	SUB AX,640
	JNZ NO7
	CALL MOV_O
	RET
NO7:
	CALL CLEAN
	INC X1
	MOV LASTKEY ,"6"
	RET
MOV_E ENDP

MOV_NO PROC NEAR
	MOV AX,X1
	SUB AX,RADIO
	JNZ NO8
	CALL MOV_NE
	RET
NO8:
	MOV AX,Y1
	SUB AX,RADIO
	JNZ NO9
	CALL MOV_SO
	RET
NO9:
	CALL CLEAN
	DEC Y1
	DEC X1
	MOV LASTKEY ,"7"
	RET
MOV_NO ENDP

MOV_N PROC NEAR
	MOV AX,Y1
	SUB AX,RADIO
	JNZ NO10
	CALL MOV_S
	RET
NO10:
	CALL CLEAN
	DEC Y1
	MOV LASTKEY ,"8"
	RET
MOV_N ENDP

MOV_NE PROC NEAR
	MOV AX,X1
	ADD AX,RADIO
	SUB AX,640
	JNZ NO11
	CALL MOV_NO
	RET
NO11:
	MOV AX,Y1
	SUB AX,RADIO
	JNZ NO12
	CALL MOV_SE
	RET
NO12:
	CALL CLEAN
	DEC Y1
	INC X1
	MOV LASTKEY ,"9"
	RET
MOV_NE ENDP

DONTMOVE PROC NEAR
	MOV AH,00h
	INT 16h
	MOV LASTKEY,AL
	RET
DONTMOVE ENDP
	DRAWING PROC NEAR
		MOV AX,RADIO
		MOV X,0
		MOV Y,AX		
	CALC:
		CALL CALCULATE
		MOV AX,Y
		SUB AX,X
		CMP AX,1
		JA CALC
		CALL CALCULATE				
	RET
	DRAWING ENDP
	
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

	POINTER PROC NEAR		
		MOV AH,0Ch
		MOV AL,COLOR	
		MOV BH,00h		
		INT 10H			
	RET
	POINTER ENDP

	CLEAN PROC NEAR		
			MOV CL,COLOR1
			MOV CH,COLOR2
		PUSH CX     
			MOV COLOR1,00h
			MOV COLOR2,00H
			CALL DRAWING
		POP CX
			MOV COLOR1,CL
			MOV COLOR2,CH
	RET
	CLEAN ENDP
CODE ENDS
PILA SEGMENT STACK
       DB 9000 DUP(?)
PILA ENDS
END INICIO    
