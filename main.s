;*******************************************************************************
; Universidad del Valle de Guatemala	
; IE2023 Programación de microcontroladores
; Autor: Michelle Serrano 
; Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
; Proyecto: Ejemplo
; Hardware: PIC16F887 
; Creado: 25/07/2022
; Última modificación: 25/07/2022
;*******************************************************************************
PROCESSOR 16F887
#include <xc.inc> 
;*******************************************************************************
; Palabra configuración
;*******************************************************************************
; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT 
  CONFIG  WDTE = OFF            
  CONFIG  PWRTE = ON           
  CONFIG  MCLRE = OFF           
  CONFIG  CP = OFF              
  CONFIG  CPD = OFF             
  CONFIG  BOREN = OFF           
  CONFIG  IESO = OFF            
  CONFIG  FCMEN = OFF           
  CONFIG  LVP = OFF             

; CONFIG2
  CONFIG  BOR4V = BOR40V        
  CONFIG  WRT = OFF    
;*******************************************************************************
; Variables
;******************************************************************************* 
PSECT udata_shr
   cont1:
    DS 1 ; 1 BYTE, 4 bits
;*******************************************************************************
; Vector Reset 
;*******************************************************************************     
PSECT CODE, delta=2, abs
 ORG 0x0000
    goto MAIN
;*******************************************************************************
; Código Pricipal
;*******************************************************************************       
PSECT CODE, delta=2, abs
 ORG 0x0100
MAIN:
    call Reloj
    call PYE
    banksel PORTA
    banksel PORTB 
    banksel PORTC
    banksel PORTD
    
Loop:
    btfsc PORTA, 0     ;si PORTA está en 0=skip sino llama la función
    call incrementar1
    
    btfsc PORTA, 1     ;si PORTA está en 0=skip sino llama la función
    call decrementar1
    
    btfsc PORTA, 2   ;si PORTA está en 0=skip sino llama la función
    call incrementar2
    
    btfsc PORTA, 3     ;si PORTA está en 0=skip sino llama la función
    call decrementar2
    
    btfsc PORTA, 4     ;si PORTA está en 0=skip sino llama la función
    call overflow
    
    
    goto Loop
;*******************************************************************************
; Funciones
;******************************************************************************* 
Reloj: 
;oscilador a 1Mhz
    banksel OSCCON
    bsf	OSCCON, 6
    bcf OSCCON, 5
    bcf OSCCON, 4
    bsf OSCCON, 2
    bsf OSCCON, 0
    
    RETURN
    
PYE:
    banksel ANSEL
    banksel ANSELH
    clrf ANSEL
    clrf ANSELH   ;Puertos digitales
    
    banksel TRISB ;CONTADOR AUMENTO
    banksel TRISC ;CONTADOR DECREMENTO
    banksel TRISD ;OVERFLOW
    
    bsf TRISA, 0  ;RA0 como input
    bsf TRISA, 1  ;RA1 como input
    bsf TRISA, 2  ;RA2 como input
    bsf TRISA, 3  ;RA3 como input
    bsf TRISA, 4  ;RA4 como input
    
    clrf TRISB    ;PORTB como output, limpiando el registro TRISB
    clrf TRISC    ;PORTC como output, limpiando el registro TRISC
    clrf TRISD    ;PORTD como output, limpiando el registro TRISC

    RETURN 
    
antirebote:
    movlw   150
    movwf   cont1
    decfsz  cont1, 1
    goto $-1
    
    RETURN

incrementar1:
    call antirebote 
    
    btfsc PORTA, 0   ;se repite hasta que se presione, hasta que sea 1
    goto $-1         ;mientras no esté presionad,regresa
    incf PORTB       ;si se presiona, incrementa
    
    btfsc   PORTB,4	; reiniciar si se alcanzaron los 4 bits
    clrf    PORTB
    
    RETURN

 decrementar1:
    call antirebote 
    
    btfsc PORTA, 1   ;se repite hasta que se presione, hasta que sea 1
    goto $-1         ;mientras no esté presionad,regresa
    decf PORTB       ;quitar 1
    
    btfsc   PORTB,4	; reiniciar si se alcanzaron los 4 bits
    call ClearPORTB
    
    RETURN
    
incrementar2:
    call antirebote 
    
    btfsc PORTA, 2   ;se repite hasta que se presione, hasta que sea 1
    goto $-1         ;mientras no esté presionad,regresa
    incf PORTC       ;si se presiona, incrementa
    
    btfsc   PORTC, 4;reiniciar si se alcanzaron los 4 bits
    clrf    PORTC
    
    RETURN

 decrementar2:
    call antirebote 
    
    btfsc PORTA, 3   ;se repite hasta que se presione, hasta que sea 1
    goto $-1         ;mientras no esté presionad,regresa
    decf PORTC       ;quitar 1
    
    btfsc   PORTC, 4; reiniciar si se alcanzaron los 4 bits
    call ClearPORTC
    
    RETURN
    
ClearPORTB:
    clrf    PORTB     ; lo limpiamos
    bsf	    PORTB, 0  ; encendemos el resto cuando el contador llegue a 0
    bsf	    PORTB, 1
    bsf	    PORTB, 2
    bsf	    PORTB, 3
    
    RETURN
    
ClearPORTC:
    clrf    PORTC    ; lo limpiamos
    bsf	    PORTC, 0  ; encendemos el resto cuando el contador llegue a 0
    bsf	    PORTC, 1
    bsf	    PORTC, 2
    bsf	    PORTC, 3
    
    RETURN
   
overflow:
    call antirebote 
    clrf    PORTD	;Limpiamos PORTD
    
    btfsc   PORTA, 4
    goto    $-1
    
    movf    PORTB, w	;Cargamos a w PORTB
    addwf   PORTC, w	;Cargamos a w PORTC y lo sumamos
    movwf   PORTD	;La suma en w a PORTD
    
    RETURN
    
END

