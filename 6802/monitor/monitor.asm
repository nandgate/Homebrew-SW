    CPU     6800
    include "vec.asm"

    ORG     $F000
    include "LED.asm"
    include "uart.asm"

; Simple monitor:
; Prompt messsage is:
; 
; aaaa bb>
; 
; Where aaaa is the current addess and bb is the current value at that address.
;
; Commands:
; ?     Show the info message
; =     Re-read the current address
; <lf>  Write to current address and increment address
; +     Increment current address
; -     Decrement current address
; g     Go to current address
; <sp>  Set current address   

; Zero page address
addrH       EQU     $00
addrL       EQU     $01
userH       EQU     $02
userL       EQU     $03
ptrH        EQU     $04
ptrL        EQU     $05

reset:
    lds     #$01FF
    jsr     FT240_init
    jsr     LED_init

InitMon:
    ldaa    #$00            ; Clear monitor state
    staa    addrL           
    staa    addrH
    staa    userL
    staa    userH
    
InfoCmd:
    ldx     #InfoStr
$$loop
    ldaa    0,x             ; get a char from the info string
    beq     Prompt          ; End of string= exit
    jsr     PutChar         ; not end end of string, output char
    inx                     ; Point to next char in string
    bra     $$loop

Prompt:
    jsr     LED_RED_Off
    ldaa    #$0a            ; Show Prompt
    jsr     PutChar
    ldaa    addrH           ; Show high address
    jsr     PutHex
    ldaa    addrL           ; Show low address
    jsr     PutHex
    ldaa    #' '            ; Space to seperate address and data
    jsr     PutChar
    ldx     addrH           ; Show data at address
    ldaa    0,x             
    jsr     PutHex
    ldaa    #'>'            ; Show Prompt
    jsr     PutChar
 NextChar:   
    jsr     GetChar         ; get char from user
    bcc     NextChar        ; Got a char? Keep polling until we get a char
    jsr     LED_RED_On
    tab
    jsr     PutChar         ; Should we echo the character?????
    tba
    cmpa    #'?'            ; Show info?
    beq     InfoCmd
    cmpa    #'='            ; re-read address?
    beq     Prompt
    cmpa    #$0a            ; Write data byte?
    bne     NotWrite
    ldaa    userL           ; Get the last 8-bit value entered
    ldx     addrH
    staa    0,x             ; Store at the current address
    bra     DoInc           ; Increment the current address

NotWrite:
    cmpa    #'+'            ; Incement address?
    bne     NotInc
DoInc:
    ldx     addrH
    inx          
    stx     addrH
    bra     Prompt

NotInc:
    cmpa    #'-'            ; Decrement address?
    bne     NotDec
    ldx     addrH
    dex
    stx     addrH
    bra     Prompt

NotDec:
    cmpa    #'g'            ; go to address?
    bne     NotGo
    lda     #(reset)&$FF    ; push the return address onto the stack
    psha
    lda     #(reset)>>8
    psha
    ldx     addrH
    jmp     0,x

NotGo:
    cmpa    #' '            ; set current address?
    bne     NotAddr
    ldx     userH           ; move the user value to the current address
    stx     addrH
    ldaa    #$00            ; clear user value
    staa    userL
    staa    userH
    bra     Prompt          ; Continue with the new address 

NotAddr:
ParseHex:
    ; Process hex digit in accA [0..9][A..F][a..f]
    oraa    #$20            ; Force to lower
    ldab    #$0F
    ldx     #(HexChars+15); initialize point to valid hex chars
ParseLoop:
    cmpa    0,x             ; Is it this digit?
    beq     GotHex          ; Yes, process the nibble value
    dex                     ; No, advance pointer
    decb
    bpl     ParseLoop       ; Keep checking until index underflows
    jmp     Prompt          ; Index underflowed, not a hex digit- abort
GotHex:
    pshb                    ; save value for later
    ldaa    userL           ; Shift the user value to the left by 4 bits
    ldab    userH
    asla
    rolb
    asla
    rolb
    asla
    rolb
    asla
    rolb
    staa    userL
    stab    userH
    pula                    ; get the value back
    oraa    userL           ; Insert the nibble into the user value
    staa    userL
    bra     NextChar        ; Done, get next char    
    
; Output the value in accA to the console as two hex bytes
PutHex:
    tab                         ; save value
    lsra                        ; move high nibble to low
    lsra
    lsra
    lsra
    ldx     #HexChars           ; lookup hex char for nibble
    stx     ptrH
    adda    ptrL                ; add in offset (assumes indexing within same page)
    staa    ptrL
    ldx     ptrH
    ldaa    0,x
    jsr     PutChar             ; output hex char for nibble
    andb    #$0f                ; mask high nibble away
    ldx     #HexChars           ; lookup hex char for nibble
    stx     ptrH
    addb    ptrL
    stab    ptrL
    ldx     ptrH
    ldaa    0,x
    jmp     PutChar             ; output hex char for nibble

HexChars:
    FCB     "0123456789abcdef"
    
InfoStr:
    FCB     10,"MiniMon,0.1,6802,0",10,0
   
irq:
    bra     irq

swi: 
    bra     swi
    
nmi:
    bra     nmi

