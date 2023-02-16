section .data
    strOpen : db "Insira o N-esimo termo de fibonacci que deseja descobrir (entre 0 e 99): ", 0
    strOpenL : equ $ - strOpen

    strErro : db "Entrada Invalida. Programa encerrado.", 10, 0
    strErroL : equ $ - strErro

    strFile : db "fib(00).bin", 0
    strFileL : equ $ - strFile

section .bss
    numLido : resb 3
    numLidoL : resb 1
    num : resq 1
    file: resd 1
    resultado: resq 1

section .text
    global _start

_start:
    mov rax, 1 ; write
    mov rdi, 1 ; no terminal
    lea rsi, [strOpen]
    mov edx, strOpenL
    syscall

leitura:
    mov rax, 0  ; READ
    mov rdi, 1  ; do terminal
    lea rsi, [numLido]
    mov edx, 3 ; 3 = tamanho máximo
    syscall

    mov [numLidoL], eax

verificacaoDeEntrada:
    cmp byte [numLidoL], 1 ; se apenas 1 caractere foi lido, ele é o enter e a entrada é inválida
    je erro

    cmp byte [numLido + eax-1], 10 ; [strLida + eax-1] aponta para ultimo lido
    je conversao ; se ultimo for enter
    ; senao

limpaBuffer:
    mov rax, 0  ; READ
    mov rdi, 1
    lea rsi, [numLido]
    mov edx, 1
    syscall
    
    cmp byte [numLido], 10 ; fica lendo a entrada até ela ser um \n (enter)
    jne limpaBuffer

erro:
    ;   msg de erro e encerra.
    mov rax, 1
    mov rdi, 1
    mov rsi, strErro
    mov rdx, strErroL
    syscall
    jmp fim 

conversao:
    xor r12, r12
    xor r13, r13

    mov r12b, [numLido] ; move o primeiro byte pra r12
    sub r12b, "0" ; subtrai 30 para obter o valor real
    mov byte [num], r12b ; armazena na memoria

    cmp byte [numLido+1], 10 ; se o segundo byte for \n, segue para fib
    je fibPrep
    ; se nao
    imul r12, 10 ; multiplica o digito já calculado por 10
    mov r13b, [numLido+1] ; move o segundo byte lido pra r13
    sub r13b, "0" ; subtrai 30 para obter o valor real

    add r12b, r13b ; acrescenta na dezena a unidade
    mov byte [num], r12b ; armazena o valor correto na memoria

fibPrep:
    xor r12,  r12
    xor r13,  r13
    xor r14,  r14

    cmp byte [num], 93 ; verifica se o valor é maior que 93
    jg erro
    
    mov r14, [num] ; verifica se o valor é menor ou igual a 1, se sim pula o calculo
    cmp r14, 1
    mov qword[resultado], r14
    jle geraNome

    mov r13, 1 ; base para o calculo do fibonacci
    mov r15, [num] ; prepara r15 para ser o indice do loop

fib:
    ; calcula o fib, sendo r14 o f(x), r13 f(x-1) e r12 f(x-2)
    mov r14, r13
    add r14, r12
    
    mov r12, r13
    mov r13, r14
    
    dec r15
    cmp r15, 1 ; repete até r15 ser 1
    jne fib
    
    mov qword[resultado], r14 ; armazena f(x) em resultado

geraNome:
    xor r13, r13
    xor r14, r14
    xor r15, r15
    mov r13, [numLido] ; move todo o numero lido para r13
    mov r15, [strFile+6] ; move ').bin' para r15

    mov [strFile+4], r13 ; coloca o numero lido logo a frente de 'fib('
    
    mov r14, strFile ; move o endereco do nome do arquivo para r14
    add r14b, [numLidoL] ; acrescenta o tamanho do numero lido + \n
    add r14, 3 ; acrescenta 3 (referente ao espaço do 'fib(' e compensar o \n do numLidoL)
    mov [r14], r15 ; reescreve no endereço certo o finalizador do nome

abreFile:
    mov rax, 2 ; abre arquivo
    lea rdi, [strFile] ; nome do arquivo
    mov esi, 2102o ; 2000(append) + 100(create) + 2(read/write)
    mov edx, 644o ; 6[ 4(read) + 2(write) owner] 4(read group) 4(read others)
    syscall

    mov [file], eax ; armazena file descriptor em file

escreveFile:
    xor rdi, rdi
    mov rax, 1 ; write
    mov rdi, [file]; no arquivo
    lea rsi, [resultado]
    mov edx, 8 ; 8 bytes
    syscall

fechaFile:
    mov rax, 3 ; fecha
    mov edi, [file]
    syscall

fim:
    mov rax, 60
    mov rdi, 0
    syscall