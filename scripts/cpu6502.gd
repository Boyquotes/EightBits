extends Node

var reg_acc: int
var reg_x: int
var reg_y: int
var reg_sp: int
var reg_pc: int
var reg_status: int

class Instruction:
	var mnemonic: Mnemonic
	var addressingMode: AddressingMode
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
	Mnemonic.LDA: "Load Acc",
	Mnemonic.LDX: "Load X",
	Mnemonic.LDY: "Load Y",
	Mnemonic.STA: "Store Acc",
	Mnemonic.STX: "Store X",
	Mnemonic.STY: "Store Y",
	Mnemonic.TAX: "Transfer Acc->X",
	Mnemonic.TAY: "Transfer Acc->Y",
	Mnemonic.TXA: "Transfer X->Acc",
	Mnemonic.TYA: "Transfer Y->Acc",
	Mnemonic.TSX: "Transfer SP->X",
	Mnemonic.TXS: "Trasfer X->SP",
	Mnemonic.PHA: "Push Acc->Stack",
	Mnemonic.PHP: "Push Status->Stack",
	Mnemonic.PLA: "Pull Stack->Acc",
	Mnemonic.PLP: "Pull Stack->Status",
	Mnemonic.AND: "Logical AND",
	Mnemonic.EOR: "Exclusive OR",
	Mnemonic.ORA: "Logical Inclusive OR",
	Mnemonic.BIT: "Bit test",
	Mnemonic.ADC: "Add with Carry",
	Mnemonic.SBC: "Subtract with Carry",
	Mnemonic.CMP: "Compare Acc",
	Mnemonic.CPX: "Compare X",
	Mnemonic.CPY: "Compare Y",
	Mnemonic.INC: "Increment memory",
	Mnemonic.INX: "Increment X",
	Mnemonic.INY: "Increment Y",
	Mnemonic.DEC: "Decrement memory",
	Mnemonic.DEX: "Decrement X",
	Mnemonic.DEY: "Decrement Y",
	Mnemonic.ASL: "Arithmetic shift left Acc",
	Mnemonic.LSR: "Logical shift right Acc",
	Mnemonic.ROL: "Rotate left Acc",
	Mnemonic.ROR: "Rotate right Acc",
	Mnemonic.JMP: "Jump to address",
	Mnemonic.JSR: "Jump to subroutine",
	Mnemonic.RTS: "Return from subroutine",
	Mnemonic.BCC: "Branch is Carry clear",
	Mnemonic.BCS: "Branch if Carry set",
	Mnemonic.BEQ: "Branch if Zero set",
	Mnemonic.BMI: "Branch if Negative set",
	Mnemonic.BNE: "Branch if Zero clear",
	Mnemonic.BPL: "Branch if Negative clear",
	Mnemonic.BVC: "Branch if oVerflow clear",
	Mnemonic.BVS: "Branch if oVerflow set",
	Mnemonic.CLC: "Clear Carry flag",
	Mnemonic.CLD: "Clear Decimal flag",
	Mnemonic.CLI: "Clear Interrupt disable flag",
	Mnemonic.CLV: "Clear oVerflow flag",
	Mnemonic.SEC: "Set Carry flag",
	Mnemonic.SED: "Set Decimal flag",
	Mnemonic.SEI: "Set Interrupt disable flag",
	Mnemonic.BRK: "Break",
	Mnemonic.NOP: "No operation",
	Mnemonic.RTI: "Return from Interrupt"
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
	
	instruction_set.resize(256)
	memory.resize(65536)
	
	add_instructions()

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
	instruction_set[opcode] = instruction

func clock(clockState):
	pass

func tick_instruction():
	pass
	
