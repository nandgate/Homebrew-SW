    CPU     6800
    
; PIA already defined in uart.asm

LED_RED     EQU     $04
LED_GREEN   EQU     $08
LED_BLUE    EQU     $02

ledon   macro   name,bitName,{GLOBALSYMBOLS}
LED_name_On:
    psha
    ldaa    PIA_PORTB
    oraa    #bitName
    staa    PIA_PORTB
    pula
    rts
    endm
    
ledoff   macro   name,bitName,{GLOBALSYMBOLS}
LED_name_Off:
    psha
    ldaa    PIA_PORTB
    anda    #(~bitName) & 255
    staa     PIA_PORTB
    pula
    rts
    endm

ledtoggle   macro   name,bitName,{GLOBALSYMBOLS}
LED_name_Toggle:
    psha
    ldaa    PIA_PORTB
    eora    #bitName
    staa    PIA_PORTB
    pula
    rts
    endm

LED_init:
    ldaa    PIA_PORTB
    anda    #(~(LED_RED | LED_GREEN | LED_BLUE)) & 255
    staa    PIA_PORTB
    ldaa    PIA_DDRB
    oraa    #(LED_RED | LED_GREEN | LED_BLUE) & 255
    staa    PIA_DDRB
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