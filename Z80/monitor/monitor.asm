    CPU     Z80
    include "vec.asm"

    ORG     $0080
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

; HL is addrH, addrL
; DE is userH, userL

reset:
    im      1               ; Use a known vector for interrups
    ld      sp,$FFFF
    call    FT240_init
    call    LED_init

InitMon:
    ld      hl,$0000
    ld      de,$0000
    
InfoCmd:
    ld      bc,InfoStr
$$loop:
    ld      a,(bc)
    cp      $00
    jp      z,Prompt
    call    PutChar
    inc     bc
    jp      $$loop

    halt

Prompt:
    call    LED_RED_Off
    ld      a,$0a           ; Show Prompt
    call    PutChar
    ld      a,h             ; Show high address
    call    PutHex
    ld      a,l             ; Show low address
    call    PutHex
    ld      a,' '             ; Space to seperate address and data
    call    PutChar
    ld      a,(hl)
    call    PutHex
    ld      a,'>'            ; Show Prompt
    call    PutChar
 NextChar:   
    call    GetChar         ; get char from user
    jp      nc,NextChar     ; Got a char? Keep polling until we get a char
    call    LED_RED_On
    ld      b,a
    call    PutChar         ; Should we echo the character?????
    ld      a,b
    cp      '?'             ; Show info?
    jp      z,InfoCmd
    cp      '='             ; re-read address?
    jp      z,Prompt
    cp      $0a             ; Write data byte?
    jp      nz,NotWrite
    ld      (hl),e          ; Store the last 8-bit value entered at the current address    
    jp      DoInc           ; Increment the current address

NotWrite:
    cp     '+'              ; Incement address?
    jp      nz,NotInc
DoInc:
    inc     hl
    jp      Prompt

NotInc:
    cp      '-'             ; Decrement address?
    jp      nz,NotDec
    dec     hl
    jp      Prompt

NotDec:
    cp      'g'            ; go to address?
    jp      nz,NotGo
    ld      bc,reset
    push    bc
    jp      (hl)

NotGo:
    cp      ' '            ; set current address?
    jp      NZ,NotAddr
    ld      h,d
    ld      l,e
    ld      de,$0000
    jp      Prompt         ; Continue with the new address 

NotAddr:
ParseHex:
    ; Process hex digit [0..9][A..F][a..f]    
    push    hl              ; Save HL and BC 
    push    bc
    or      $20             ; Force to lower
    ld      hl,HexChars     ; Lookup hex digit in table
    ld      bc,16
    cpir
    jp      z,GotHex        ; Jump when a hex digit was found
    pop     bc              ; Not a hex digit, restor HL and BC
    pop     hl
    jp      Prompt          ; Ignore chractervand show prompt

GotHex:
    sla     e               ; Shift the user value to the left by 4 bits
    rl      d
    sla     e
    rl      d
    sla     e
    rl      d
    sla     e
    rl      d
    ld      a,c             ; determin what digit we got
    cpl
    and     $0f      
    or      e               ; Or it into the user value
    ld      e,a
    pop     bc              ; Restore HL and BC
    pop     hl
    nop
    jp      NextChar
    
; Output the value in acc to the console as two hex bytes
 PutHex:
    ld      b,a                 ; save value for later
    srl     a                   ; move high nibble to low
    srl     a
    srl     a
    srl     a
    push    hl                  ; save for later
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
    pop     hl                  ; restore old value
    ret

HexChars:
    db     "0123456789abcdef"
    
InfoStr:
    db     10,"MiniMon,0.1,Z80,0",10,0

    