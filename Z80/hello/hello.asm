    CPU     Z80

    ORG     $9000
    include "LED.asm"
    include "uart.asm"

main:
    call    FT240_init
    call    LED_init
loop:
    ld      hl,HelloMsg
    call    LED_GREEN_TOGGLE
    call    putStr
    jp      loop
    
    ; print null terminated string at (HL)
putStr:
    ld      a,(hl)              ; get the character
    and     a,$FF               ; is it $00?
    ret     z                   ; yes, done
    call    PutChar             ; no, send it
    inc     hl                  ; increment pointer
    jp      putStr              ; output next character

HelloMsg:
     db     "Hello world!",10,0