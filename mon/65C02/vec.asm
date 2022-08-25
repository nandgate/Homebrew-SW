    CPU     65C02

; Vector table
    ORG    $FFFA
    ADR     nmi
    ADR     reset
    ADR     irqBrk
