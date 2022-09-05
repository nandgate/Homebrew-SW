    CPU     6800

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
FT240_SIWU  EQU     $20     ; SIWU on bit 5, always high
FT240_NOSTB EQU     $0E     ; RD# = 1, irqs disabled 
FT240_RDSTB EQU     $0C     ; RD# = 0, irqs disabled 
FT240_TXE   EQU     $40     ; TXE# on bit 6 (FIFO can accept data when low)
FT240_RXF   EQU     $80     ; RXF# on bit 7 (FIFO has data when low)


; Initialize the VIA to operate iwth the FT240, which is use for console IO.
FT240_init:
    ldaa    #FT240_NOSTB    ; RD# = 1
    staa    PIA_PCR
    ldaa    PIA_PORTB       ; WR = 0, don't touch the other bits
    anda    #~FT240_WRMSK
    staa    PIA_PORTB
    ldaa    #PIA_IN         ; data port input, its only output when writing to FT240
    staa    PIA_DDRA
    ldaa    PIA_DDRB        ; control ports bits for FT240, don't touch other bits
    oraa    #(FT240_WRMSK | FT240_SIWU) & $FF   ; Ouptut pins
    anda    #(~(FT240_RXF | FT240_TXE)) & $FF   ; Input pins
    staa    PIA_DDRB

FT240_Flush:
    ldaa    PIA_PORTB       ; Test RXF# (bit-7)
    bmi     $$NoChar        ; Branch when RXF# is set, no data in FIFO
    ldab    #FT240_RDSTB    ; FT240 RD# = 0; strobe next byte from FIFO
    stab    PIA_PCR
    nop
    ldab    #FT240_NOSTB    ; FT240 RD# = 1
    stab    PIA_PCR
    bra     FT240_Flush
$$NoChar:
    rts

; Output the value in the accA to the console    
PutChar:
    psha
$$PutWait:
    ldaa    PIA_PORTB       ; Test TXE (bit-6)
    bita    #FT240_TXE
    bne     $$PutWait       ; When set the FIFO is full, keep polling until there is room
    pula
    staa    PIA_PORTA       ; Write data to port
    ldaa    #PIA_OUT        ; Set data port direction to output
    staa    PIA_DDRA
    ldaa    PIA_PORTB       ; FT240 WR = 1 (don't touch other bits)
    oraa    #FT240_WRMSK
    staa    PIA_PORTB
    anda    #~FT240_WRMSK   ; FT240 WR = 0
    staa    PIA_PORTB
    ldaa    #PIA_IN         ; Set data port direction to input
    staa    PIA_DDRA
    rts

; Read a character from the console in the accA, C == 1 indicates a character was read
GetChar:
    ldaa    PIA_PORTB       ; Test RXF# (bit-7)
    bmi     $$NoChar        ; Branch when RXF# is set, no data in FIFO
    ldab    #FT240_RDSTB    ; FT240 RD# = 0; strobe next byte from FIFO
    stab    PIA_PCR
    ldaa    PIA_PORTA       ; Read data byte from FT240 (assumes DDR in input)
    ldab    #FT240_NOSTB    ; FT240 RD# = 1
    stab    PIA_PCR
    sec                     ; Set carry to indicate we read a data byte
    rts
$$NoChar:
    clc                     ; Clear carry to indicate there was nothing to read
    rts