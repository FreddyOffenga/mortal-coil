; Mortal Coil, for Outline 2k17, 128 bytes compo
; Kind of rotating starfield using one missile and DMA off!

; Credits to 'White Flame' for describing sine wave generation, found here:
; http://codebase64.org/doku.php?id=base:generating_approximate_sines_in_assembly

; F#READY, May 2017

; 121 bytes, saved a few bytes
; 124 bytes, added awesome sound :)
; 127 bytes, added sine/2 to coil to have a sine coil
; 128 bytes, saved 5 bytes, but included run adres (6 bytes)
; 123 bytes, program located at zp $80
; 125 bytes, fix to be NTSC compatible

; GTIA
HPOSM0      = $d004
GRAFM		= $d011
COLPM0		= $d012
GRACTL   	= $d01d

; POKEY
RANDOM		= $d20a

; ANTIC
WSYNC		= $d40a
VCOUNT		= $d40b

positions	= $3000
colors		= $3100
sinewave	= $3200

temp		= 18

			org $0080

mortalcoil
			ldy #$3f
 			ldx #0
			stx 559

makesine
value_lo
			lda #0
  			clc
delta_lo
  			adc #0
  			sta value_lo+1
value_hi
  			lda #0
delta_hi
  			adc #0
  			sta value_hi+1
 
  			sta sinewave+$c0,x
  			sta sinewave+$80,y
  			eor #$7f
  			sta sinewave+$40,x
  			sta sinewave+$00,y
 
  			lda delta_lo+1
  			adc #8
  			sta delta_lo+1
  			bcc nothi
   			inc delta_hi+1
nothi
			; Loop
  			inx
  			dey
 			bpl makesine
  
; !!! y = 255
;			lda #3
;			sta GRACTL
			sty GRACTL

; color starfield

fillrnd
			lda RANDOM
			sta positions,y
			sta colors,y
			dey
			bne fillrnd
						
;			lda #0
;			sta GRAFM
loop
			lda VCOUNT
			bne loop

; !!! y = 0

			ldx 20
			ldy #254
putmsl
			lda positions,x
			inc positions,x
			stx temp
			tax
			lda sinewave,x
;			clc
			ldx temp
			adc sinewave,x
			lsr
			adc #$40
			sta WSYNC
			sta HPOSM0
			sta $d201	; it even has sound! :)
			lda colors,x
			sta COLPM0
			inx
			dey
			bne putmsl
			beq loop

			run mortalcoil