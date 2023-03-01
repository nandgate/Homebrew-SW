    IFNDEF  _HEXIO_
_HEXIO_     SET     1

    include "uart.asm"

getHexByte:
    jsr     getHexDigit         ; get the first hex digit
    bcs     $$getHexByteExit    ; bail on error
    asl     a                   ; move digit to high nibble
    asl     a
    asl     a
    asl     a
    psh     a                   ; save it later
    jsr     getHexDigit         ; Get second hex digit
    bcs     $$getHexByteExit    ; bail on error
    pul     b                   ; get high nibble
    aba                         ; combine with low nibble to form the byte value
    clc                         ; clear carry for success
$$getHexByteExit
    rts

getHexDigit
    jsr     GetChar
parseHexDigit:
    ; Process hex digit in accA [0..9][A..F][a..f]
    oraa    #$20            ; Force to lower
    ldab    #$0F
    ldx     #(HexChars+15); initialize point to valid hex chars
$$ParseLoop:
    cmpa    0,x             ; Is it this digit?
    beq     $$GotHex        ; Yes, process the nibble value
    dex                     ; No, advance pointer
    decb
    bpl     $$ParseLoop     ; Keep checking until index underflows
    sec                     ; Index underflowed, not a hex digit, indicate failue
    rts
$$GotHex:
    tba                     ; Put the parsed value in accA
    clc                     ; Clear carry to indicate success
    rts
    
    ; Output the value in accA to the console as two hex bytes
putHex8:
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

; print accB,accA as a hex value
putHex16:
    psh     a                   ; save low value for later
    tba
    jsr     putHex8             ; print the high byte
    pul     a                   ; get the low value back
    bra     putHex8             ; print the low byte

HexChars:
    FCB     "0123456789abcdef"

    ENDIF