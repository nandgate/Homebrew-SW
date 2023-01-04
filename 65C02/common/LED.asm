    CPU     65C02
    
; PIA already defined in uart.asm

LED_RED     EQU     $04
LED_GREEN   EQU     $08
LED_BLUE    EQU     $02

ledon   macro   name,bitName,{GLOBALSYMBOLS}
LED_name_On:
    pha
    lda     PIA_PORTB
    ora     #bitName
    sta     PIA_PORTB
    pla
    rts
    endm
    
ledoff   macro   name,bitName,{GLOBALSYMBOLS}
LED_name_Off:
    pha
    lda     PIA_PORTB
    and     #(~bitName) & 255
    sta     PIA_PORTB
    pla
    rts
    endm

ledtoggle   macro   name,bitName,{GLOBALSYMBOLS}
LED_name_Toggle:
    pha
    lda     PIA_PORTB
    eor     #bitName
    sta     PIA_PORTB
    pla
    rts
    endm


LED_init:
    lda     PIA_PORTB
    and     #(~(LED_RED | LED_GREEN | LED_BLUE)) & 255
    sta     PIA_PORTB
    lda     PIA_DDRB
    ora     #(LED_RED | LED_GREEN | LED_BLUE) & 255
    sta     PIA_DDRB
    rts

    ledon       Red,LED_RED
    ledoff      Red,LED_RED
    ledtoggle   Red,LED_RED
    
    ledon       Green,LED_GREEN
    ledoff      Green,LED_GREEN
    ledtoggle   Green,LED_GREEN

    ledon       Blue,LED_BLUE
    ledoff      Blue,LED_BLUE
    ledtoggle   Blue,LED_BLUE  
