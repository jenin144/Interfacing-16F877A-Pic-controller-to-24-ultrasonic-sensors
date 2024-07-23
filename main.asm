;;final

PROCESSOR 16F877A
INCLUDE "P16F877A.INC"

__CONFIG 0x3731

HUSNUM EQU 33
LUSNUM EQU 34
delay EQU 50
TMR_VAL_L EQU 32 ; Low byte of 16-bit TMR1 value
TMR_VAL_H EQU 33 ; High byte of 16-bit TMR1 value
TEMP EQU 39 ; Temporary variable for calculations
TEMP2 EQU 40 ; Second temporary variable for calculations

Num1 EQU 43 ; First number input
divisor EQU 44 ; Divisor (28)
Result EQU 45 ; Calculated result

TEMP11 EQU 46 ; Temporary variable for calculations
TEMP22 EQU 47 ; Second temporary variable for calculations
TEMP33 EQU 49 ; Second temporary variable for calculations
COMBINED   EQU 53   ; Define COMBINED at address 0x23
ECHO_PIN EQU 54

Msd EQU 50 ; Most significant digit of result
Lsd EQU 51 ; Least significant digit of result
hundred EQU 52 ; Mode for display selection

blink_count EQU 0x77
delay_counter1 EQU 0x87
delay_counter2 EQU 0x88
delay_counter3 EQU 0x89

HIGH1 EQU 35
HIGH2 EQU 36
HIGH3 EQU 37
HIGH4 EQU 38


VAL1 EQU 60
VAL2 EQU 61
VAL3 EQU 62
VAL4 EQU 63
VAL5 EQU 64
VAL6 EQU 65
VAL7 EQU 31
VAL8 EQU 67
VAL9 EQU 68
VAL10 EQU 69
VAL11 EQU 32
VAL12 EQU 30
;*
VAL13 EQU 20
VAL14 EQU 21
VAL15 EQU 22
VAL16 EQU 23
VAL17 EQU 24
;*
VAL18 EQU 25
VAL19 EQU 26
VAL20 EQU 27
VAL21 EQU 99
VAL22 EQU 28
VAL23 EQU 101
VAL24 EQU 29

COUNTER EQU 54



;;;;;;;;;;;;;;;;;;
; The instructions should start from here
ORG 0x00
GOTO init

ORG 0x04
GOTO ISR

; The init for our program
init:
BANKSEL TRISD ; Select bank 1
CLRF TRISD ; Display port is output

BANKSEL TRISB ; Select bank 1
BSF TRISB, 2 ; RB4 (echo pin) is input
BSF TRISB, 3 ; RB4 (echo pin) is input
BSF TRISB, 4 ; RB4 (echo pin) is input

BANKSEL TRISC ; Select bank 1
BCF TRISC, 0 ; RB4 (echo pin) is input
BCF TRISC, 1 ; RB4 (echo pin) is input
BCF TRISC, 2 ; RB4 (echo pin) is input
BCF TRISC, 3 ; RB4 (echo pin) is input
BCF TRISC, 4 ; RB4 (echo pin) is input
BCF TRISC, 5 ; RB4 (echo pin) is input

; Initialize TMR1
BANKSEL T1CON ; Select bank 1
MOVLW 0x31 ; T1CON = 0b00110001 (Timer1 ON, prescaler 1:8)
MOVWF T1CON
CLRF TMR1H ; Clear TMR1 High byte
CLRF TMR1L ; Clear TMR1 Low byte
BCF PIR1, TMR1IF ; Clear TMR1 overflow flag
BSF PIE1, TMR1IE ; Enable TMR1 interrupt

BANKSEL PORTD

GOTO start

; When interrupt happens the program will enter here
ISR:
BANKSEL PIR1
BCF PIR1, TMR1IF ; Clear TMR1 interrupt flag
BANKSEL PORTD
retfie

INCLUDE "LCDIS_PORTD.INC" ; IF U WANT TO USE LCD ON PORT D

; The main code for our program
start:

BANKSEL PORTC ; Select bank 1
BSF PORTC, 0 ; RB4 (echo pin) is input
BCF PORTC, 1 ; RB4 (echo pin) is input
BCF PORTC, 2 ; RB4 (echo pin) is input

 MOVLW 1     ; Load W with the value 2
 MOVWF ECHO_PIN
 
 CLRF COUNTER


;;;** STEP1 **

MOVLW 3 ; Number of blinks 3
MOVWF blink_count ; Store in a register
loopblink:

CALL xms
CALL xms
CALL inid
BCF Select, RS ; set display command mode
CALL printWelcomeM_lcd
MOVLW 0x32 ; d'50'
CALL DELAY_W_10_MS ; delay 10ms * 50 = 500ms
MOVLW 0x0E ; cursor blink
CALL send
DECFSZ blink_count, F ; Decrement blink_count
Goto loopblink ; Loop if not zero
Goto step2

;; 500000us = 500 ms= 0.5 sec   - > 50*4*10*250
DELAY_W
MOVWF TEMP
loop_start

NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP

DECFSZ TEMP
GOTO loop_start
RETURN
DELAY_W_10_MS
MOVWF TEMP2
MOVLW 0xFA
lp_st

