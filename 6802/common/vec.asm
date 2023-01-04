    CPU     6800

; Vector table
    ORG     $FFF8
    ADR     irq
    ADR     swi
    ADR     nmi
    ADR     reset
