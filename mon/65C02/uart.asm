    CPU     65C02

PIA_BASE    EQU     $0200
PIA_PORTB   EQU     PIA_BASE + $0
PIA_PORTA   EQU     PIA_BASE + $1
PIA_DDRB    EQU     PIA_BASE + $2
PIA_DDRA    EQU     PIA_BASE + $3
PIA_ACR     EQU     PIA_BASE + $B
PIA_PCR     EQU     PIA_BASE + $C
    
PIA_IN      EQU     $00
PIA_OUT     EQU     $FF

FT240_WRMSK EQU     $01     ; WR on bit-0
FT240_NOSTB EQU     $0E     ; RD# = 1, irqs disabled 
FT240_RDSTB EQU     $0C     ; RD# = 0, irqs disabled 


; Initialize the VIA to operate iwth the FT240, which is use for console IO.
FT240_init:
    lda     #$FC
    sta     PIA_ACR         ; Disable input latching, don't touch the other bits
    lda     #FT240_NOSTB    ; RD# = 1
    sta     PIA_PCR
    lda     PIA_PORTB       ; WR = 0, don't touch the other bits
    and     #~FT240_WRMSK
    sta     PIA_PORTB
    lda     #PIA_IN         ; data port input, its only output when writing to FT240
    sta     PIA_DDRA
    lda     PIA_DDRB        ; control ports bits for FT240, don't touch other bits
    ora     #FT240_WRMSK    ; WR is ouptut
    and     #$3F            ; TXE# and RXF# are input
    sta     PIA_DDRB
    rts

; Output the value in the acc to the console    
PutChar:
    bit     PIA_PORTB       ; Test TXE (bit-6)
    bvs     PutChar         ; When set the FIFO is full, keep polling until there is room
    sta     PIA_PORTA       ; Write data to port
    lda     #PIA_OUT        ; Set data port direction to output
    sta     PIA_DDRA
    lda     PIA_PORTB       ; FT240 WR = 1 (don't touch other bits)
    ora     #FT240_WRMSK
    sta     PIA_PORTB
    and     #~FT240_WRMSK   ; FT240 WR = 0
    sta     PIA_PORTB
    lda     #PIA_IN         ; Set data port direction to input
    sta     PIA_DDRA
    rts

; Read a character from the console in the acc, C == 1 indicates a character was read
GetChar:
    bit     PIA_PORTB       ; Test RXF# (bit-7)
    bmi     $$NoChar          ; Branch when RXF# is set, no data in FIFO
    ldx     #FT240_RDSTB    ; FT240 RD# = 0; strobe next byte from FIFO
    stx     PIA_PCR
    lda     PIA_PORTA       ; Read data byte from FT240 (assumes DDR in input)
    ldx     #FT240_NOSTB    ; FT240 RD# = 1
    stx     PIA_PCR
    sec                     ; Set carry to indicate we read a data byte
    rts
$$NoChar:
    clc                     ; Clear carry to indicate there was nothing to read
    rts