CALL DELAY_W
CALL DELAY_W
CALL DELAY_W
CALL DELAY_W


DECFSZ TEMP2
GOTO lp_st
RETURN

;;;** STEP 2 **
step2:

BANKSEL PORTC ; Select bank 1
 BCF PORTC, 3 ; RB4 (echo pin) is input
 BCF PORTC, 4 ; RB4 (echo pin) is input
 BCF PORTC, 5 ; RB4 (echo pin) is input


BTFSC PORTC, 3        ; Test bit 3 of PORTC
BSF TEMP11, 0          ; If bit 3 is set, set bit 0 of TEMP3
BTFSS PORTC, 3        ; Test bit 3 of PORTC
BCF TEMP11, 0          ; If bit 3 is clear, clear bit 0 of TEMP3

; Save the value of bit 4 (PORTC4) to TEMP4
BTFSC PORTC, 4        ; Test bit 4 of PORTC
BSF TEMP22, 0          ; If bit 4 is set, set bit 0 of TEMP4
BTFSS PORTC, 4        ; Test bit 4 of PORTC
BCF TEMP22, 0          ; If bit 4 is clear, clear bit 0 of TEMP4

; Save the value of bit 5 (PORTC5) to TEMP5
BTFSC PORTC, 5        ; Test bit 5 of PORTC
BSF TEMP33, 0          ; If bit 5 is set, set bit 0 of TEMP5
BTFSS PORTC, 5        ; Test bit 5 of PORTC
BCF TEMP33, 0          ; If bit 5 is clear, clear bit 0 of TEMP5

loop_selection_lines:


;trig low - wait 2micro - trig high - wait 10micro -

PULSE_trig_pin:
BANKSEL PORTC ; Select bank 1

BTFSC TEMP11, 0      ; Test bit 0 of TEMP3
BCF PORTC, 3        ; If bit 0 of TEMP3 is set, set bit 3 of PORTC
BTFSS TEMP11, 0      ; Test bit 0 of TEMP3
BSF PORTC, 3        ; If bit 0 of TEMP3 is clear, clear bit 3 of PORTC

BTFSC TEMP22, 0      ; Test bit 0 of TEMP4
BCF PORTC, 4        ; If bit 0 of TEMP4 is set, set bit 4 of PORTC
BTFSS TEMP22, 0      ; Test bit 0 of TEMP4
BSF PORTC, 4        ; If bit 0 of TEMP4 is clear, clear bit 4 of PORTC

BTFSC TEMP33, 0      ; Test bit 0 of TEMP5
BCF PORTC, 5        ; If bit 0 of TEMP5 is set, set bit 5 of PORTC
BTFSS TEMP33, 0      ; Test bit 0 of TEMP5
BSF PORTC, 5        ; If bit 0 of TEMP5 is clear, clear bit 5 of PORTC

NOP ; 1 us delay -> 4/ 4 MHZ
NOP ; 1 us delay -> 4/ 4 MHZ
BANKSEL PORTC ; Select bank 1
BTFSC TEMP11, 0      ; Test bit 0 of TEMP3
BSF PORTC, 3        ; If bit 0 of TEMP3 is set, set bit 3 of PORTC
BTFSS TEMP11, 0      ; Test bit 0 of TEMP3
BCF PORTC, 3        ; If bit 0 of TEMP3 is clear, clear bit 3 of PORTC

BTFSC TEMP22, 0      ; Test bit 0 of TEMP4
BSF PORTC, 4        ; If bit 0 of TEMP4 is set, set bit 4 of PORTC
BTFSS TEMP22, 0      ; Test bit 0 of TEMP4
BCF PORTC, 4        ; If bit 0 of TEMP4 is clear, clear bit 4 of PORTC

BTFSC TEMP33, 0      ; Test bit 0 of TEMP5
BSF PORTC, 5        ; If bit 0 of TEMP5 is set, set bit 5 of PORTC
BTFSS TEMP33, 0      ; Test bit 0 of TEMP5
BCF PORTC, 5        ; If bit 0 of TEMP5 is clear, clear bit 5 of PORTC

NOP ; 1 us delay -> 4/ 4 MHZ
NOP ; 1 us delay -> 4/ 4 MHZ
NOP ; 1 us delay -> 4/ 4 MHZ
NOP ; 1 us delay -> 4/ 4 MHZ
NOP ; 1 us delay -> 4/ 4 MHZ
NOP ; 1 us delay -> 4/ 4 MHZ
NOP ; 1 us delay -> 4/ 4 MHZ
NOP ; 1 us delay -> 4/ 4 MHZ
NOP ; 1 us delay -> 4/ 4 MHZ
NOP ; 1 us delay -> 4/ 4 MHZ

BANKSEL PORTC ; Select bank 1

BTFSC TEMP11, 0      ; Test bit 0 of TEMP3
BCF PORTC, 3        ; If bit 0 of TEMP3 is set, set bit 3 of PORTC
BTFSS TEMP11, 0      ; Test bit 0 of TEMP3
BSF PORTC, 3        ; If bit 0 of TEMP3 is clear, clear bit 3 of PORTC

