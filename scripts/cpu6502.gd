extends Node

var reg_acc: int
var reg_x: int
var reg_y: int
var reg_sp: int
var reg_pc: int
var reg_status: int

# Status register flag values
const flag_negative = 128
const flag_overflow = 64
const flag_break = 16
const flag_decimal = 8
const flag_interrupt = 4
const flag_zero = 2
const flag_carry =1

var prev_clock: bool
var current_opcode: int

class Instruction:
	@export var mnemonic: Mnemonic
	@export var addressingMode: AddressingMode
	var cycles: int
	var opcode: int

enum Mnemonic { LDA, LDX, LDY, 
				STA, STX, STY,
				TAX, TAY, TXA, TYA, TSX, TXS,
				PHA, PHP, PLA, PLP,
				AND, EOR, ORA, BIT,
				ADC, SBC, CMP, CPX, CPY,
				INC, INX, INY, DEC, DEX, DEY, 
				ASL, LSR, ROL, ROR,
				JMP, JSR, RTS, 
				BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS,
				CLC, CLD, CLI, CLV, SEC, SED, SEI,
				BRK, NOP, RTI }

enum AddressingMode { IMP, ACC, IMM, ZP, ZPX, ZPY, REL, ABS, ABSX, ABSY, IND, IDXINDX, INDIDXY }

var instruction_set = []

