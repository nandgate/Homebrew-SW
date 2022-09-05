    CPU     6502
    
; PIA already defined in uart.asm

LED_RED     EQU     $04
LED_GREEN   EQU     $08
LED_BLUE    EQU     $02

LED_init:
    lda     PIA_PORTB
    and     #(~(LED_RED | LED_GREEN | LED_BLUE)) & 255
    sta     PIA_PORTB
    lda     PIA_DDRB
    ora     #(LED_RED | LED_GREEN | LED_BLUE) & 255
    sta     PIA_DDRB
    rts

LED_RedOn:
    pha
    lda     PIA_PORTB
    ora     #LED_RED
    sta     PIA_PORTB
    pla
    rts

LED_RedOff:
    pha
    lda     PIA_PORTB
    and     #(~LED_RED) & 255
    sta     PIA_PORTB
    pla
    rts
    
LED_RedToggle:
    pha
    lda     PIA_PORTB
    eor     #LED_RED
    sta     PIA_PORTB
    pla
    rts
    
