    CPU     65C02
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
addrL       EQU     $00
addrH       EQU     $01
userL       EQU     $02
userH       EQU     $03

reset:
    cld                     ; Make sure we are NOT is decimal mode
    ldx     #$FF
    txs
    jsr     FT240_init
    jsr     LED_init

InitMon:
    stz     addrL           ; Clear monitor state
    stz     addrH
    stz     userL
    stz     userH
    
InfoCmd:
    ldx     #$00
$$loop
    lda     InfoStr,x
    beq     Prompt     
    jsr     PutChar
    inx
    bra     $$loop

Prompt:
    jsr     LED_RED_Off
    lda     #$0a            ; Show Prompt
    jsr     PutChar
    lda     addrH           ; Show high address
    jsr     PutHex
    lda     addrL           ; Show low address
    jsr     PutHex
    lda     #' '            ; Space to seperate address and data
    jsr     PutChar
    ldy     #$00
    lda     (addrL),y       ; Show data at address
    jsr     PutHex
    lda     #'>'            ; Show Prompt
    jsr     PutChar
 NextChar:   
    jsr     GetChar         ; get char from user
    bcc     NextChar        ; Got a char? Keep polling until we get a char
    jsr     LED_RED_On
    tax
    jsr     PutChar         ; Should we echo the character?????
    txa
    cmp     #'?'            ; Show info?
    beq     InfoCmd
    cmp     #'='            ; re-read address?
    beq     Prompt
    cmp     #$0a            ; Write data byte?
    bne     NotWrite
    lda     userL           ; Get the last 8-bit value entered
    ldy     #$00
    sta     (addrL),y       ; Store at the current address
    bra     DoInc           ; Increment the current address

NotWrite:
    cmp     #'+'            ; Incement address?
    bne     NotInc
DoInc:
    inc     addrL           ; TODO test this logic: 03FF -> 0400 -> 0401; FFFF -> 0000
    bne     Prompt
    inc     addrH
    bra     Prompt

NotInc:
    cmp     #'-'            ; Decrement address?
    bne     NotDec
    lda     addrL
    bne     $$NoMSB
    dec     addrH
$$NoMSB:
    dec     addrL
    bra     Prompt

NotDec:
    cmp     #'g'            ; go to address?
    bne     NotGo
    lda     #(reset-1)>>8   ; push the return address onto the stack
    pha
    lda     #(reset-1)&$FF
    pha
    jmp     (addrL)

NotGo:
    cmp     #' '            ; set current address?
    bne     NotAddr
    lda     userL           ; move the user value to the current address
    sta     addrL
    lda     userH
    sta     addrH
    lda     #$00            ; clear user value
    sta     userL
    sta     userH
    bra     Prompt          ; Continue with the new address 

NotAddr:
ParseHex:
    ; Process hex digit [0..9][A..F][a..f]
    ora     #$20            ; Force to lower
    ldx     #$0F            ; initialize index
ParseLoop:
    cmp     HexChars,x      ; Is it this digit?
    beq     GotHex          ; Yes, process the nibble value
    dex                     ; No, advance index
    bpl     ParseLoop       ; Keep checking until index underflows
    jmp     Prompt          ; Index underflowed, not a hex digit- abort
GotHex:
    asl     userL           ; Shift the user value to the left by 4 bits
    rol     userH
    asl     userL
    rol     userH
    asl     userL
    rol     userH
    asl     userL
    rol     userH
    txa                     ; Get the nibble value
    ora     userL           ; Insert the nibble into the user value
    sta     userL
    jmp     NextChar        ; Done, get next char    
    
; Output the value in acc to the console as two hex bytes
PutHex:
    tay                         ; save value
    lsr                         ; move high nibble to low
    lsr
    lsr
    lsr
    tax
    lda     HexChars,X          ; lookup hex digit 
    jsr     PutChar
    tya                         ; get value back
    and     #$0f                ; mask high nibble away
    tax
    lda     HexChars,X          ; lookup hex digit 
    jmp     PutChar

HexChars:
    FCB     "0123456789abcdef"
    
InfoStr:
    FCB     10,"MiniMon,0.1,65C02,0",10,0
   
nmi:
    bra     nmi

irqBrk:
    bra     irqBrk

    