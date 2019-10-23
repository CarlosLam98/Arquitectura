ADC EQU 0x20
FLG EQU 0X21
POB EQU 0X22
CON EQU 0X23

 org 0x00 ;Inicio del programa en la posici?n cero de memoria
 nop ;Libre (uso del debugger)

_inicio
	bcf STATUS,RP0 ;Ir banco 0
	bcf STATUS,RP1
	movlw b'01000001' ;A/D conversion Fosc/8
	movwf ADCON0
	;     	     7     6     5    4    3    2       1 0
	; 1Fh ADCON0 ADCS1 ADCS0 CHS2 CHS1 CHS0 GO/DONE ? ADON
	bsf STATUS,RP0 ;Ir banco 1
	bcf STATUS,RP1
	movlw b'00000001'
	movwf OPTION_REG ;TMR0 preescaler, 1:156
	;                7    6      5    4    3   2   1   0
	; 81h OPTION_REG RBPU INTEDG T0CS T0SE PSA PS2 PS1 PS0
	movlw b'00001110' ;A/D Port AN0/RA0
	movwf ADCON1
	;            7    6     5 4 3     2     1     0
	; 9Fh ADCON1 ADFM ADCS2 ? ? PCFG3 PCFG2 PCFG1 PCFG0
	bsf TRISA,0 ;RA0 linea de entrada para el ADC
	clrf TRISB
	clrf TRISD
	clrf TRISC
	bsf TRISA, 1
    	bcf STATUS,RP0 ;Ir banco 0
	bcf STATUS,RP1
	clrf PORTB ;Limpiar PORTB

_Recorrido
	BSF PORTD, 7
 	MOVLW 0X00
 	MOVWF PORTB 	
	call _delay
 	MOVLW 0X01
 	MOVWF PORTB
	call _delay
 	MOVLW 0X02
	MOVWF PORTB
	call _delay
	MOVLW 0X04
	MOVWF PORTB
	call _delay
	MOVLW 0X08
	MOVWF PORTB
	call _delay
	BCF PORTD, 7
	BSF PORTD, 6
	MOVLW 0X08
	MOVWF PORTB
	call _delay
	MOVLW 0X10
	MOVWF PORTB
	call _delay
	MOVLW 0X20
	MOVWF PORTB
	call _delay
	MOVLW 0X01
	MOVWF PORTB
	call _delay
	BCF PORTD, 6
	btfss PORTA, 1
	goto _Recorrido
	goto _bucle
_delay
	btfss INTCON,T0IF
	goto _delay;Esperar que el timer0 desborde
	bcf INTCON,T0IF ;Limpiar el indicador de desborde
	return
_bucle
	bsf ADCON0,GO ;Comenzar conversion A/D
_espera
	btfsc ADCON0,GO ;ADCON0 es 0? (la conversion esta completa?)
	goto _espera ;No, ir _espera
	movfw CON
	movwf PORTC
	movf ADRESH,W ;Si, W=ADRESH
	; 1Eh ADRESH A/D Result Register High Byte
	; 9Eh ADRESL A/D Result Register Low Byte
	movwf ADC ;ADC=W
	rrf ADC,F ;ADC /4
	rrf ADC,F
	bcf ADC,7
	bcf ADC,6
	movfw ADC ;W = ADC
	call _tablas
	movwf PORTB ;PORTB = W

	movwf POB
	sublw 0x38			;L
	btfsc status, 2
	goto _esL
	movfw POB
	sublw 0x76
	btfsc status, 2
	goto _esH
	goto _esOtro

_esL
	bcf PORTD, 6
	bsf PORTD, 7
	movlw 0x01
	movwf FLG
	goto _bucle
_esH
	bcf PORTD, 7
	bsf PORTD, 6
	movfw FLG
	sublw 0x01
	btfsc status, 2
	goto _auxi
	goto _bucle

_auxi
	movlw 0x02
	movwf FLG
	bsf PORTD, 0
	incf CON,1
	goto _bucle
_esOtro
	movfw FLG
	sublw 0x02
	btfsc status, 2	
	goto _apagar
	goto _bucle
_apagar
	movlw 0x00
	movwf FLG
	bcf PORTD, 0
	goto _bucle

_tablas
	ADDWF PCL, 1
	RETLW b'00000000'			;0
	RETLW b'00000000'			;1
	RETLW b'00000000'			;2
	RETLW b'00000000'			;3
	RETLW b'00000000'			;4
	RETLW b'00000000'			;5
	RETLW b'00000000'			;6
	RETLW b'00000000'			;7
	RETLW b'00000000'			;8
	RETLW b'00000000'			;9
	RETLW b'00000000'			;A
	RETLW b'00000000'			;B
	RETLW b'00000000'			;C
	RETLW b'00000000'			;D
	RETLW b'00000000'			;E
	RETLW b'00000000'			;F
	RETLW b'00111000'			;L
	RETLW b'00000110'			;1
	RETLW b'01011011'			;2
	RETLW b'01001111'			;3
	RETLW b'01100110'			;4
	RETLW b'01101101'			;5
	RETLW b'01111101'			;6
	RETLW b'00000111'			;7
	RETLW b'01111111'			;8
	RETLW b'01110110'			;H
	RETLW b'00000000'			;A
	RETLW b'00000000'			;B
	RETLW b'00000000'			;C
	RETLW b'00000000'			;D
	RETLW b'00000000'			;E
	RETLW b'00000000'			;F
	RETLW b'00000000'			;0
	RETLW b'00000000'			;1
	RETLW b'00000000'			;2
	RETLW b'00000000'			;3
	RETLW b'00000000'			;4
	RETLW b'00000000'			;5
	RETLW b'00000000'			;6
	RETLW b'00000000'			;7
	RETLW b'00000000'			;8
	RETLW b'00000000'			;9
	RETLW b'00000000'			;A
	RETLW b'00000000'			;B
	RETLW b'00000000'			;C
	RETLW b'00000000'			;D
	RETLW b'00000000'			;E
	RETLW b'00000000'			;F
	RETLW b'00000000'			;0
	RETLW b'00000000'			;1
	RETLW b'00000000'			;2
	RETLW b'00000000'			;3
	RETLW b'00000000'			;4
	RETLW b'00000000'			;5
	RETLW b'00000000'			;6
	RETLW b'00000000'			;7
	RETLW b'00000000'			;8
	RETLW b'00000000'			;9
	RETLW b'00000000'			;A
	RETLW b'00000000'			;B
	RETLW b'00000000'			;C
	RETLW b'00000000'			;D
	RETLW b'00000000'			;E
	RETLW b'00000000'			;F
end