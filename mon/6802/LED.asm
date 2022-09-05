    CPU     6800
    
; PIA already defined in uart.asm

LED_RED     EQU     $04
LED_GREEN   EQU     $08
LED_BLUE    EQU     $02

LED_init:
    ldaa    PIA_PORTB
    anda    #(~(LED_RED | LED_GREEN | LED_BLUE)) & 255
    staa    PIA_PORTB
    ldaa    PIA_DDRB
    oraa    #(LED_RED | LED_GREEN | LED_BLUE) & 255
    staa    PIA_DDRB
    rts

LED_RedOn:
    psha
    ldaa    PIA_PORTB
    oraa    #LED_RED
    staa    PIA_PORTB
    pula
    rts

LED_RedOff:
    psha
    ldaa    PIA_PORTB
    anda    #(~LED_RED) & 255
    staa     PIA_PORTB
    pula
    rts
    
LED_RedToggle:
    psha
    ldaa    PIA_PORTB
    eora    #LED_RED
    staa    PIA_PORTB
    pula
    rts
    
