    CPU     Z80

    ORG     $0000   ; Reset
    jp      reset

    ORG     $0038   ; IRQ
 irq:
    jp      irq
    
    ORG     $0066   ; NMI
 nmi:
    jp      nmi
    
    
