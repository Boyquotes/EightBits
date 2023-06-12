; don't change this stuff as the unit test cases for the symbol parser rely on this stuff staying the same

	processor 6502
	
	; Some zero page data	
	org $0080

ZP_ZERO
	.byte $00
ZP_ONE
	.byte $01
ZP_TWO
	.byte $02

ZP_D0
	.word DATA_ZERO
ZP_D1
	.word DATA_ONE
ZP_D2
	.word DATA_TWO
ZP_D3
	.word DATA_THREE
ZP_DP
	.word PAGE_NEXT_ROOT

; Some non zero page data
	org $400

DATA_ZERO
	.byte $00
DATA_ONE
	.byte $01
DATA_TWO
	.byte $02
DATA_THREE
	.byte $03
	.byte $04

	org $5c0
PAGE_NEXT_ROOT
	.byte $00
	org $610
PAGE_NEXT
	.byte $24

; Some code
	org $1000


Code_start
			brk