BTFSC TEMP22, 0      ; Test bit 0 of TEMP4
BCF PORTC, 4        ; If bit 0 of TEMP4 is set, set bit 4 of PORTC
BTFSS TEMP22, 0      ; Test bit 0 of TEMP4
BSF PORTC, 4        ; If bit 0 of TEMP4 is clear, clear bit 4 of PORTC

BTFSC TEMP33, 0      ; Test bit 0 of TEMP5
BCF PORTC, 5        ; If bit 0 of TEMP5 is set, set bit 5 of PORTC
BTFSS TEMP33, 0      ; Test bit 0 of TEMP5
BSF PORTC, 5        ; If bit 0 of TEMP5 is clear, clear bit 5 of PORTC

CLRF TMR1H ; Clear TMR1 again to start timing
CLRF TMR1L ; Clear TMR1 Low byte
BCF PIR1, TMR1IF ; Clear TMR1 overflow flag

BANKSEL PORTC ; Select bank 1
BTFSC TEMP11, 0      ; Test bit 0 of TEMP3
BSF PORTC, 3        ; If bit 0 of TEMP3 is set, set bit 3 of PORTC
BTFSS TEMP11, 0      ; Test bit 0 of TEMP3
BCF PORTC, 3        ; If bit 0 of TEMP3 is clear, clear bit 3 of PORTC

BTFSC TEMP22, 0      ; Test bit 0 of TEMP4
BSF PORTC, 4        ; If bit 0 of TEMP4 is set, set bit 4 of PORTC
BTFSS TEMP22, 0      ; Test bit 0 of TEMP4
BCF PORTC, 4        ; If bit 0 of TEMP4 is clear, clear bit 4 of PORTC

BTFSC TEMP33, 0      ; Test bit 0 of TEMP5
BSF PORTC, 5        ; If bit 0 of TEMP5 is set, set bit 5 of PORTC
BTFSS TEMP33, 0      ; Test bit 0 of TEMP5
BCF PORTC, 5        ; If bit 0 of TEMP5 is clear, clear bit 5 of PORTC



BANKSEL PORTB
WAIT_FOR_ECHO_HIGH:
;MOVF ECHO_PIN, W        ; Move the value from TEMP to WREG
NEXT:
MOVF ECHO_PIN, W        ; Move the value from TEMP to WREG
SUBLW 1             ; Subtract 1 from WREG, WREG now contains TEMP - 1
BTFSS STATUS, Z  
GOTO NEXT1 
BTFSS PORTB, 2 ; Skip if echo pin is high
GOTO WAIT_FOR_ECHO_HIGH ; Loop until RB4 is high
GOTO NN

NEXT1:
MOVF ECHO_PIN, W        ; Move the value from TEMP to WREG
SUBLW 2             ; Subtract 1 from WREG, WREG now contains TEMP - 1
BTFSS STATUS, Z 
GOTO NEXT2 
BTFSS PORTB, 3 ; Skip if echo pin is high
GOTO WAIT_FOR_ECHO_HIGH ; Loop until RB4 is high
GOTO NN

NEXT2:
MOVF ECHO_PIN, W        ; Move the value from TEMP to WREG
BTFSS PORTB, 4 ; Skip if echo pin is high
GOTO WAIT_FOR_ECHO_HIGH ; Loop until RB4 is high

; Echo is high, store TMR1 value
NN:
CLRF TMR1H ; Clear TMR1 again to start timing
CLRF TMR1L ; Clear TMR1 Low byte
BCF PIR1, TMR1IF ; Clear TMR1 overflow flag

WAIT_FOR_ECHO_LOW:

NEXT3:
MOVF ECHO_PIN, W        ; Move the value from TEMP to WREG
SUBLW 1             ; Subtract 1 from WREG, WREG now contains TEMP - 1
BTFSS STATUS, Z  
GOTO NEXT4 
BTFSC PORTB, 2 ; Skip if echo pin is high
GOTO WAIT_FOR_ECHO_LOW ; Loop until RB4 is high
GOTO NN2

NEXT4:
MOVF ECHO_PIN, W        ; Move the value from TEMP to WREG
SUBLW 2             ; Subtract 1 from WREG, WREG now contains TEMP - 1
BTFSS STATUS, Z 
GOTO NEXT5 
BTFSC PORTB, 3 ; Skip if echo pin is high
GOTO WAIT_FOR_ECHO_LOW ; Loop until RB4 is high
GOTO NN2

NEXT5:
MOVF ECHO_PIN, W        ; Move the value from TEMP to WREG
BTFSC PORTB, 4 ; Skip if echo pin is high
GOTO WAIT_FOR_ECHO_LOW ; Loop until RB4 is high

NN2:
; MOVLW D'140'
MOVF TMR1L, W ; Read TMR1 Low byte
MOVWF TMR_VAL_L


; MOVLW D'0'
MOVF TMR1H, W ; Read TMR1 high byte
MOVWF TMR_VAL_H



; Initialize divisor
MOVLW D'7'
MOVWF divisor

 ; Clear counter
    CLRF hundred
 	CLRF Result        ; total to Z
