.386

;MODELO
.model flat, stdcall
option casemap:none

include ReadFile.inc
include \masm32\include\masm32rt.inc



;SEGMENTO DE DATOS
.data

	msj4 db "Aún no existe un KeyLog",0
	msj3 db "Fecha en que fue escrito: ",0
    msj2 db "No se han encontrado coincidencias",0
	msj1 db "Buscar Palabra: ",0
	Archivo byte "C:\ProyectoMicro\keylog.txt",NULL

;SEGMENTO DE DATOS (?)
.data?

	FileSize dd ?
	HandleMed dd ?
	BytesRead dd ?
	palabra db 100 dup(?)
	temporal dd ?
	temporal2 dd ?
	handlee dd ?

;SEGMENTO DE CODIGO
.code
PROGRAMA:
	call principal

	principal proc
		
        invoke StdOut, addr msj1
		invoke StdIn,addr palabra,100

		mov edx, offset Archivo
		INVOKE CreateFile, edx, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_HIDDEN,NULL
		mov handlee, eax

		;Marca error si el archivo no existe
		cmp eax, INVALID_HANDLE_VALUE 
		je finalPROGRAMA

		invoke GetFileSize,eax,0
		mov FileSize, eax
		inc eax

		invoke GlobalAlloc,GMEM_FIXED,eax
		mov HandleMed, eax

		add eax, FileSize
		mov BYTE PTR [eax],0
                               

		invoke ReadFile,handlee,HandleMed,FileSize,ADDR BytesRead,0
		invoke CloseHandle,handlee

		;SE LLAMA AL METODO QUE COMPARA LAS CADENAS
		call VerificarCadena

		;invoke StdOut,HandleMed
		invoke GlobalFree,HandleMed

		
		;ERRORHANDLE:
		;invoke StdOut, addr msj4

		finalPROGRAMA:
		invoke ExitProcess,0
		ret
	principal endp

	ArchivoLectura PROC
		.data
		ReadFromFile_1 DWORD ?
		.code
		INVOKE ReadFile,
		eax, 
		edx, 
		ecx,
		ADDR ReadFromFile_1, 
		0
		mov eax,ReadFromFile_1
		ret
	ArchivoLectura ENDP

	
	VerificarCadena proc
		;SE LIMPIAN LOS REGISTRO QUE SE VAN A UTILIZAR
	    XOR EBX, EBX
		XOR EDI, EDI
		XOR EAX, EAX
		XOR ESI, ESI

		MOV EDI, HandleMed
		LEA ESI, palabra

		MOVZX EAX, BYTE PTR [EDI]
		MOV temporal2, EAX
		MOVZX EBX, BYTE PTR [ESI]
		MOV temporal, EBX
		CMP EBX, temporal2
		JE EQUALS
		JNE NEXT
		
		;SI SON IGUALES
		EQUALS:
		XOR EBX, EBX
		INC ESI
		
		MOVZX EBX, BYTE PTR [ESI]
		MOV temporal, EBX

		MOV EBX, temporal
		CMP EBX, 0
		JE FechaHora
		XOR EAX, EAX
		
		INC EDI

		MOVZX EAX, BYTE PTR [EDI]
		MOV temporal2, EAX

		XOR EAX, EAX
		MOV EAX, temporal2
		CMP temporal, EAX
		JE EQUALS
		JNE RESTART

		NEXT:
		INC EDI
		MOVZX EAX, BYTE PTR [EDI]
		CMP EAX, 0
		JE BUFEND

		CMP EAX, temporal
		JE EQUALS
		JNE NEXT

		RESTART:
		XOR ESI, ESI
		LEA ESI, palabra
		MOVZX EBX, BYTE PTR [ESI]
		MOV temporal, EBX
		JMP NEXT

		ENDSTRING:
		INC EDI

		MOVZX EAX, BYTE PTR [EDI]
		CMP EAX, 13
		JE FechaHora
		JNE ENDSTRING

		BUFEND:
		invoke StdOut, addr msj2
		JMP final

		FechaHora:
		invoke StdOut, addr msj3
		INC EDI
		JMP final

		final:
		ret
	VerificarCadena endp

end PROGRAMA