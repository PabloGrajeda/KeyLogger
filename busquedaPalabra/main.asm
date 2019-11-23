.386
.model flat, stdcall
option casemap:none

include \masm32\include\masm32rt.inc
include ReadFile.inc

.data
	Archivo byte "C:\ProyectoMicro\keylog.txt",NULL
	msj1 db "Buscar: ",0
	msj2 db "no se econtro  la palabra",0
	msj3 db "Se encontro coincidencia ",0
.data?
	palabra db 100 dup(?)	
	temporal dd ?				
	temporal2 dd ?				
	hanldee dd ?		
	FileSize dd ?			
	fileBuffer dd ?			
	BytesRead dd ?			
	counter dd ?			
.code
program:
	call PRINCIPAL

	PRINCIPAL proc

		;INICIA LA BUSQUEDA
		invoke StdOut, addr msj1		
		invoke StdIn,addr palabra,100	

		mov edx, offset Archivo
		INVOKE CreateFile, edx, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_HIDDEN,NULL
		mov hanldee, eax
		cmp eax, INVALID_HANDLE_VALUE	
		je ENDPROGRAM

		invoke GetFileSize,eax,0
		mov FileSize, eax
		inc eax							

		invoke GlobalAlloc,GMEM_FIXED,eax
		mov fileBuffer, eax

		add eax, FileSize
		mov BYTE PTR [eax],0		
									

		invoke ReadFile,hanldee,fileBuffer,FileSize,ADDR BytesRead,0
		invoke CloseHandle,hanldee

		call EVALUARSTRING			

		invoke GlobalFree,fileBuffer

		mov eax, 10
		push eax
		print esp					
		pop eax


		ENDPROGRAM:
		invoke ExitProcess,0
		ret
	PRINCIPAL endp

	EVALUARSTRING proc
	    XOR ESI, ESI
		XOR EDI, EDI
		XOR EBX, EBX
		XOR EAX, EAX
		
		MOV EDI, fileBuffer			
		LEA ESI, palabra			

		MOVZX EAX, BYTE PTR [EDI]	
		MOV temporal2, EAX				
		MOVZX EBX, BYTE PTR [ESI]	
		MOV temporal, EBX				
		CMP EBX, temporal2				
		JE EAQUALS
		JNE NEXT

		EAQUALS:
		XOR EBX, EBX
		INC ESI						
		
		MOVZX EBX, BYTE PTR [ESI]	
		MOV temporal, EBX				

		CMP EBX, 0					
								
		JE VerifyPalabraCompleta	
		JNE SigueBuscando	

		VerifyPalabraCompleta:
		INC EDI						
		MOVZX EAX, BYTE PTR [EDI]	
		CMP EAX, 20h				
		JE HORAFECHA
		CMP EAX, 13d			
		JE HORAFECHA			
		JNE REBOOT				

		SigueBuscando:
		XOR EAX, EAX
		
		INC EDI
		MOVZX EAX, BYTE PTR [EDI]	
		MOV temporal2, EAX				

		CMP temporal, EAX				
		JE EAQUALS
		JNE REBOOT

		NEXT:
		INC EDI
		MOVZX EAX, BYTE PTR [EDI]	
		CMP EAX, 0					
		JE BUFEND

		CMP EAX, temporal				
		JE EAQUALS
		JNE NEXT

		REBOOT:
		XOR ESI, ESI
		LEA ESI, palabra			
		MOVZX EBX, BYTE PTR [ESI]	
		MOV temporal, EBX				
		JMP NEXT

		ENDSTRING:
		INC EDI						

		MOVZX EAX, BYTE PTR [EDI]	
		CMP EAX, 13
		JE HORAFECHA
		JNE ENDSTRING

		BUFEND:
		invoke StdOut, addr msj2	
		JMP ENDPROCESS

		HORAFECHA:
		invoke StdOut, addr msj3
		INC EDI
		INC EDI
		INC EDI
		INC EDI
		INC EDI
		INC EDI
		INC EDI
		INC EDI
		INC EDI
		INC EDI
		INC EDI
		INC EDI
		INC EDI
		INC EDI
		MOVZX EAX, BYTE PTR [EDI]	
		CMP EAX, 0					
		JE FECHAS

		MOV ECX, 19d
		MOV counter, ECX
		
		NEXTDATE:
			INC EDI		
			MOVZX EAX, BYTE PTR [EDI]	
			push eax
			print esp				
			pop eax
		DEC counter	

		jz FINLOOP
		jmp NEXTDATE

		FINLOOP:
		MOV EAX, 10d
		push eax
		print esp					
		pop eax
		jmp REBOOT				

		FECHAS:
		
		ENDPROCESS:
		MOV EAX, 10d
		push eax
		print esp					
		pop eax
		ret
	EVALUARSTRING endp
end program
