    DOSSEG
    .MODEL SMALL
    .STACK 32
    .DATA


encoded     DB  80 DUP(0)
temp        DB  '0x', 160 DUP(0)
fileHandler DW  ?
filename    DB  'in/in.txt', 0          ; Trebuie sa existe acest fisier 'in/in.txt'!
outfile     DB  'out/out.txt', 0        ; Trebuie sa existe acest director 'out'!
message     DB  80 DUP(0)

msglenini   DW  ?
msglen      DW  ?
padding     DW  0
iterations  DW  0 
x           DW  ?
x0          DW  ?
a           DW  0
b           DW  0
nume        DB  'Ioana', 0h
prenume     DB  'Dragos', 0h  
xp          DW  ?
bitesNumber DW  ?
paddingAdded  DW 0 
cod64       DB  'Bqmgp86CPe9DfNz7R1wjHIMZKGcYXiFtSU2ovJOhW4ly5EkrqsnAxubTV03a=L/d', 0h
    .CODE
START:
    MOV     AX, @DATA
    MOV     DS, AX

    CALL    FILE_INPUT                  ; NU MODIFICATI!
    
    CALL    SEED                        ; TODO - Trebuie implementata
    
    CALL    ENCRYPT                     ; TODO - Trebuie implementata

    CALL    ENCODE                      ; TODO - Trebuie implementata
    MOV AX, msglenini
    MOV msglen, AX
                                        ; Mai jos se regaseste partea de
                                        ; afisare pe baza valorilor care se
                                        ; afla in variabilele x0, a, b, respectiv
                                        ; in sirurile message si encoded.
                                        ; NU MODIFICATI!
    MOV     AH, 3CH                     ; BIOS Int - Open file
    MOV     CX, 0
    MOV     AL, 1                       ; AL - Access mode ( Write - 1 )
    MOV     DX, OFFSET outfile          ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    CALL    WRITE                       ; NU MODIFICATI!

    MOV     AH, 4CH                     ; Bios Int - Terminate with return code
    MOV     AL, 0                       ; AL - Return code
    INT     21H
FILE_INPUT:
    MOV     AH, 3DH                     ; BIOS Int - Open file
    MOV     AL, 0                       ; AL - Access mode ( Read - 0 )
    MOV     DX, OFFSET fileName         ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    MOV     AH, 3FH                     ; BIOD Int - Read from file or device
    MOV     BX, [fileHandler]           ; BX - File handler
    MOV     CX, 80                      ; CX - Number of bytes to read
    MOV     DX, OFFSET message          ; DX - Data buffer
    INT     21H
    MOV     [msglen], AX                ; Return: AX - number of read bytes

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H

    RET


     ; TODO1: Completati subrutina SEED
                                        ; astfel incat la final sa fie salvat
                                        ; in variabila 'x' si 'x0' continutul 
                                        ; termenului initial
SEED:
    ;MOV   AH, 2CH                     ; BIOS Int - Get System Time
    ;INT   21H

    MOV AH, 0 
    MOV AL, 60   
    MUL CH  ; 60*CH 
    
    MOV BH, 0
    MOV BL, CL
    ADD AX, BX    ; 60*CH+CL 

    MOV BH, 0
    MOV BL, 60 
    PUSH DX
    MUL BX      ; 60(60*CH+CL) 
    POP DX
    MOV BH, 0
    MOV BL, DH
    ADD AX, BX ; 60*(60*CH+CL)+DH 

    MOV BX, 100

    PUSH DX     ; incarcam pe stiva DX-ul dat de ceas
    MUL BX     ; (60*(60*CH+CL)+DH)*100 
    MOV BX, DX
    
    
    POP DX
    PUSH BX     ; bagam pe stiva BX (contine rezultatul inmultirii initial pastrat in DX)
    MOV BH, 0
    MOV BL, DL
    ADD AX, BX ; (60*(60*CH+CL)+DH)*100+DL 
    

    MOV BX, 255
    MOV DX, 0
    POP DX
    DIV BX
    MOV AX, DX
    MOV x0, AX
    MOV x0, 13
    MOV x, 13
                                       
    MOV BX, 0
    MOV SI,  OFFSET prenume
