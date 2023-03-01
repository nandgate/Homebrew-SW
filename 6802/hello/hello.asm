    CPU     6800
    
count   equ 0

    ORG     $1000
    include "LED.asm"
    include "uart.asm"

main:
    jsr    FT240_init
    jsr    LED_init
    clra
    staa    count
loop:
    jsr     LED_GREEN_TOGGLE
    ldx     #HelloMsg
    jsr     putStr
    inc     count
    bne     loop
    rts
    
HelloMsg:
     db     "Hello chat!",10,0