;*****************
; Check bit 0 of TMR_VAL_H
    BTFSS TMR_VAL_H, 0 
    GOTO checkSecondBit
	MOVLW D'35'  ; 256/7
	ADDWF Result , F
checkSecondBit
    BTFSS TMR_VAL_H, 1 
    GOTO checkthirdBit
    BTFSC TMR_VAL_H, 0
    GOTO minus10
	MOVLW D'71'  ; 512/7
		ADDWF Result , F
    
checkthirdBit
    BTFSS TMR_VAL_H, 2 
    GOTO div
    BTFSS TMR_VAL_H, 0
    GOTO minus100   
	MOVLW D'140' ; 1024/7
		ADDWF Result , F
    GOTO div 
    
;*****************
minus10:

	MOVLW D'61'  ; 512/7
		ADDWF Result , F
    GOTO div
minus100: 
	MOVLW D'130'
	ADDWF Result , F
   
   
;*******

div:
MOVF divisor, W ; get divisor
BCF STATUS, C ; clear C flag
sub1:
INCF Result ; increment result
SUBWF TMR_VAL_L ; subtract divisor from TMR_VAL_L
BTFSS STATUS, Z ; check if exact answer
GOTO neg ; no
GOTO SKIP  ; yes, display answer
neg:
BTFSC STATUS, C ; gone negative?
GOTO sub1 ; no - repeat
DECF Result ; correct the result
MOVF divisor, W ; get divisor
ADDWF TMR_VAL_L ; calculate remainder

SKIP    
;****************************************************
CALL SETVALUES
;CALL print_lcd


MOVLW 0x32
CALL DELAY_W_10_MS

MOVLW 0x32
CALL DELAY_W_10_MS


;INCF SEL, F


    ; Combine the bits
    CLRF COMBINED         ; Clear the combined register

    MOVF TEMP11, W        ; Move TEMP11 to W
    BTFSC TEMP11, 0       ; Test if TEMP11 is 1
    BSF COMBINED, 0       ; If so, set bit 2 in COMBINED

    MOVF TEMP22, W        ; Move TEMP22 to W
    BTFSC TEMP22, 0       ; Test if TEMP22 is 1
    BSF COMBINED, 1       ; If so, set bit 1 in COMBINED

    MOVF TEMP33, W        ; Move TEMP33 to W
    BTFSC TEMP33, 0       ; Test if TEMP33 is 1
    BSF COMBINED, 2       ; If so, set bit 0 in COMBINED

    ; Increment the combined value
    INCF COMBINED, F      ; Increment the combined value
    

 

    ; Separate the bits
    BTFSS COMBINED, 0     ; Test bit 2 of COMBINED
    BCF TEMP11, 0         ; Clear bit 0 of TEMP11 if bit 2 of COMBINED is 0
    BTFSC COMBINED, 0     ; Test bit 2 of COMBINED again
    BSF TEMP11, 0         ; Set bit 0 of TEMP11 if bit 2 of COMBINED is 1

    BTFSS COMBINED, 1     ; Test bit 1 of COMBINED
    BCF TEMP22, 0         ; Clear bit 0 of TEMP22 if bit 1 of COMBINED is 0
    BTFSC COMBINED, 1     ; Test bit 1 of COMBINED again
    BSF TEMP22, 0         ; Set bit 0 of TEMP22 if bit 1 of COMBINED is 1

    BTFSS COMBINED, 2     ; Test bit 0 of COMBINED
    BCF TEMP33, 0         ; Clear bit 0 of TEMP33 if bit 0 of COMBINED is 0
    BTFSC COMBINED, 2     ; Test bit 0 of COMBINED again
    BSF TEMP33, 0         ; Set bit 0 of TEMP33 if bit 0 of COMBINED is 1
    

BANKSEL PORTC ; Select bank 1
BTFSC TEMP11, 0      ; Test bit 0 of TEMP3
BSF PORTC, 3        ; If bit 0 of TEMP3 is set, set bit 3 of PORTC
BTFSS TEMP11, 0      ; Test bit 0 of TEMP3
BCF PORTC, 3        ; If bit 0 of TEMP3 is clear, clear bit 3 of PORTC

BTFSC TEMP22, 0      ; Test bit 0 of TEMP4
BSF PORTC, 4        ; If bit 0 of TEMP4 is set, set bit 4 of PORTC
BTFSS TEMP22, 0      ; Test bit 0 of TEMP4
BCF PORTC, 4        ; If bit 0 of TEMP4 is clear, clear bit 4 of PORTC

BTFSC TEMP33, 0      ; Test bit 0 of TEMP5
BSF PORTC, 5        ; If bit 0 of TEMP5 is set, set bit 5 of PORTC
BTFSS TEMP33, 0      ; Test bit 0 of TEMP5
BCF PORTC, 5        ; If bit 0 of TEMP5 is clear, clear bit 5 of PORTC

        ; Check if the value is 8 or more
    MOVF COMBINED, W      ; Move the combined value to W
    SUBLW b'111'               ; Subtract 8 from W
    BTFSC STATUS, C       ; Check the Carry flag (if combined >= 8, Carry is set)
    ;CLRF COMBINED         ; Clear COMBINED if it is 8 or more

   GOTO loop_selection_lines ; If USNUM is not 24, go back to start