PRENUME_SUM:
    MOV DL, [SI]
    MOV DH, 0

    ADD BX, DX
    INC SI

    MOV DL, 0h
    CMP BYTE PTR [SI], DL
    JNE PRENUME_SUM
    MOV AX, BX
    MOV CX, 255
    MOV DX,0
    DIV CX
    MOV a, DX
    MOV a, 104

    MOV BX, 0
    MOV SI, OFFSET nume
NUME_SUM:
    MOV DL, [SI]
    MOV DH, 0
    ADD BX,  DX
    INC SI

    MOV DL, 0h
    CMP BYTE PTR [SI], DL
    JNE NUME_SUM
    

    MOV AX, BX
    MOV CX, 255
    MOV DX,0
    DIV CX
    MOV b, DX
    MOV b, 200

    RET

                                            ; TODO3: Completati subrutina ENCRYPT
                                            ; astfel incat in cadrul buclei sa fie
                                            ; XOR-at elementul curent din sirul de
                                            ; intrare cu termenul corespunzator din
                                            ; sirul generat, iar mai apoi sa fie generat
                                            ; si termenul urmator

ENCRYPT:
    MOV     CX, [msglen]
    MOV     SI, OFFSET message
    MOV     AX, x0
    MOV     x, AX

TRAVERSAL:
    MOV BX, x
    XOR [SI], BX

    MOV AX, x
    MOV DX, a
    MUL DX
    ADD AX, b

    MOV BX, 255
    DIV BX

    MOV x, DX   ; construit urmatorul x

    CMP CX, 2
    JNE PASS
    MOV BX, x
    MOV xp, BX
PASS:
    INC SI
    LOOP TRAVERSAL

    RET
RAND:
    MOV     AX, [x]
                                            ; TODO2: Completati subrutina RAND, astfel incat
                                            ; in cadrul acesteia va fi calculat termenul
                                            ; de rang n pe baza coeficientilor a, b si a 
                                            ; termenului de rang inferior (n-1) si salvat
                                            ; in cadrul variabilei 'x'

    RET



                                            ; TODO4: Completati subrutina ENCODE, astfel incat
                                            ; in cadrul acesteia va fi realizata codificarea
                                            ; sirului criptat pe baza alfabetului COD64 mentionat
                                            ; in enuntul problemei si rezultatul va fi stocat
                                            ; in cadrul variabilei encoded


ENCODE:
    MOV BX, msglen
    MOV msglenini, BX
    MOV AX, msglen
    MOV BX, 3
    MOV DX, 0
    DIV BX

    CMP DX, 0 
    JE  ZERO_ENCODING

    CMP DX, 1
    JE ONE_ENCODING

    CMP DX, 2
    JE TWO_ENCODING



ONE_ENCODING:
    MOV BX, msglen
    ADD BX, 2
    MOV msglen, BX
    MOV paddingAdded, 2
    JMP ZERO_ENCODING
TWO_ENCODING:  
    MOV BX, msglen 
    ADD BX, 1
    MOV msglen, BX
    MOV paddingAdded, 1
ZERO_ENCODING: 
    
    MOV BX, 3
    MOV AX, msglen
    XOR DX, DX
    DIV BX
    MOV CX, AX ; numarul de iteratii, pentru Scut va fi astfel 2(Si, Si+1, Si+2 de 2 ori, prelucrand astfel cate 3 octeti per iteratie)
    MOV SI, offset message
    MOV DI, offset encoded

