
    IFNDEF  _HEXIO_
_HEXIO_     SET     1

    include "uart.asm"

getHexByte:
    call    getHexDigit         ; get the first hex digit
    ret     c                   ; bail on error
    ld      d,a                 ; Save the first digit to high nibble    
    sla     d
    sla     d
    sla     d
    sla     d
    call    getHexDigit         ; Get second hex digit
    ret     c                   ; bail on error
    or      d                   ; combine with the fist digit to form the byte value
    and     a,$ff               ; clear carty ofr success
    ret
    
getHexDigit:
    call    GetChar             ; Get a character
parseHexDigit:
    or      $20                 ; Force to lower
    ld      hl,HexChars         ; Lookup hex digit in table
    ld      bc,16
    cpir
    jp      nz,notHex           ; Jump when a hex digit was found
    ld      a,c
    xor     a,$0F               ; clear carry to indicate success reading a hex byte
    ret    
notHex:
    scf                         ; set carry to indicate failure 
    ret
    
; print A as a hex value
; uses b, hl
putHex8:
    ld      b,a                 ; save value for later
    srl     a                   ; move high nibble to low
    srl     a
    srl     a
    srl     a
    ld      hl,HexChars         ; lookup hex digit              
    add     a,l                 ; (only works when table does not pass page boundary)
    ld      l,a
    ld      a,(hl)              
    call    PutChar             ; Send out high digit
    ld      a,b                 ; get value back
    and     $0f                 ; mask high nibble away
    ld      hl,HexChars         ; lookup hex digit              
    add     a,l                 ; (only works when table does not pass page boundary)
    ld      l,a
    ld      a,(hl)              
    call    PutChar             ; Send out low digit
    ret
    
; print HL as a hex value
; uses a, b, hl
putHex16:
    push    hl                  ; save value for later
    ld      a,h                 ; print the h byte
    call    putHex8
    pop     hl                  ; get the value back
    ld      a,l                 ; print the l byte
    jp      putHex8

HexChars:
    db     "0123456789abcdef"

    ENDIF