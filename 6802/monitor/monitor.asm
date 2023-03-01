    CPU     6800
    include "vec.asm"

    ORG     $F000
    include "LED.asm"
    include "uart.asm"
    include "hexio.asm"

; Simple monitor:
; Prompt messsage is:
; 
; aaaa bb>
; 
; Where aaaa is the current addess and bb is the current value at that address.
;
; Commands:
; ?     Show the info message
; =     Re-read the current address
; <lf>  Write to current address and increment address
; +     Increment current address
; -     Decrement current address
; g     Go to current address
; <sp>  Set urrent address   

; Zero page address
addrH       EQU     $00
addrL       EQU     $01
userH       EQU     $02
userL       EQU     $03
ptrH        EQU     $04
ptrL        EQU     $05
styp        EQU     $06
scnt        EQU     $07   
schk        EQU     $08   

reset:
    lds     #$01FF
    jsr     FT240_init
    jsr     LED_init

InitMon:
    ldaa    #$00            ; Clear monitor state
    staa    addrL           
    staa    addrH
    staa    userL
    staa    userH
    
InfoCmd:
    ldx     #InfoStr
    jsr     putStr

Prompt:
;    jsr     LED_RED_Off
    ldaa    #$0a            ; Show Prompt
    jsr     PutChar
    ldab    addrH           ; Show address
    ldaa    addrL
    jsr     putHex16
    ldaa    #' '            ; Space to seperate address and data
    jsr     PutChar
    ldx     addrH           ; Show data at address
    ldaa    0,x             
    jsr     putHex8
    ldaa    #'>'            ; Show Prompt
    jsr     PutChar
 NextChar:   
    jsr     GetChar         ; get char from user
;    jsr     LED_RED_On
    tab
;    jsr     PutChar         ; Should we echo the character?????
    tba
    cmpa    #'?'            ; Show info?
    beq     InfoCmd
    cmpa    #'S'             ; S-record?
    beq     LoadSrec
    cmpa    #'='            ; re-read address?
    beq     Prompt
    cmpa    #$0a            ; Write data byte?
    bne     NotWrite
    ldaa    userL           ; Get the last 8-bit value entered
    ldx     addrH
    staa    0,x             ; Store at the current address
    bra     DoInc           ; Increment the current address

NotWrite:
    cmpa    #'+'            ; Incement address?
    bne     NotInc
DoInc:
    ldx     addrH
    inx          
    stx     addrH
    bra     Prompt

NotInc:
    cmpa    #'-'            ; Decrement address?
    bne     NotDec
    ldx     addrH
    dex
    stx     addrH
    bra     Prompt

NotDec:
    cmpa    #'g'            ; go to address?
    bne     NotGo
    lda     #(reset)&$FF    ; push the return address onto the stack
    psha
    lda     #(reset)>>8
    psha
    ldx     addrH
    jmp     0,x

NotGo:
    cmpa    #' '            ; set current address?
    bne     NotAddr
    ldx     userH           ; move the user value to the current address
    stx     addrH
    ldaa    #$00            ; clear user value
    staa    userL
    staa    userH
    bra     Prompt          ; Continue with the new address 

NotAddr:
ParseHex:
    jsr     parseHexDigit   ; Get a hex digit
    bcs     Prompt          ; Bail when not a hex digit
    psha                    ; save value for later
    ldaa    userL           ; Shift the user value to the left by 4 bits
    ldab    userH
    asla
    rolb
    asla
    rolb
    asla
    rolb
    asla
    rolb
    staa    userL
    stab    userH
    pula                    ; get the value back
    oraa    userL           ; Insert the nibble into the user value
    staa    userL
    bra     NextChar        ; Done, get next char    
    
; Read and process an S-record
LoadSrec:
    jsr     GetChar             ; Get the S-record type
    staa    styp                ; Save it for later
    cmpa    #'0'                ; S0 record?
    beq     S0Rec               ; yes, processes it
    cmpa    #'1'                ; S1 record?
    beq     SRec                ; yes, process it
    cmpa    #'9'                ; S9 record?
    beq     SRec                ; yes, process it
ReadToEOL:                      ; Not a support S-reord type
    jsr     GetChar             ; get next char
    cmpa    #'\n'               ; End Of Line?
    bne     ReadToEOL           ; No, keep reading
    jmp     Prompt              ; Yes, done with record
S0Rec:
    jsr     LED_RED_OFF         ; Turn off the error status LED
SRec:
    clr     schk                ; New record, clear the checksum
    jsr     getHexByteSrec      ; Get byte count
    bcs     SErr                ; skip rest of line when not hex
    staa    scnt
    jsr     getHexByteSrec      ; Get address high
    bcs     SErr                ; skip rest of line when not hex
    staa    addrH
    jsr     getHexByteSrec      ; Get address low
    bcs     SErr                ; skip rest of line when not hex
    staa    addrL
    ldaa    styp                ; Is this a S0 record?
    cmpa    #'0'                  
    bne     SLoop               ; Nope skip S0Tag    
    ldx     #S0Tag              ; Show we got a S0 record 
    jsr     putStr
    ldaa    addrL               ; Show the address field
    ldab    addrH
    jsr     putHex16
    ldaa    #':'                ; Seperator
    jsr     putChar
SLoop:
    ldaa    scnt                ; Is checksum next byte?
    dec     a
    beq     SVerify             ; Yes, verify checksum
    jsr     getHexByteSrec      ; No, read the next byte as two hex digits
    bcs     SErr                ; skip rest of line when not hex
    ldab    styp                ; Is this a S0 record?    
    cmpb    #'0'
    bne     S1Rec
    jsr     putChar             ; yes, echo back to the user as a char
    bra     SLoop
S1Rec:
    cmpb    #'1'                ; is this an S1 record?
    bne     SLoop               ; no, must be S9, ignore the data
    ldx     addrH               ; yes, save the data byte to the current address
    sta     0,x
    inx                         ; Increment the address
    stx     addrH
    bra     SLoop
SVerify:
    jsr     getHexByteSrec      ; read the checksum
    bcs     SErr                ; skip rest of line when not hex
    lda     SCHK                ; Checksum is now valid when it is zero
    inc     a
    beq     SChkOK              ; Checks out..
SErr:
    jsr     LED_RED_ON          ; Checksum failed, turn on the red light
    bra     ReadToEOL           ; Skip the rest of the line until EOL
SChkOk:
    ldab    styp                ; S9 record?
    cmpb    #'9'
    bne     ReadToEOL           ; no, done with this record, skip the rest of the line
    ldx     addrH               ; yes, get the address
    cmpx    #0                  ; is the address zero?
    beq     ReadToEOL           ; yes, done with record
    jsr     0,x                 ; no, transer to specified address 
    jmp     InitMon
    
getHexByteSrec:
    jsr     getHexByte          ; get a byte as two hex digits
    bcs     $$Exit              ; bail on error
    psha    
    adda    schk                ; add byte value to running checksum
    staa    schk
    dec     scnt                ; Decrement the byte count
    pula                        ; return the byte value
    clc                         ; clear carry for success
$$Exit:
    rts
    
S0Tag:
    db      10,"S0 ",0
    
InfoStr:
    FCB     10,"MiniMon,0.1,6802,0",10,0
   
irq:
    bra     irq

swi: 
    bra     swi
    
nmi:
    bra     nmi

;  S00400004100