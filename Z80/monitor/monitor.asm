    CPU     Z80
    include "vec.asm"

    ORG     $0080
    include "LED.asm"
    include "uart.asm"
    include "hexio.asm"

; Order is important
STYP    EQU     $EFF0
SCNT    EQU     $EFF1   
SCHK    EQU     $EFF2   
ADDRL   EQU     $EFF3
ADDRH   EQU     $EFF4
USERL   EQU     $EFF5
USERH   EQU     $EFF6

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

; HL is addrH, addrL
; DE is userH, userL

reset:
    im      1               ; Use a known vector for interrups
    ld      sp,$FFFF
    call    FT240_init
    call    LED_init

InitMon:
    ld      hl,$0000
    ld      (ADDRL),hl
    ld      (USERL),hl
    
InfoCmd:
    ld      hl,InfoStr
    call    putStr

Prompt:
;    call    LED_RED_Off
    ld      a,$0a           ; Show Prompt
    call    PutChar
    ld      hl,(ADDRL)      ; Show the address
    call    putHex16
    ld      a,' '             ; Space to seperate address and data
    call    PutChar
    ld      hl,(ADDRL)
    ld      a,(hl)
    call    putHex8
    ld      a,'>'            ; Show Prompt
    call    PutChar
 NextChar:   
    call    GetChar         ; get char from user (blocking)
;    call    LED_RED_On
;    call    PutChar         ; Should we echo the character?????
    cp      '?'             ; Show info?
    jp      z,InfoCmd
    cp      'S'             ; S-record?
    jp      z,LoadSrec
    cp      '='             ; re-read address?
    jp      z,Prompt
    cp      $0a             ; Write data byte?
    jp      nz,NotWrite
    ld      hl,(ADDRL)
    ld      a,(USERL)
    ld      (hl),a          ; Store the last 8-bit value entered at the current address    
    jp      DoInc           ; Increment the current address

NotWrite:
    cp     '+'              ; Incement address?
    jp      nz,NotInc
DoInc:
    call    IncAddr
    jp      Prompt

NotInc:
    cp      '-'             ; Decrement address?
    jp      nz,NotDec
    call    DecAddr
    jp      Prompt

NotDec:
    cp      'g'            ; go to address?
    jp      nz,NotGo
    ld      bc,reset
    push    bc
    ld      hl,(ADDRL)
    jp      (hl)

NotGo:
    cp      ' '            ; set current address?
    jp      nz,NotAddr
    ld      hl,(USERL)
    ld      (ADDRL),hl
    jp      Prompt         ; Continue with the new address 

NotAddr:
    call    parseHexDigit
    jp      c,Prompt          ; Ignore chractervand show prompt

GotHex:   
    ld      hl,USERL          ; a: E    USERH: AB   USERL: CD
    rld                       ; a: C    USERH: AB   USERL: DE
    inc     hl              
    rld                       ; a: A    USERH: BC   USERL: DE
    jp      NextChar
    
IncAddr:
    ld  hl,(ADDRL)
    inc hl
    ld  (ADDRL),hl
    ret

DecAddr:
    ld  hl,(ADDRL)
    dec hl
    ld  (ADDRL),hl
    ret

; Read and process an S-record
LoadSrec:
    call    GetChar             ; Get the S-record type
    ld      (STYP),a            ; Save it for later
    cp      '0'                 ; S0 record?
    jp      z,S0Rec             ; yes, processes it
    cp      '1'                 ; S1 record?
    jp      z,SRec              ; yes, process it
    cp      '9'                 ; S9 record?
    jp      z,SRec              ; yes, process it
ReadToEOL:                      ; Not a support S-reord type
    call    GetChar             ; get next char
    cp      a,'\n'              ; End Of Line?
    jp      nz,ReadToEOL        ; No, keep reading
    jp      Prompt              ; Yes, done with record
S0Rec:
    call    LED_RED_Off         ; Turn off the error status LED
SRec:
    ld      a,0                 ; New record, clear the checksum
    ld      (SCHK), a
    call    getHexByteSrec      ; Get byte count
    jp      c,SErr              ; skip rest of line when not hex
    ld      (SCNT),a
    call    getHexByteSrec      ; Get address high
    jp      c,SErr              ; skip rest of line when not hex
    ld      (ADDRH),a
    call    getHexByteSrec      ; Get address low
    jp      c,SErr              ; skip rest of line when not hex
    ld      (ADDRL),a
    ld      a,(STYP)            ; Is this a S0 record?
    cp     '0'                  
    jp      nz,SLoop            ; Nope skip S0Tag    
    ld      hl,S0Tag            ; Show we got a S0 record 
    call    putStr
    ld      hl,(ADDRL)          ; Show the address field
    call    putHex16
    ld      a,':'               ; Seperator
    call    putChar
SLoop:
    ld      a,(SCNT)            ; Is checksum next byte?
    dec     a
    jp      z,SVerify           ; Yes, verify checksum
    call    getHexByteSrec      ; No, read the next byte as two hex digits
    jp      c,SErr              ; skip rest of line when not hex
    
    ld      b,a
    ld      a,(STYP)            ; What type of record is this?
    cp     '0'                  ; S0 record?
    jp      nz,S1Rec
    ld      a,b
    call    putChar             ; yes, echo back to the user as a char
    jp      SLoop
S1Rec:
    cp      '1'                 ; S1 record?
    jp      nz,SLoop            ; no, must be S9, ignore the data
    ld      hl,(ADDRL)          ; yes, save the data byte to the current address
    ld      (hl),b
    call    IncAddr             ; Increment the address
    jp      SLoop
SVerify:
    call    getHexByteSrec      ; read the checksum
    jp      c,SErr              ; skip rest of line when not hex
    ld      a,(SCHK)            ; Checksum is now valid when it is zero
    inc     a
    cp      a,0
    jp      z,SChkOK            ; Checks out..
SErr:
    call    LED_RED_ON          ; Checksum failed, turn on the red light
    jp      ReadToEOL           ; Skip the rest of the line until EOL
SChkOk:
    ld      a,(STYP)            ; What was the record type?
    cp     '9'                  ; S9 record?
    jp      nz,ReadToEOL        ; no, done with this record, skip the rest of the line
    ld      hl,(ADDRL)          ; yes, get the address
    ld      a,h                 ; is the address zero?
    add     a,l
    jp      z,ReadToEOL         ; yes, done with record
    jp      (hl)                ; no, transer to specified address (TODO:use go command)

getHexByteSrec:
    call    getHexByte          ; get a byte as two hex digits
    ret     c                   ; bail on error
    ld      b,a
    ld      hl,SCHK             ; add byte value to running checksum
    add     a,(hl)
    ld      (hl),a
    ld      hl,SCNT             ; Decrement the byte count
    dec     (hl)
    ld      a,b                 ; return the byte value
    and     a,$ff               ; clear carty ofr success
    ret
    
S0Tag:
    db      10,"S0 ",0
    
InfoStr:
    db     10,"MiniMon,0.1,Z80,0",10,0

    