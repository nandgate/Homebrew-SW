    CPU     Z80
    
; PIA already defined in uart.asm

LED_RED     EQU     $04
LED_GREEN   EQU     $08
LED_BLUE    EQU     $02

ledon   macro   name,bitName,{GLOBALSYMBOLS}
LED_name_On:
    ex      af,af'
    in      a,PIA_PORTB
    or      LED_RED
    out     PIA_PORTB,a
    ex      af,af'
    ret
    endm
    
ledoff   macro   name,bitName,{GLOBALSYMBOLS}
LED_name_Off:
    ex      af,af'
    in      a,PIA_PORTB
    and     (~LED_RED) & 255
    out     PIA_PORTB,a
    ex      af,af'
    ret
    endm

ledtoggle   macro   name,bitName,{GLOBALSYMBOLS}
LED_name_Toggle:
    ex      af,af'
    in      a,PIA_PORTB
    xor     LED_RED
    out     PIA_PORTB,a
    ex      af,af'
    ret
    endm

LED_init:
    in      a,PIA_PORTB
    and     (~(LED_RED | LED_GREEN | LED_BLUE)) & 255
    out     PIA_PORTB,a
    in      a,PIA_DDRB
    or      (LED_RED | LED_GREEN | LED_BLUE) & 255
    out     PIA_DDRB,a
    ret

    ledon       Red,LED_RED
    ledoff      Red,LED_RED
    ledtoggle   Red,LED_RED
    
    ledon       Green,LED_GREEN
    ledoff      Green,LED_GREEN
    ledtoggle   Green,LED_GREEN

    ledon       Blue,LED_BLUE
    ledoff      Blue,LED_BLUE
    ledtoggle   Blue,LED_BLUE

    
    
