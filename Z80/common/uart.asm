    CPU     Z80

PIA_BASE    EQU     $00
PIA_PORTB   EQU     PIA_BASE + $0
PIA_PORTA   EQU     PIA_BASE + $1
PIA_DDRB    EQU     PIA_BASE + $2
PIA_DDRA    EQU     PIA_BASE + $3
PIA_ACR     EQU     PIA_BASE + $B
PIA_PCR     EQU     PIA_BASE + $C
    
PIA_IN      EQU     $00
PIA_OUT     EQU     $FF

FT240_WRMSK EQU     $01     ; WR on bit-0, pulse high to write to the FIFO
FT240_SIWU  EQU     $20     ; SIWU on bit 5, always high
FT240_NOSTB EQU     $0E     ; RD# = 1, irqs disabled 
FT240_RDSTB EQU     $0C     ; RD# = 0, irqs disabled (used to read from the FIFO)
FT240_TXE   EQU     $40     ; TXE# on bit 6 (FIFO can accept data when low)
FT240_RXF   EQU     $80     ; RXF# on bit 7 (FIFO has data when low)

; Initialize the VIA to operate iwth the FT240, which is use for console IO.
FT240_init:
    ld      a,FT240_NOSTB  ; RD# = 1
    out     PIA_PCR,a
    in      a,PIA_PORTB
    and     ~FT240_WRMSK   ; WR = 0, don't touch the other bits
    or      FT240_SIWU     ; SIWU = 1, dont' tough the other bits
    out     PIA_PORTB,a
    ld      a,PIA_IN       ; data port input, its only output when writing to FT240
    out     PIA_DDRA,a
    in      a,PIA_DDRB    ; control ports bits for FT240, don't touch other bits
    or      (FT240_WRMSK | FT240_SIWU) & $FF   ; Ouptut pins
    and     (~(FT240_RXF | FT240_TXE)) & $FF   ; Input pins
    out     PIA_DDRB,a

FT240_Flush:
    in      a,PIA_PORTB   ; Test RXF# (bit-7)
    bit     7,a
    ret     nz              ; Return when RXF# is set, no data in FIFO
    ld      a,FT240_RDSTB  ; FT240 RD# = 0; strobe next byte from FIFO
    out     PIA_PCR,a
    nop
    ld      a,FT240_NOSTB  ; FT240 RD# = 1
    out     PIA_PCR,a
    jp      FT240_Flush
$$NoChar:
    ret

; Output the value in the acc to the console    
PutChar:
    push    bc
    ld      c,PIA_PORTB
$$PutCharPoll:
    in      b,(c)           ; Test TXE (bit-6)
    bit     6,b
    jp      nz,$$PutCharPoll     ; When set the FIFO is full, keep polling until there is room
    out     PIA_PORTA,a   ; Write data to port
    ld      a,PIA_OUT      ; Set data port direction to output
    out     PIA_DDRA,a
    in      a,PIA_PORTB   ; FT240 WR = 1 (don't touch other bits)
    or      FT240_WRMSK
    out     PIA_PORTB,a
    and     ~FT240_WRMSK   ; FT240 WR = 0
    out     PIA_PORTB,a
    ld      a,PIA_IN         ; Set data port direction to input
    out     PIA_DDRA,a
    pop     bc
    ret

; Read a character from the console in the acc, C == 1 indicates a character was read
GetChar:
    push    bc
    in      a,PIA_PORTB   ; Test RXF# (bit-7)
    bit     7,a
    jp      nz,$$NoChar        ; Branch when RXF# is set, no data in FIFO
    ld      a,FT240_RDSTB   ; FT240 RD# = 0; strobe next byte from FIFO
    out     PIA_PCR,a
    in      a,PIA_PORTA   ; Read data byte from FT240 (assumes DDR in input)
    ld      b,a
    ld      a,FT240_NOSTB    ; FT240 RD# = 1
    out     PIA_PCR,a
    scf                     ; Set carry to indicate we read a data byte
    ld      a,b
    pop     bc
    ret
$$NoChar:
    scf                     ; CLear carry to indicate there was nothing to read
    ccf                     
    pop     bc
    ret
   