ASSIGN:
    MOV AL, BYTE PTR [SI]
    SHR AL, 2 ; avem primul set

    MOV BH, BYTE PTR [SI]
    AND BH, 3 ; am preluat ultimii 2 biti din primul octet (construim al doilea set)
    MOV BL, BYTE PTR [SI+1]
    SHL BH, 4 ; am deplasat cei 2 biti la stanga cu 4 pozitii
    AND BL, 240 ; pastrez primii 4 biti (golesc pe ceilalti)
    SHR BL, 4 
    OR BH, BL  

    MOV AH, BYTE PTR [SI+1]
    AND AH, 15 ; AND cu F ca sa raman cu cei mai nes. 4 biti. mai trebuiesc uniti primii 2 biti din al 3 lea oct.
    SHL AH, 2
    MOV BL, BYTE PTR [SI+2]
    AND BL, 192 ; pastrez cei mai semn. 2 biti din octetul 3
    SHR BL, 6
    OR AH, BL ; avem a 3 a secventa

    PUSH CX
    MOV CH, BYTE PTR [SI+2]
    AND CH, 63 ; pastrez primii 6 biti din din octetul 2
    MOV BL, CH
    POP CX

    ; AL - primul set, BH - al doilea set, AH - al treilea set, BL - al patrulea set


    MOV BYTE PTR [DI],   AL    ; am plasat intr-un sir valorile seturilor actuale
    MOV BYTE PTR [DI+1], BH
    MOV BYTE PTR [DI+2], AH
    MOV BYTE PTR [DI+3], BL 

CONTINUE:
    ADD DI, 4
    ADD SI, 3
    LOOP ASSIGN


    
    MOV SI, OFFSET encoded

    MOV BX, 8
    MOV AX, msglenini
    MUL BX
    MOV BX, 6
    DIV BX

    ;PUSH AX
    ;MOV BX, 3 
    ;DIV BX

    ;CMP DX, 2
    ;JNE NO_ASIGNARE_2
    ;POP AX
    ;ADD AX, 1
    ;MOV CX, AX
    ;JMP START_ENCODING
    ;NO_ASIGNARE_2:

    ;CMP DX, 1
    ;JNE NO_ASIGNARE_1
    ;POP AX
    ;ADD AX, 2
    ;MOV CX, BX
    ;JMP START_ENCODING
    ;NO_ASIGNARE_1:

 
    MOV CX, AX
START_ENCODING:
    MOV AH, BYTE PTR [SI]
    MOV BH, 0
    MOV DI, OFFSET cod64
LOOP_COD64:
    CMP AH, BH
    JNE PASS_ASSIGN
    MOV AH, BYTE PTR [DI]
    MOV BYTE PTR [SI], AH
    JMP CONTINUE_ENCODING
    PASS_ASSIGN:
    INC DI
    INC BH
    JMP LOOP_COD64
CONTINUE_ENCODING:
    INC SI
    LOOP START_ENCODING

    MOV CX, paddingAdded
    CMP CX, 0
    JE PASS_PADDING


ADD_PADDING:
    MOV BYTE PTR [SI], 2Bh
    INC SI
    LOOP ADD_PADDING

PASS_PADDING:
    MOV AX, xp
    MOV x, AX 
    RET
   
WRITE_HEX:
    MOV     DI, OFFSET temp + 2
    XOR     DX, DX
DUMP:
    MOV     DL, [SI]
    PUSH    CX
    MOV     CL, 4

    ROR     DX, CL
    
    CMP     DL, 0ah
    JB      print_digit1

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     next_digit

print_digit1:  
    OR      DL, 30h
    MOV     byte ptr [DI] ,DL
next_digit:
    INC     DI
    MOV     CL, 12
    SHR     DX, CL
    CMP     DL, 0ah
    JB      print_digit2

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     AGAIN

print_digit2:    
    OR      DL, 30h
    MOV     byte ptr [DI], DL
AGAIN:
    INC     DI
    INC     SI
    POP     CX
    LOOP    dump
    
    MOV     byte ptr [DI], 10
    RET
WRITE:
    MOV     SI, OFFSET x0
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21h

    MOV     SI, OFFSET a
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET b
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET x
    MOV     CX, 1
    CALL    WRITE_HEX    
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET message
    MOV     CX, [msglen]
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, [msglen]
    ADD     CX, [msglen]
    ADD     CX, 3
    INT     21h

    MOV     AX, [iterations]
    MOV     BX, 4
    MUL     BX
    MOV     CX, AX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET encoded
    INT     21H

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H
    RET
    END START