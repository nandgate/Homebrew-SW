    CPU     6502
    
count   equ 0

    ORG     $1000
    include "LED.asm"
    include "uart.asm"

strPtrL     EQU     $04
strPtrH     EQU     $05

hi  function x,(x>>8)&255
lo  function x,x&255

main:
    jsr     FT240_init
    jsr     LED_init
    lda     #$F0
    sta     count
loop:
    jsr     LED_GREEN_TOGGLE
    lda     #lo(HelloMsg)
    sta     strPtrL
    lda     #hi(HelloMsg)
    lda     strPtrH
    jsr     putStr
    inc     count
    bne     loop
    rts
    
HelloMsg:
     FCB     "Hello chat!",10,0
     