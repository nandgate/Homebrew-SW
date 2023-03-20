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
    sta     strPtrL             ; save it later
    jsr     getHexDigit         ; Get second hex digit
    bcs     $$getHexByteExit    ; bail on error
    ora     strPtrL             ; combine with low nibble to form the byte value
    clc                         ; clear carry for success
$$getHexByteExit
    rts

getHexDigit
    jsr     GetChar
parseHexDigit:
    ; Process hex digit in accA [0..9][A..F][a..f]
    ora     #$20            ; Force to lower
    ldx     #$0F
$$ParseLoop:
    cmp     HexChars,x         ; Is it this digit?
    beq     $$GotHex        ; Yes, process the nibble value
    dex                     ; No, advance pointer
    bpl     $$ParseLoop     ; Keep checking until index underflows
    sec                     ; Index underflowed, not a hex digit, indicate failue
    rts
$$GotHex:
    txa                     ; Put the parsed value in accA
    clc                     ; Clear carry to indicate success
    rts
    
    ; Output the value in accA to the console as two hex bytes
putHex8:
    pha                         ; save value
    lsr                         ; move high nibble to low
    lsr
    lsr
    lsr
    tax
    lda     HexChars,x          ; lookup hex char for nibble
    jsr     PutChar             ; output hex char for nibble
    pla
    and     #$0f                ; mask high nibble away
    tax
    lda     HexChars,x
    jmp     PutChar             ; output hex char for nibble

; print strPtrH,strPtrL as a hex value
putHex16:
    lda     strPtrH             ; save low value for later
    jsr     putHex8             ; print the high byte
    lda     strPtrL             ; get the low value back
    jmp     putHex8             ; print the low byte

HexChars:
    FCB     "0123456789abcdef"

    ENDIF