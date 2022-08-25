    CPU     6502

; Vector table
    ORG    $FFFA
    ADR     nmi
    ADR     reset
    ADR     irqBrk