var mnemonic_name: Dictionary = {
	Mnemonic.LDA: "LDA",
	Mnemonic.LDX: "LDX",
	Mnemonic.LDY: "LDY",
	Mnemonic.STA: "STA",
	Mnemonic.STX: "STX",
	Mnemonic.STY: "STY",
	Mnemonic.TAX: "TAX",
	Mnemonic.TAY: "TAY",
	Mnemonic.TXA: "TXA",
	Mnemonic.TYA: "TYA",
	Mnemonic.TSX: "TSX",
	Mnemonic.TXS: "TXS",
	Mnemonic.PHA: "PHA",
	Mnemonic.PHP: "PHP",
	Mnemonic.PLA: "PLA",
	Mnemonic.PLP: "PLP",
	Mnemonic.AND: "AND",
	Mnemonic.EOR: "EOR",
	Mnemonic.ORA: "ORA",
	Mnemonic.BIT: "BIT",
	Mnemonic.ADC: "ADC",
	Mnemonic.SBC: "SBC",
	Mnemonic.CMP: "CMP",
	Mnemonic.CPX: "CPX",
	Mnemonic.CPY: "CPY",
	Mnemonic.INC: "INC",
	Mnemonic.INX: "INX",
	Mnemonic.INY: "INY",
	Mnemonic.DEC: "DEC",
	Mnemonic.DEX: "DEX",
	Mnemonic.DEY: "DEY",
	Mnemonic.ASL: "ASL",
	Mnemonic.LSR: "LSR",
	Mnemonic.ROL: "ROL",
	Mnemonic.ROR: "ROR",
	Mnemonic.JMP: "JMP",
	Mnemonic.JSR: "JSR",
	Mnemonic.RTS: "RTS",
	Mnemonic.BCC: "BCC",
	Mnemonic.BCS: "BCS",
	Mnemonic.BEQ: "BEQ",
	Mnemonic.BMI: "BMI",
	Mnemonic.BNE: "BNE",
	Mnemonic.BPL: "BPL",
	Mnemonic.BVC: "BVC",
	Mnemonic.BVS: "BVS",
	Mnemonic.CLC: "CLC",
	Mnemonic.CLD: "CLD",
	Mnemonic.CLI: "CLI",
	Mnemonic.CLV: "CLV",
	Mnemonic.SEC: "SEC",
	Mnemonic.SED: "SED",
	Mnemonic.SEI: "SEI",
	Mnemonic.BRK: "BRK",
	Mnemonic.NOP: "NOP",
	Mnemonic.RTI: "RTI"
}
var mnemonic_handlers: Dictionary = {
	Mnemonic.LDA: mnemonic_LDA,
	Mnemonic.LDX: mnemonic_LDX,
	Mnemonic.LDY: mnemonic_UNKNOWN,
	Mnemonic.STA: mnemonic_UNKNOWN,
	Mnemonic.STX: mnemonic_UNKNOWN,
	Mnemonic.STY: mnemonic_UNKNOWN,
	Mnemonic.TAX: mnemonic_UNKNOWN,
	Mnemonic.TAY: mnemonic_UNKNOWN,
	Mnemonic.TXA: mnemonic_UNKNOWN,
	Mnemonic.TYA: mnemonic_UNKNOWN,
	Mnemonic.TSX: mnemonic_UNKNOWN,
	Mnemonic.TXS: mnemonic_TXS,
	Mnemonic.PHA: mnemonic_UNKNOWN,
	Mnemonic.PHP: mnemonic_UNKNOWN,
	Mnemonic.PLA: mnemonic_UNKNOWN,
	Mnemonic.PLP: mnemonic_UNKNOWN,
	Mnemonic.AND: mnemonic_UNKNOWN,
	Mnemonic.EOR: mnemonic_UNKNOWN,
	Mnemonic.ORA: mnemonic_UNKNOWN,
	Mnemonic.BIT: mnemonic_UNKNOWN,
	Mnemonic.ADC: mnemonic_UNKNOWN,
	Mnemonic.SBC: mnemonic_UNKNOWN,
	Mnemonic.CMP: mnemonic_UNKNOWN,
	Mnemonic.CPX: mnemonic_UNKNOWN,
	Mnemonic.CPY: mnemonic_UNKNOWN,
	Mnemonic.INC: mnemonic_UNKNOWN,
	Mnemonic.INX: mnemonic_INX,
	Mnemonic.INY: mnemonic_UNKNOWN,
	Mnemonic.DEC: mnemonic_UNKNOWN,
	Mnemonic.DEX: mnemonic_UNKNOWN,
	Mnemonic.DEY: mnemonic_UNKNOWN,
	Mnemonic.ASL: mnemonic_UNKNOWN,
	Mnemonic.LSR: mnemonic_UNKNOWN,
	Mnemonic.ROL: mnemonic_UNKNOWN,
	Mnemonic.ROR: mnemonic_UNKNOWN,
	Mnemonic.JMP: mnemonic_UNKNOWN,
	Mnemonic.JSR: mnemonic_JSR,
	Mnemonic.RTS: mnemonic_UNKNOWN,
	Mnemonic.BCC: mnemonic_UNKNOWN,
	Mnemonic.BCS: mnemonic_UNKNOWN,
	Mnemonic.BEQ: mnemonic_UNKNOWN,
	Mnemonic.BMI: mnemonic_UNKNOWN,
	Mnemonic.BNE: mnemonic_UNKNOWN,
	Mnemonic.BPL: mnemonic_UNKNOWN,
	Mnemonic.BVC: mnemonic_UNKNOWN,
	Mnemonic.BVS: mnemonic_UNKNOWN,
	Mnemonic.CLC: mnemonic_UNKNOWN,
	Mnemonic.CLD: mnemonic_CLD,
	Mnemonic.CLI: mnemonic_UNKNOWN,
	Mnemonic.CLV: mnemonic_UNKNOWN,
	Mnemonic.SEC: mnemonic_UNKNOWN,
	Mnemonic.SED: mnemonic_UNKNOWN,
	Mnemonic.SEI: mnemonic_SEI,
	Mnemonic.BRK: mnemonic_UNKNOWN,
	Mnemonic.NOP: mnemonic_UNKNOWN,
	Mnemonic.RTI: mnemonic_UNKNOWN
}
var addressing_mode_name: Dictionary = {
	AddressingMode.IMP: "Implicit",
	AddressingMode.ACC: "Accumulator",
	AddressingMode.IMM: "Immediate",
	AddressingMode.ZP: "Zero Page",
	AddressingMode.ZPX: "Zero Page, X",
	AddressingMode.ZPY: "Zero Page, Y",
	AddressingMode.REL: "Relative",
	AddressingMode.ABS: "Absolute",
	AddressingMode.ABSX: "Absolute, X",
	AddressingMode.ABSY: "Absolute, Y",
	AddressingMode.IND: "Indirect",
	AddressingMode.IDXINDX: "Indexed Indirect",
	AddressingMode.INDIDXY: "Indirect Indexed"
}
var addressing_mode_size: Dictionary = {
	AddressingMode.IMP: 1,
	AddressingMode.ACC: 1,
	AddressingMode.IMM: 2,
	AddressingMode.ZP: 2,
	AddressingMode.ZPX: 2,
	AddressingMode.ZPY: 2,
	AddressingMode.REL: 2,
	AddressingMode.ABS: 3,
	AddressingMode.ABSX: 3,
	AddressingMode.ABSY: 3,
	AddressingMode.IND: 3,
	AddressingMode.IDXINDX: 2,
	AddressingMode.INDIDXY: 2	
}
var addressing_mode_handlers: Dictionary = {
	AddressingMode.IMP: addrmode_IMP,
	AddressingMode.ACC: addrmode_ACC,
	AddressingMode.IMM: addrmode_IMM,
	AddressingMode.ZP: addrmode_ZP,
	AddressingMode.ZPX: addrmode_ZPX,
	AddressingMode.ZPY: addrmode_ZPY,
	AddressingMode.REL: addrmode_REL,
	AddressingMode.ABS: addrmode_ABS,
	AddressingMode.ABSX: addrmode_ABSX,
	AddressingMode.ABSY: addrmode_ABSY,
	AddressingMode.IND: addrmode_IND,
	AddressingMode.IDXINDX: addrmode_IDXINDX,
	AddressingMode.INDIDXY: addrmode_INDIDXY,
}
# Make this external at some point
var memory: PackedByteArray

