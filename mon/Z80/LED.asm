    CPU     Z80
    
; PIA already defined in uart.asm

LED_RED     EQU     $04
LED_GREEN   EQU     $08
LED_BLUE    EQU     $02

LED_init:
    in      a,PIA_PORTB
    and     (~(LED_RED | LED_GREEN | LED_BLUE)) & 255
    out     PIA_PORTB,a
    in      a,PIA_DDRB
    or      (LED_RED | LED_GREEN | LED_BLUE) & 255
    out     PIA_DDRB,a
    ret

LED_RedOn:
    ex      af,af'
    in      a,PIA_PORTB
    or      LED_RED
    out     PIA_PORTB,a
    ex      af,af'
    ret

LED_RedOff:
    ex      af,af'
    in      a,PIA_PORTB
    and     (~LED_RED) & 255
    out     PIA_PORTB,a
    ex      af,af'
    ret
    
LED_RedToggle:
    ex      af,af'
    in      a,PIA_PORTB
    xor     LED_RED
    out     PIA_PORTB,a
    ex      af,af'
    ret
    