; Loop back to check the next sensor
;CLRF SEL


MOVF ECHO_PIN,W
XORLW 3                 ; Exclusive OR with 3
BTFSS STATUS, Z         ; Skip next instruction if result is zero (ECHO_PIN == 3)

GOTO SKIP_SET
MOVLW 1                 ; Load WREG with 1
MOVWF ECHO_PIN 
 
GOTO FINAL



SKIP_SET:
MOVF ECHO_PIN,W
ADDLW 1     ; Load W with the value 2
MOVWF ECHO_PIN

MOVF ECHO_PIN, W        ; Move the value from TEMP to WREG
SUBLW 2             ; Subtract 1 from WREG
BTFSS STATUS, Z     ; Skip next instruction if result is zero (TEMP == 1)
GOTO EN3

BANKSEL PORTC ; Select bank 1
BCF PORTC, 0 ; RB4 (echo pin) is input
BSF PORTC, 1 ; RB4 (echo pin) is input
BCF PORTC, 2 ; RB4 (echo pin) is input
GOTO FINAL

EN3:
MOVF ECHO_PIN, W        ; Move the value from TEMP to WREG
SUBLW 3             ; Subtract 1 from WREG
BTFSS STATUS, Z     ; Skip next instruction if result is zero (TEMP == 1)
GOTO FINAL

BANKSEL PORTC ; Select bank 1
BCF PORTC, 0 ; RB4 (echo pin) is input
BCF PORTC, 1 ; RB4 (echo pin) is input
BSF PORTC, 2 ; RB4 (echo pin) is input


FINAL:
GOTO step2


loop:
GOTO loop


print_lcd:
CALL xms
CALL xms
CALL inid

CLRF HUSNUM
CLRF LUSNUM

;^^^^^^^^^^^^^^^^1^^^^^^^^^^^^^^^^^^^^

BCF Select, RS ; set display command mode

 MOVLW 0x01 ; clear display
 CALL send ; send command

 MOVLW 0x0C ; turn on display without cursor
 CALL send ; send command


MOVLW 0x80 ; code to home cursor
CALL send ; output to display
MOVLW D'5' ; move the maximum distance from the register
MOVWF LUSNUM ; store value into USNUM

	;; Call extreaction funcrion  to extract MSD LSD , Hundred
	MOVFW  HIGH1   ;;;
	MOVWF Result
 
	CALL ExtractDigitss
    CALL printdistancetoLCDZEROW

CLRF HUSNUM
CLRF LUSNUM

;^^^^^^^^^^^^^^^^2^^^^^^^^^^^^^^^^^^^^
MOVLW D'1' ; move the SECOND MAX distance from the register
MOVWF LUSNUM ; store value into USNUM
MOVFW  HIGH2   ;;;
MOVWF Result
CALL ExtractDigitss
CALL printdistancetoLCDZEROW
CLRF HUSNUM
CLRF LUSNUM

;^^^^^^^^^^^^^^^^3^^^^^^^^^^^^^^^^^^^^
BCF Select, RS ; set display command mode
MOVLW 0xC0 ; code to move cursor
CALL send
MOVLW D'0' ; THIRD
MOVWF LUSNUM ; store value into USNUM
MOVFW  HIGH3   ;;;
MOVWF Result
CALL ExtractDigitss
CALL printdistancetoLCDZEROW

CLRF HUSNUM
CLRF LUSNUM
;^^^^^^^^^^^^^^^^4^^^^^^^^^^^^^^^^^^^^

MOVLW D'2' ; 4
MOVWF HUSNUM ; store value into USNUM
MOVLW D'5' ; 4
MOVWF LUSNUM ; store value into USNUM
MOVF HIGH4,W   ;;;
MOVWF Result
CALL ExtractDigitss
CALL printdistancetoLCDZEROW


RETURN

printdistancetoLCDZEROW:
BSF Select, RS ; set data mode

MOVLW 'U' ; load 'U'
CALL send ; send to LCD
MOVLW 'S' ; load 'S'
CALL send ; send to LCD
; MOVLW '0' ; load '0'
; CALL send ; send to LCD


;* display Maximum US number ***

MOVF HUSNUM, W ; load high digit result
BTFSC STATUS, Z ; check if zero
GOTO secondnum ; don't display Msd if zero

ADDLW 030 ; convert to ASCII
BSF Select, RS ; select data mode
CALL send ; send Msd

secondnum:
MOVF LUSNUM, W ; load low digit result
ADDLW 030 ; convert to ASCII
BSF Select, RS ; select data mode
CALL send


;* Maximum US ndistance ***
MOVLW ':' ; load ':'
CALL send ; send to LCD

display_msd_lsd:
; Display hundred
MOVF hundred, W ; load high digit result
BTFSC STATUS, Z ; check if zero
GOTO msd ; don't display hundred if zero
ADDLW 030 ; convert to ASCII
BSF Select, RS ; select data mode
CALL send

; Display 2-digit BCD result