# add a hardware API ? maybe later

func _ready():
	# power-on logic here
	reg_acc = 0
	reg_x = 0
	reg_y = 0
	reg_sp = 0
	reg_pc = 0
	reg_status = 0
	prev_clock = false
	current_opcode = 0
	
	instruction_set.resize(256)
	memory.resize(65536)
	
	add_instructions()
	load_rom()

func load_rom():
	var file = FileAccess.open("res://roms/combat.bin", FileAccess.READ)
	var content = file.get_buffer(file.get_length())
	for i in range(0, 2048):
		memory[i + 0xf000] = content[i]
		memory[i + 0xf800] = content[i]
	var reset = memory[0xfffc] + (memory[0xfffd] << 8)
	reg_pc = reset

func add_instructions():
	# ADC
	add_instruction(Mnemonic.ADC, AddressingMode.IMM, 0x69, 2)
	add_instruction(Mnemonic.ADC, AddressingMode.ZP, 0x65, 3)
	add_instruction(Mnemonic.ADC, AddressingMode.ZPX, 0x75, 4)
	add_instruction(Mnemonic.ADC, AddressingMode.ABS, 0x6d, 4)
	add_instruction(Mnemonic.ADC, AddressingMode.ABSX, 0x7d, 4)
	add_instruction(Mnemonic.ADC, AddressingMode.ABSY, 0x79, 4)
	add_instruction(Mnemonic.ADC, AddressingMode.IDXINDX, 0x61, 6)
	add_instruction(Mnemonic.ADC, AddressingMode.INDIDXY, 0x71, 5)
	# AND
	add_instruction(Mnemonic.AND, AddressingMode.IMM, 0x29, 2)
	add_instruction(Mnemonic.AND, AddressingMode.ZP, 0x25, 3)
	add_instruction(Mnemonic.AND, AddressingMode.ZPX, 0x35, 4)
	add_instruction(Mnemonic.AND, AddressingMode.ABS, 0x2d, 4)
	add_instruction(Mnemonic.AND, AddressingMode.ABSX, 0x3d, 4)
	add_instruction(Mnemonic.AND, AddressingMode.ABSY, 0x39, 4)
	add_instruction(Mnemonic.AND, AddressingMode.IDXINDX, 0x21, 6)
	add_instruction(Mnemonic.AND, AddressingMode.INDIDXY, 0x31, 5)
	# ASL
	add_instruction(Mnemonic.ASL, AddressingMode.ACC, 0x0a, 2)
	add_instruction(Mnemonic.ASL, AddressingMode.ZP, 0x06, 5)
	add_instruction(Mnemonic.ASL, AddressingMode.ZPX, 0x16, 6)
	add_instruction(Mnemonic.ASL, AddressingMode.ABS, 0x0e, 6)
	add_instruction(Mnemonic.ASL, AddressingMode.ABSX, 0x1e, 7)
	# BCC
	add_instruction(Mnemonic.BCC, AddressingMode.REL, 0x90, 2)
	# BCS
	add_instruction(Mnemonic.BCS, AddressingMode.REL, 0xb0, 2)
	# BEQ
	add_instruction(Mnemonic.BEQ, AddressingMode.REL, 0xf0, 2)
	# BIT
	add_instruction(Mnemonic.BIT, AddressingMode.ZP, 0x24, 3)
	add_instruction(Mnemonic.BIT, AddressingMode.ABS, 0x2c, 4)
	# BMI
	add_instruction(Mnemonic.BMI, AddressingMode.REL, 0x30, 2)
	# BNE
	add_instruction(Mnemonic.BNE, AddressingMode.REL, 0xd0, 2)
	# BPL
	add_instruction(Mnemonic.BPL, AddressingMode.REL, 0x10, 2)
	# BRK
	add_instruction(Mnemonic.BRK, AddressingMode.IMP, 0x00, 7)
	# BVC
	add_instruction(Mnemonic.BVC, AddressingMode.REL, 0x50, 2)
	# BVS
	add_instruction(Mnemonic.BVS, AddressingMode.REL, 0x70, 2)
	# CLC
	add_instruction(Mnemonic.CLC, AddressingMode.IMP, 0x18, 2)
	# CLD
	add_instruction(Mnemonic.CLD, AddressingMode.IMP, 0xd8, 2)
	# CLI
	add_instruction(Mnemonic.CLI, AddressingMode.IMP, 0x58, 2)
	# CLV
	add_instruction(Mnemonic.CLV, AddressingMode.IMP, 0xb8, 2)
	# CMP
	add_instruction(Mnemonic.CMP, AddressingMode.IMM, 0xc9, 2)
	add_instruction(Mnemonic.CMP, AddressingMode.ZP, 0xc5, 3)
	add_instruction(Mnemonic.CMP, AddressingMode.ZPX, 0xd5, 4)
	add_instruction(Mnemonic.CMP, AddressingMode.ABS, 0xcd, 4)
	add_instruction(Mnemonic.CMP, AddressingMode.ABSX, 0xdd, 4)
	add_instruction(Mnemonic.CMP, AddressingMode.ABSY, 0xd9, 4)
	add_instruction(Mnemonic.CMP, AddressingMode.IDXINDX, 0xc1, 6)
	add_instruction(Mnemonic.CMP, AddressingMode.INDIDXY, 0xd1, 5)
	# CPX
	add_instruction(Mnemonic.CPX, AddressingMode.IMM, 0xe0, 2)
	add_instruction(Mnemonic.CPX, AddressingMode.ZP, 0xe4, 3)
	add_instruction(Mnemonic.CPX, AddressingMode.ABS, 0xec, 4)
	# CPY
	add_instruction(Mnemonic.CPY, AddressingMode.IMM, 0xc0, 2)
	add_instruction(Mnemonic.CPY, AddressingMode.ZP, 0xc4, 3)
	add_instruction(Mnemonic.CPY, AddressingMode.ABS, 0xcc, 3)
	# DEC
	add_instruction(Mnemonic.DEC, AddressingMode.ZP, 0xc6, 5)
	add_instruction(Mnemonic.DEC, AddressingMode.ZPX, 0xd6, 6)
	add_instruction(Mnemonic.DEC, AddressingMode.ABS, 0xce, 6)
	add_instruction(Mnemonic.DEC, AddressingMode.ABSX, 0xde, 7)
	# DEY
	add_instruction(Mnemonic.DEY, AddressingMode.IMP, 0x88, 2)
	# EOR
	add_instruction(Mnemonic.EOR, AddressingMode.IMM, 0x49, 2)
	add_instruction(Mnemonic.EOR, AddressingMode.ZP, 0x45, 3)
	add_instruction(Mnemonic.EOR, AddressingMode.ZPX, 0x55, 4)
	add_instruction(Mnemonic.EOR, AddressingMode.ABS, 0x4d, 4)
	add_instruction(Mnemonic.EOR, AddressingMode.ABSX, 0x5d, 4)
	add_instruction(Mnemonic.EOR, AddressingMode.ABSY, 0x59, 4)
	add_instruction(Mnemonic.EOR, AddressingMode.IDXINDX, 0x41, 6)
	add_instruction(Mnemonic.EOR, AddressingMode.INDIDXY, 0x51, 5)
	# INC
	add_instruction(Mnemonic.INC, AddressingMode.ZP, 0xe6, 5)
	add_instruction(Mnemonic.INC, AddressingMode.ZPX, 0xf6, 6)
	add_instruction(Mnemonic.INC, AddressingMode.ABS, 0xee, 6)
	add_instruction(Mnemonic.INC, AddressingMode.ABSX, 0xfe, 7)
	# INX
	add_instruction(Mnemonic.INX, AddressingMode.IMP, 0xe8, 2)
	# INY
	add_instruction(Mnemonic.INY, AddressingMode.IMP, 0xc8, 2)
	# JMP
	add_instruction(Mnemonic.JMP, AddressingMode.ABS, 0x4c, 3)
	add_instruction(Mnemonic.JMP, AddressingMode.IND, 0x6c, 5)
	# JSR
	add_instruction(Mnemonic.JSR, AddressingMode.ABS, 0x20, 6)
	# LDA
	add_instruction(Mnemonic.LDA, AddressingMode.IMM, 0xa9, 2)
	add_instruction(Mnemonic.LDA, AddressingMode.ZP, 0xa5, 3)
	add_instruction(Mnemonic.LDA, AddressingMode.ZPX, 0xb5, 4)
	add_instruction(Mnemonic.LDA, AddressingMode.ABS, 0xad, 4)
	add_instruction(Mnemonic.LDA, AddressingMode.ABSX, 0xbd, 4)
	add_instruction(Mnemonic.LDA, AddressingMode.ABSY, 0xb9, 4)
	add_instruction(Mnemonic.LDA, AddressingMode.IDXINDX, 0xa1, 6)
	add_instruction(Mnemonic.LDA, AddressingMode.INDIDXY, 0xb1, 5)
	# LDX
	add_instruction(Mnemonic.LDX, AddressingMode.IMM, 0xa2, 2)
	add_instruction(Mnemonic.LDX, AddressingMode.ZP, 0xa6, 3)
	add_instruction(Mnemonic.LDX, AddressingMode.ZPY, 0xb6, 4)
	add_instruction(Mnemonic.LDX, AddressingMode.ABS, 0xae, 4)
	add_instruction(Mnemonic.LDX, AddressingMode.ABSY, 0xbe, 4)
	# LDY
	add_instruction(Mnemonic.LDY, AddressingMode.IMM, 0xa0, 2)
	add_instruction(Mnemonic.LDY, AddressingMode.ZP, 0xa4, 3)
	add_instruction(Mnemonic.LDY, AddressingMode.ZPX, 0xb4, 4)
	add_instruction(Mnemonic.LDY, AddressingMode.ABS, 0xac, 4)
	add_instruction(Mnemonic.LDY, AddressingMode.ABSX, 0xbc, 4)
	# LSR
	add_instruction(Mnemonic.LSR, AddressingMode.ACC, 0x4a, 2)
	add_instruction(Mnemonic.LSR, AddressingMode.ZP, 0x46, 5)
	add_instruction(Mnemonic.LSR, AddressingMode.ZPX, 0x56, 6)
	add_instruction(Mnemonic.LSR, AddressingMode.ABS, 0x4e, 6)
	add_instruction(Mnemonic.LSR, AddressingMode.ABSX, 0x5e, 7)
	# NOP
	add_instruction(Mnemonic.NOP, AddressingMode.IMP, 0xea, 2)
	# ORA
	add_instruction(Mnemonic.ORA, AddressingMode.IMM, 0x09, 2)
	add_instruction(Mnemonic.ORA, AddressingMode.ZP, 0x05, 3)
	add_instruction(Mnemonic.ORA, AddressingMode.ZPX, 0x15, 4)
	add_instruction(Mnemonic.ORA, AddressingMode.ABS, 0x0d, 4)
	add_instruction(Mnemonic.ORA, AddressingMode.ABSX, 0x1d, 4)
	add_instruction(Mnemonic.ORA, AddressingMode.ABSY, 0x19, 4)
	add_instruction(Mnemonic.ORA, AddressingMode.IDXINDX, 0x01, 6)
	add_instruction(Mnemonic.ORA, AddressingMode.INDIDXY, 0x11, 5)
	#PHA
	add_instruction(Mnemonic.PHA, AddressingMode.IMP, 0x48, 3)
	# PHP
	add_instruction(Mnemonic.PHP, AddressingMode.IMP, 0x08, 3)
	# PLA
	add_instruction(Mnemonic.PLA, AddressingMode.IMP, 0x68, 4)
	# PLP
	add_instruction(Mnemonic.PLP, AddressingMode.IMP, 0x28, 4)
	# ROL
	add_instruction(Mnemonic.ROL, AddressingMode.ACC, 0x2a, 2)
	add_instruction(Mnemonic.ROL, AddressingMode.ZP, 0x26, 5)
	add_instruction(Mnemonic.ROL, AddressingMode.ZPX, 0x36, 6)
	add_instruction(Mnemonic.ROL, AddressingMode.ABS, 0x2e, 6)
	add_instruction(Mnemonic.ROL, AddressingMode.ABSX, 0x3e, 7)
	# ROR
	add_instruction(Mnemonic.ROR, AddressingMode.ACC, 0x6a, 2)
	add_instruction(Mnemonic.ROR, AddressingMode.ZP, 0x66, 5)
	add_instruction(Mnemonic.ROR, AddressingMode.ZPX, 0x76, 6)
	add_instruction(Mnemonic.ROR, AddressingMode.ABS, 0x6e, 6)
	add_instruction(Mnemonic.ROR, AddressingMode.ABSX, 0x7e, 7)
	# RTI
	add_instruction(Mnemonic.RTI, AddressingMode.IMP, 0x40, 6)
	# RTS
	add_instruction(Mnemonic.RTS, AddressingMode.IMP, 0x60, 6)
	# SBC
	add_instruction(Mnemonic.SBC, AddressingMode.IMM, 0xe9, 2)
	add_instruction(Mnemonic.SBC, AddressingMode.ZP, 0xe5, 3)
	add_instruction(Mnemonic.SBC, AddressingMode.ZPX, 0xf5, 4)
	add_instruction(Mnemonic.SBC, AddressingMode.ABS, 0xed, 4)
	add_instruction(Mnemonic.SBC, AddressingMode.ABSX, 0xfd, 4)
	add_instruction(Mnemonic.SBC, AddressingMode.ABSY, 0xf9, 4)
	add_instruction(Mnemonic.SBC, AddressingMode.IDXINDX, 0xe1, 6)
	add_instruction(Mnemonic.SBC, AddressingMode.INDIDXY, 0xf1, 5)
	# SEC
	add_instruction(Mnemonic.SEC, AddressingMode.IMP, 0x38, 2)
	# SED
	add_instruction(Mnemonic.SED, AddressingMode.IMP, 0xf8, 2)
	# SEI
	add_instruction(Mnemonic.SEI, AddressingMode.IMP, 0x78, 2)
	# STA
	add_instruction(Mnemonic.STA, AddressingMode.ZP, 0x85, 3)
	add_instruction(Mnemonic.STA, AddressingMode.ZPX, 0x95, 4)
	add_instruction(Mnemonic.STA, AddressingMode.ABS, 0x8d, 4)
	add_instruction(Mnemonic.STA, AddressingMode.ABSX, 0x9d, 5)
	add_instruction(Mnemonic.STA, AddressingMode.ABSY, 0x99, 5)
	add_instruction(Mnemonic.STA, AddressingMode.IDXINDX, 0x81, 6)
	add_instruction(Mnemonic.STA, AddressingMode.INDIDXY, 0x91, 6)
	# STX
	add_instruction(Mnemonic.STX, AddressingMode.ZP, 0x86, 3)
	add_instruction(Mnemonic.STX, AddressingMode.ZPY, 0x96, 4)
	add_instruction(Mnemonic.STX, AddressingMode.ABS, 0x8e, 4)
	# STY
	add_instruction(Mnemonic.STY, AddressingMode.ZP, 0x84, 3)
	add_instruction(Mnemonic.STY, AddressingMode.ZPX, 0x94, 4)
	add_instruction(Mnemonic.STY, AddressingMode.ABS, 0x8c, 4)
	# TAX
	add_instruction(Mnemonic.TAX, AddressingMode.IMP, 0xaa, 2)
	# TAY
	add_instruction(Mnemonic.TAY, AddressingMode.IMP, 0xa8, 2)
	# TSX
	add_instruction(Mnemonic.TSX, AddressingMode.IMP, 0xba, 2)
	# TXS
	add_instruction(Mnemonic.TXS, AddressingMode.IMP, 0x9a, 2)
	# TYA
	add_instruction(Mnemonic.TYA, AddressingMode.IMP, 0x98, 2)

