    CPU     6502

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
; <sp>  Set current address   

; Zero page address
addrL       EQU     $00
addrH       EQU     $01
userL       EQU     $02
userH       EQU     $03
strPtrL     EQU     $04
strPtrH     EQU     $05
styp        EQU     $06
scnt        EQU     $07   
schk        EQU     $08   

hi  function x,(x>>8)&255
lo  function x,x&255


reset:
    cld                     ; Make sure we are NOT is decimal mode
    ldx     #$FF
    txs
    jsr     FT240_init
    jsr     LED_init

InitMon:
    lda     #$00            ; Clear monitor state
    sta     addrL           
    sta     addrH
    sta     userL
    sta     userH
    
InfoCmd:
    lda     #lo(InfoStr)
    sta     strPtrL
    lda     #hi(InfoStr)
    sta     strPtrH
    jsr     putStr

Prompt:
;    jsr     LED_RED_Off
    lda     #$0a            ; Show Prompt
    jsr     PutChar
    lda     addrH           ; Show address
    sta     strPtrH
    lda     addrL
    sta     strPtrL
    jsr     putHex16
    lda     #' '            ; Space to seperate address and data
    jsr     PutChar
    ldy     #$00
    lda     (addrL),y       ; Show data at address
    jsr     putHex8
    lda     #'>'            ; Show Prompt
    jsr     PutChar
 NextChar:   
    jsr     GetChar         ; get char from user
;    jsr     LED_RED_On
;    tax
;    jsr     PutChar         ; Should we echo the character?????
;    txa
    cmp     #'?'            ; Show info?
    beq     InfoCmd
    cmp     #'S'             ; S-record?
    beq     LoadSrec
    cmp     #'='            ; re-read address?
    beq     Prompt
    cmp     #$0a            ; Write data byte?
    bne     NotWrite
    lda     userL           ; Get the last 8-bit value entered
    ldy     #$00
    sta     (addrL),y       ; Store at the current address
    jmp     DoInc           ; Increment the current address

NotWrite:
    cmp     #'+'            ; Incement address?
    bne     NotInc
DoInc:
    inc     addrL           ; TODO test this logic: 03FF -> 0400 -> 0401; FFFF -> 0000
    bne     Prompt
    inc     addrH
    jmp     Prompt

NotInc:
    cmp     #'-'            ; Decrement address?
    bne     NotDec
    lda     addrL
    bne     $$NoMSB
    dec     addrH
$$NoMSB:
    dec     addrL
    jmp     Prompt

NotDec:
    cmp     #'g'            ; go to address?
    bne     NotGo
Go:
    lda     #(reset-1)>>8   ; push the return address onto the stack
    pha
    lda     #(reset-1)&$FF
    pha
    jmp     (addrL)

NotGo:
    cmp     #' '            ; set current address?
    bne     NotAddr
    lda     userL           ; move the user value to the current address
    sta     addrL
    lda     userH
    sta     addrH
    lda     #$00            ; clear user value
    sta     userL
    sta     userH
    jmp     Prompt          ; Continue with the new address 

NotAddr:
ParseHex:
    jsr     parseHexDigit
    bcs     Prompt
    asl     userL           ; Shift the user value to the left by 4 bits
    rol     userH
    asl     userL
    rol     userH
    asl     userL
    rol     userH
    asl     userL
    rol     userH
    ora     userL           ; Insert the nibble into the user value
    sta     userL
    jmp     NextChar        ; Done, get next char    

; Read and process an S-record
LoadSrec:
    jsr     GetChar             ; Get the S-record type
    sta     styp                ; Save it for later
    cmp     #'0'                ; S0 record?
    beq     S0Rec               ; yes, processes it
    cmp     #'1'                ; S1 record?
    beq     SRec                ; yes, process it
    cmp     #'9'                ; S9 record?
    beq     SRec                ; yes, process it
ReadToEOL:                      ; Not a support S-reord type
    jsr     GetChar             ; get next char
    cmp     #'\n'               ; End Of Line?
    bne     ReadToEOL           ; No, keep reading
    jmp     Prompt              ; Yes, done with record
S0Rec:
    jsr     LED_RED_OFF         ; Turn off the error status LED
SRec:
    lda     #$00
    sta     schk                ; New record, clear the checksum
    jsr     getHexByteSrec      ; Get byte count
    bcs     SErr                ; skip rest of line when not hex
    sta     scnt
    jsr     getHexByteSrec      ; Get address high
    bcs     SErr                ; skip rest of line when not hex
    sta     addrH
    jsr     getHexByteSrec      ; Get address low
    bcs     SErr                ; skip rest of line when not hex
    sta     addrL
    lda     styp                ; Is this a S0 record?
    cmp     #'0'                  
    bne     SLoop               ; Nope skip S0Tag
    lda     #lo(S0Tag)          ; Show we got a S0 record
    sta     strPtrL
    lda     #hi(S0Tag)
    sta     strPtrH              
    jsr     putStr
    lda     addrH               ; Show the address field
    jsr     putHex8   
    lda     addrL               
    jsr     putHex8
    lda     #':'                ; Seperator
    jsr     putChar
SLoop:
    lda     scnt                ; Is checksum next byte?
    sec
    sbc     #$01
    beq     SVerify             ; Yes, verify checksum
    jsr     getHexByteSrec      ; No, read the next byte as two hex digits
    bcs     SErr                ; skip rest of line when not hex
    ldx     styp                ; Is this a S0 record?    
    cpx     #'0'
    bne     S1Rec
    jsr     putChar             ; yes, echo back to the user as a char
    jmp     SLoop
S1Rec:
    cpx     #'1'                ; is this an S1 record?
    bne     SLoop               ; no, must be S9, ignore the data
    ldy     #$00                ; yes, save the data byte to the current address
    sta     (addrL),y 
    inc     addrL               ; Increment the address   
    bne     $$Skip
    inc     addrH
$$Skip:
    jmp     SLoop
SVerify:
    jsr     getHexByteSrec      ; read the checksum
    bcs     SErr                ; skip rest of line when not hex
    lda     SCHK                ; Checksum is now valid when it is zero
    clc
    adc     #$01
    beq     SChkOK              ; Checks out..
SErr:
    jsr     LED_RED_ON          ; Checksum failed, turn on the red light
    jmp     ReadToEOL           ; Skip the rest of the line until EOL
SChkOk:
    lda     styp                ; S9 record?
    cmp     #'9'
    beq     $$Skip              ; no, done with this record, skip the rest of the line
    jmp     ReadToEOL
$$Skip:
    lda     addrH               ; yes, get the address
    ora     addrL               ; is the address zero?
    beq     $$Skip2           ; yes, done with record
    jmp     Go                  ; no, transer to specified address 
$$Skip2:
    jmp     ReadToEOL
    
getHexByteSrec:
    jsr     getHexByte          ; get a byte as two hex digits
    bcs     $$Exit              ; bail on error
    tax
    clc
    adc     schk                ; add byte value to running checksum
    sta     schk
    dec     scnt                ; Decrement the byte count
    txa                         ; return the byte value
    clc                         ; clear carry for success
$$Exit:
    rts

S0Tag:
    FCB      10,"S0 ",0
    
InfoStr:
    FCB     10,"MiniMon,0.1,6502,0",10,0
   
nmi:
    jmp     nmi

irqBrk:
    jmp     irqBrk

    