msd:
MOVF Msd, W ; load high digit result
BTFSC STATUS, Z ; check if zero
GOTO lowd ; don't display Msd if zero

ADDLW 030 ; convert to ASCII
BSF Select, RS ; select data mode
CALL send ; send Msd

lowd:
MOVF Lsd, W ; load low digit result
ADDLW 030 ; convert to ASCII
BSF Select, RS ; select data mode
CALL send ; send Lsd

done_display:
MOVLW ' ' ; load ':'
CALL send ; send to LCD
RETURN

ExtractDigitss
; Convert binary to BCD ...................................
	;MOVFW Result
outres:
    MOVF Result, W     ; load result
    MOVWF Lsd          ; store in low digit
    CLRF Msd           ; high digit = 0
    BSF STATUS, C      ; set C flag
    MOVLW D'10'        ; load 10

again:
    SUBWF Lsd          ; subtract 10 from result
    INCF Msd           ; increment high digit
    BTFSC STATUS, C    ; check if negative
    GOTO again         ; no, keep going
    ADDWF Lsd          ; yes, add 10 back 
    DECF Msd           ; decrement high digit
;*****

    ; Check if Lsd exceeds 9
     MOVF Lsd, W         ; Move Lsd to W
     SUBLW  d'9'        ; Subtract 10 from W
    BTFSC STATUS, C     ; If the result is zero or negative (borrow)
    GOTO CHECKHUNDRED            ; Return if Lsd is not greater than 9

    ; Decrement Lsd by 10
    MOVLW D'9'         ; Load 10 into W
    SUBWF Lsd, F        ; Subtract 10 from Lsd

    ; Increment Msd by 1
    INCF Msd, F         ; Increment Msd

    ;;;; Check if Msd exceeds 9
    
CHECKHUNDRED    
     MOVF Msd, W         ; Move Lsd to W
     SUBLW  d'9'        ; Subtract 10 from W
    BTFSC STATUS, C     ; If the result is zero or negative (borrow)
    return            ; Return if Lsd is not greater than 9

    ; Decrement Lsd by 10
    MOVLW D'9'         ; Load 10 into W
    SUBWF Msd, F        ; Subtract 10 from Lsd

    ; Increment Msd by 1
    INCF hundred, F         ; Increment Msd
    
    	;movfw Lsd 
;	movfw Msd
    	;movfw hundred



return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printWelcomeM_lcd:

; MOVLW 0x01 ; clear display
; CALL send ; send command

; MOVLW 0x0C ; turn on display without cursor
; CALL send ; send command

MOVLW 0x80 ; set cursor at begining of 1st line
CALL send ; send command

MOVLW 0x1C ; shift screen to the right
CALL send ; send command
MOVLW 0x1C ; shift screen to the right
CALL send ; send command


BSF Select, RS ; set data mode
MOVLW ' '
CALL send
MOVLW ' '
CALL send
MOVLW 'W'
CALL send
MOVLW 'e'
CALL send
MOVLW 'l'
CALL send
MOVLW 'c'
CALL send
MOVLW 'o'
CALL send
MOVLW 'm'
CALL send
MOVLW 'e'
CALL send

BCF Select, RS ; set display command mode
MOVLW 0xC0 ; code to move cursor to second line
CALL send

BSF Select, RS ; set data mode

MOVLW 'S'
CALL send
MOVLW 'F'
CALL send
MOVLW 'R'
CALL send
MOVLW '0'
CALL send
MOVLW '4'
CALL send
MOVLW ' '
CALL send
MOVLW 'M'
CALL send
MOVLW 'o'
CALL send
MOVLW 'd'
CALL send
MOVLW 'u'
CALL send
MOVLW 'l'
CALL send
MOVLW 'e'
CALL send
MOVLW 's'
CALL send


return
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

FINDMAX4Dist:

;'''''''''''''''''''''''''''''''''''

;;; find the maximum 

; Initialize HIGH1 with the first value
MOVF VAL1, W
MOVWF HIGH1
CLRF HIGH2
CLRF HIGH3
CLRF HIGH4

MOVF HIGH1,W
MOVF HIGH2,W
MOVF HIGH3,W
MOVF HIGH4,W

; Start of loop to find the maximum value
MOVF VAL2, W
CALL CompareAndUpdate
MOVF VAL3, W
CALL CompareAndUpdate
MOVF VAL4, W
CALL CompareAndUpdate
MOVF VAL5, W
CALL CompareAndUpdate
MOVF VAL6, W
CALL CompareAndUpdate
MOVF VAL7, W
CALL CompareAndUpdate
MOVF VAL8, W
CALL CompareAndUpdate
MOVF VAL9, W
CALL CompareAndUpdate
MOVF VAL10, W
CALL CompareAndUpdate
MOVF VAL11, W
CALL CompareAndUpdate
MOVF VAL12, W
CALL CompareAndUpdate
MOVF VAL13, W
CALL CompareAndUpdate
MOVF VAL14, W
CALL CompareAndUpdate
MOVF VAL15, W
CALL CompareAndUpdate
MOVF VAL16, W
CALL CompareAndUpdate
MOVF VAL17, W
CALL CompareAndUpdate
MOVF VAL18, W
CALL CompareAndUpdate
MOVF VAL19, W
CALL CompareAndUpdate
MOVF VAL20, W
CALL CompareAndUpdate
MOVF VAL21, W
CALL CompareAndUpdate
MOVF VAL22, W
CALL CompareAndUpdate
MOVF VAL23, W
CALL CompareAndUpdate
MOVF VAL24, W
CALL CompareAndUpdate


; End of program
CALL FINISHH


;***********
CompareAndUpdate:
    ; Compare W with HIGH1
    MOVWF TEMP ; Store the value in W to TEMP
    MOVF HIGH1, W ; Move HIGH1 to W
    SUBWF TEMP, W ; Subtract TEMP from W (W contains HIGH1)
    BTFSC STATUS, C ; If the result is negative, skip the next instruction
    GOTO UpdateHigh1 ; If W > HIGH1, update HIGH1 and shift down

    ; Compare W with HIGH2
    MOVF TEMP, W ; Restore the original value from TEMP
    MOVWF TEMP ; Store the value in W to TEMP
    MOVF HIGH2, W ; Move HIGH2 to W
    SUBWF TEMP, W ; Subtract TEMP from W (W contains HIGH2)
    BTFSC STATUS, C ; If the result is negative, skip the next instruction
    GOTO UpdateHigh2 ; If W > HIGH2, update HIGH2 and shift down

    ; Compare W with HIGH3
    MOVF TEMP, W ; Restore the original value from TEMP
    MOVWF TEMP ; Store the value in W to TEMP
    MOVF HIGH3, W ; Move HIGH3 to W
    SUBWF TEMP, W ; Subtract TEMP from W (W contains HIGH3)
    BTFSC STATUS, C ; If the result is negative, skip the next instruction
    GOTO UpdateHigh3 ; If W > HIGH3, update HIGH3 and shift down

    ; Compare W with HIGH4
    MOVF TEMP, W ; Restore the original value from TEMP
    MOVWF TEMP ; Store the value in W to TEMP
    MOVF HIGH4, W ; Move HIGH4 to W
    SUBWF TEMP, W ; Subtract TEMP from W (W contains HIGH4)
    BTFSS STATUS, C ; If the result is negative, skip the next instruction
    RETURN ; If W <= HIGH4, no update is needed

    ; Update HIGH4 if the new value is greater
    MOVF TEMP, W ; Restore the original value from TEMP
    MOVWF HIGH4 ; Update HIGH4
    RETURN

UpdateHigh1:
    MOVF HIGH3, W ; Move HIGH3 to W
    MOVWF HIGH4 ; Shift HIGH3 to HIGH4
    MOVF HIGH2, W ; Move HIGH2 to W
    MOVWF HIGH3 ; Shift HIGH2 to HIGH3
    MOVF HIGH1, W ; Move HIGH1 to W
    MOVWF HIGH2 ; Shift HIGH1 to HIGH2
    MOVF TEMP, W ; Restore the original value from TEMP
    MOVWF HIGH1 ; Update HIGH1
    RETURN

UpdateHigh2:
    MOVF HIGH3, W ; Move HIGH3 to W
    MOVWF HIGH4 ; Shift HIGH3 to HIGH4
    MOVF HIGH2, W ; Move HIGH2 to W
    MOVWF HIGH3 ; Shift HIGH2 to HIGH3
    MOVF TEMP, W ; Restore the original value from TEMP
    MOVWF HIGH2 ; Update HIGH2
    RETURN

UpdateHigh3:
    MOVF HIGH3, W ; Move HIGH3 to W
    MOVWF HIGH4 ; Shift HIGH3 to HIGH4
    MOVF TEMP, W ; Restore the original value from TEMP
    MOVWF HIGH3 ; Update HIGH3
    RETURN

;********

FINISHH:
    MOVFW HIGH1
    MOVFW HIGH2
    MOVFW HIGH3
    MOVFW HIGH4 


	return
	
	
SETVALUES:

MainLoop:
    ; Check the value of the counter and perform actions
    MOVF COUNTER, W ; Move COUNTER value to W

    ; Case 0
    SUBLW D'0'
    BTFSC STATUS, Z
   ; GOTO L1
    CALL Case0

    
L1:
    ; Case 1
    MOVF COUNTER, W
    SUBLW D'1'
    BTFSC STATUS, Z
  ;  GOTO L2
     CALL Case1


 L2:
    ; Case 2
    MOVF COUNTER, W
    SUBLW D'2'
    BTFSC STATUS, Z
    ;   GOTO L3
        CALL Case2

    
 L3:
    ; Case 3
    MOVF COUNTER, W
    SUBLW D'3'
    BTFSC STATUS, Z
  ;      GOTO L4
        CALL Case3


     L4:
    ; Case 4
    MOVF COUNTER, W
    SUBLW D'4'
    BTFSC STATUS, Z
     ;   GOTO L5
        CALL Case4

 L5:
    ; Case 5
    MOVF COUNTER, W
    SUBLW D'5'
    BTFSC STATUS, Z
     ;   GOTO L6
        CALL Case5


     L6:
    ; Case 6
    MOVF COUNTER, W
    SUBLW D'6'
    BTFSC STATUS, Z
      ;  GOTO L7
    CALL Case6


     L7:
    ; Case 7
    MOVF COUNTER, W
    SUBLW D'7'
    BTFSC STATUS, Z
      ;  GOTO L8
        CALL Case7


     L8:
    ; Case 8
    MOVF COUNTER, W
    SUBLW D'8'
    BTFSC STATUS, Z
   ;     GOTO L9
        CALL Case8


 L9:  
  ; Case 9
    MOVF COUNTER, W
    SUBLW D'9'
    BTFSC STATUS, Z
    ;    GOTO L10
        CALL Case9


     L10:
    ; Case 10
    MOVF COUNTER, W
    SUBLW D'10'
    BTFSC STATUS, Z
     ;   GOTO L11
        CALL Case10


     L11:
    ; Case 11
    MOVF COUNTER, W
    SUBLW D'11'
    BTFSC STATUS, Z
     ;   GOTO L12
        CALL Case11


     L12:
    ; Case 12
    MOVF COUNTER, W
    SUBLW D'12'
    BTFSC STATUS, Z
      ;  GOTO L13
        CALL Case12


     L13:
    ; Case 13
    MOVF COUNTER, W
    SUBLW D'13'
    BTFSC STATUS, Z
     ;   GOTO L14
        CALL Case13


     L14:
    ; Case 14
    MOVF COUNTER, W
    SUBLW D'14'
    BTFSC STATUS, Z
   ;     GOTO L15
        CALL Case14


     L15:
    ; Case 15
    MOVF COUNTER, W
    SUBLW D'15'
    BTFSC STATUS, Z
    ;    GOTO L16
        CALL Case15


     L16:
    ; Case 16
    MOVF COUNTER, W
    SUBLW D'16'
    BTFSC STATUS, Z
     ;   GOTO L17
    CALL Case16


     L17:
    ; Case 17
    MOVF COUNTER, W
    SUBLW D'17'
    BTFSC STATUS, Z
   ;     GOTO L18
    CALL Case17


     L18:
    ; Case 18
    MOVF COUNTER, W
    SUBLW D'18'
    BTFSC STATUS, Z
    ;    GOTO L19
    CALL Case18


     L19:
    ; Case 19
    MOVF COUNTER, W
    SUBLW D'19'
    BTFSC STATUS, Z
    ;    GOTO L20
    CALL Case19


     L20:
    ; Case 20
    MOVF COUNTER, W
    SUBLW D'20'
    BTFSC STATUS, Z
     ;   GOTO L21
    CALL Case20


     L21:
    ; Case 21
    MOVF COUNTER, W
    SUBLW D'21'
    BTFSC STATUS, Z
    ;    GOTO L22
    CALL Case21


     L22:
    ; Case 22
    MOVF COUNTER, W
    SUBLW D'22'
    BTFSC STATUS, Z
      ;  GOTO L23
    CALL Case22


     L23:
    ; Case 23
    MOVF COUNTER, W
    SUBLW D'23'
    BTFSC STATUS, Z
    ;GOTO L24
    CALL Case23
  ;  GOTO L24

L24:
    RETURN ; Continue the loop if no case matched

Case0:
    MOVF Result, W
    MOVWF VAL1
    MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case1:
    MOVF Result, W
    MOVWF VAL2
    MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case2:
    MOVF Result, W
    MOVWF VAL3
     MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case3:
    MOVF Result, W
    MOVWF VAL4
    MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case4:
    MOVF Result, W
    MOVWF VAL5
   MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case5:
    MOVF Result, W
    MOVWF VAL6
   MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case6:
    MOVF Result, W
    MOVWF VAL7
    MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case7:
    MOVF Result, W
    MOVWF VAL8
    MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case8:
    MOVF Result, W
    MOVWF VAL9
    MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case9:
    MOVF Result, W
    MOVWF VAL10
  MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case10:
    MOVF Result, W
    MOVWF VAL11
    MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case11:
    MOVF Result, W
    MOVWF VAL12
   MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case12:
    MOVF Result, W
    MOVWF VAL13
   MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case13:
    MOVF Result, W
    MOVWF VAL14
    MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case14:
    MOVF Result, W
    MOVWF VAL15
     MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case15:
    MOVF Result, W
    MOVWF VAL16
    MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case16:
    MOVF Result, W
    MOVWF VAL17
 MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case17:
    MOVF Result, W
    MOVWF VAL18
 MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case18:
    MOVF Result, W
    MOVWF VAL19
 MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case19:
    MOVF Result, W
    MOVWF VAL20
   MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case20:
    MOVF Result, W
    MOVWF VAL21
 MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case21:
    MOVF Result, W
    MOVWF VAL22
     MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case22:
    MOVF Result, W
    MOVWF VAL23
 MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER
    RETURN

Case23:
    MOVF Result, W
    MOVWF VAL24
   MOVF COUNTER,W
    ADDLW 1
    MOVWF COUNTER

    CALL findmaxandprint
    

    
    RETURN
   
findmaxandprint:

CALL FINDMAX4Dist
CALL print_lcd

GOTO step2

END