func add_instruction(mnemonic, addressing_mode, opcode, cycles):
	var instruction = Instruction.new()
	instruction.mnemonic = mnemonic
	instruction.addressingMode = addressing_mode
	instruction.opcode = opcode
	instruction.cycles = cycles
	instruction_set[opcode] = instruction

func clock(_clockState: bool):
	pass

func print_status():
	var instruction = instruction_set[current_opcode]
	var format_string = "PC:%04x ACC:%02x X:%02x Y:%02x SP:%02x %s"
	var actual_string = format_string % [reg_pc, reg_acc, reg_x, reg_y, reg_sp, mnemonic_name[instruction.mnemonic]]
	print(actual_string)

func tick_instruction():
	current_opcode = memory[reg_pc]
	var current_instruction = instruction_set[current_opcode]
	print_status()
	mnemonic_handlers[current_instruction.mnemonic].call(current_instruction)
	
func _process(_delta):
	tick_instruction()

func get_address(mode: AddressingMode):
	match mode:
		AddressingMode.IMP:
			pass

func addrmode_IMP():
	pass
func addrmode_ACC():
	pass
func addrmode_IMM():
	reg_pc += 1
	return memory[reg_pc]
func addrmode_ZP():
	pass
func addrmode_ZPX():
	pass
func addrmode_ZPY():
	pass
func addrmode_REL():
	pass
func addrmode_ABS():
	reg_pc += 2
	return memory[reg_pc - 1] | (memory[reg_pc] << 8)
func addrmode_ABSX():
	pass
func addrmode_ABSY():
	pass
func addrmode_IND():
	pass
func addrmode_IDXINDX():
	pass
func addrmode_INDIDXY():
	pass

func set_status_flag(flag):
	reg_sp = reg_sp | flag

func clear_status_flag(flag):
	reg_sp = reg_sp & (0xff ^ flag)

func update_zero_flag(val):
	if val == 0:
		set_status_flag(flag_zero)
	else:
		clear_status_flag(flag_zero)

func update_negative_flag(val):
	if val & 0x80:
		set_status_flag(flag_negative)
	else:
		clear_status_flag(flag_negative)

func mnemonic_CLD(instruction: Instruction):
	clear_status_flag(flag_decimal)
	reg_pc += 1

func mnemonic_INX(instruction: Instruction):
	reg_x += 1
	reg_pc += 1
	update_zero_flag(reg_x)
	update_negative_flag(reg_x)

func mnemonic_JSR(instruction: Instruction):
	var return_address = reg_pc + 2
	memory[reg_sp] = return_address & 0xff
	reg_sp -= 1
	memory[reg_sp] = (return_address & 0xff00) >> 8
	reg_sp -= 1
	var value = addressing_mode_handlers[instruction.addressingMode].call()
	reg_pc = value

func mnemonic_LDA(instruction: Instruction):
	reg_acc = addressing_mode_handlers[instruction.addressingMode].call()
	update_zero_flag(reg_acc)
	update_negative_flag(reg_acc)
	reg_pc += 1

func mnemonic_LDX(instruction: Instruction):
	reg_x = addressing_mode_handlers[instruction.addressingMode].call()
	update_zero_flag(reg_x)
	update_negative_flag(reg_x)
	reg_pc += 1

func mnemonic_SEI(instruction: Instruction):
	set_status_flag(flag_interrupt)
	reg_pc += 1

func mnemonic_TXS(instruction: Instruction):
	reg_sp = reg_x
	reg_pc += 1
	
func mnemonic_UNKNOWN(instruction: Instruction):
	pass
