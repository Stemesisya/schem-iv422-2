#!/usr/bin/env kotlin

import java.io.File
import java.util.regex.Pattern
import kotlin.system.exitProcess

var currentLine = 0

class CompilationException(string: String): IllegalArgumentException("Instruction #$currentLine: $string")

class OffsettedBase(string: String) {
	companion object {
		val pattern: Pattern = Pattern.compile("(-?\\d*)\\(([a-z0-9]*)\\)")
	}

	val offset: Int
	val base: Int

	init {
		val matcher = pattern.matcher(string)
		if(!matcher.matches())
			throw CompilationException("invalid offsetted value '$string'")
		offset = matcher.group(1).toInt()
		base = getRegister(matcher.group(2))

		if(offset % 4 != 0)
			throw CompilationException("Offset should be divisible by 4.")
	}

}

val Registers = HashMap<String, Int>().apply {
	var addr = 0
	fun reg(name: String) { put(name, addr++) }

	reg("zero")
	reg("ra")
	reg("sp")
	reg("gp")
	reg("tp")
	reg("t0"); reg("t1"); reg("t2")
	reg("s0"); reg("s1")
	reg("a0"); reg("a1")
	for (i in 2..7)
		reg("a$i")
	for (i in 2..11)
		reg("s$i")
	for (i in 3..6)
		reg("t$i")

}

val Ops = HashMap<String, InstructionType>().apply {
	put("lw", TypeI(0x03))
	put("sw", TypeS(0x23))
}

abstract class InstructionType(val name: String, val op: Int) {
	companion object {
		const val RD_OFFSET = 7
		const val IMM_4_0_OFFSET = 7
		const val FUNC3_OFFSET = 12
		const val RS1_OFFSET = 15
		const val RS2_OFFSET = 20
		const val IMM_OFFSET = 20
		const val IMM_11_5_OFFSET = 25

		const val IMM_4_0_MASK = 0x1F
		const val IMM_4_0_LEN = 5
	}

	var binary = 0
	var func3 = 0x2

	abstract fun load(list: List<String>)

	open fun construct(): Int {
		binary = op
		binary = binary or (func3 shl FUNC3_OFFSET)
		return binary
	}

	fun requireNArgs(args: List<String>, n: Int) {
		if(args.size < n)
			throw CompilationException("not enough args for type '$name'. $n required")
		else if(args.size > n)
			throw CompilationException("too much args for type '$name'. $n required")
	}
}

class TypeI(op: Int): InstructionType("I", op) {
	var rd = 0
	var rs1 = 0
	var imm = 0

	override fun load(list: List<String>) {
		requireNArgs(list, 2)
		rd = getRegister(list[0])
		val base = OffsettedBase(list[1])
		rs1 = base.base
		imm = base.offset
	}

	override fun construct(): Int {
		super.construct()
		binary = binary or (rd shl RD_OFFSET)
		binary = binary or (rs1 shl RS1_OFFSET)
		binary = binary or (imm shl IMM_OFFSET)
		return binary
	}
}

class TypeS(op: Int): InstructionType("S", op) {
	var rs1 = 0
	var rs2 = 0
	var imm = 0

	override fun load(list: List<String>) {
		requireNArgs(list, 2)
		rs2 = getRegister(list[0])
		val base = OffsettedBase(list[1])
		rs1 = base.base
		imm = base.offset
	}

	override fun construct(): Int {
		super.construct()
		binary = binary or (rs1 shl RS1_OFFSET)
		binary = binary or (rs2 shl RS2_OFFSET)
		val imm40 = imm and IMM_4_0_MASK
		val imm115 = imm shr IMM_4_0_LEN
		binary = binary or (imm40 shl IMM_4_0_OFFSET)
		binary = binary or (imm115 shl IMM_11_5_OFFSET)
		return binary
	}
}

val program = File("program.asm")

val binary = Array(256) { 0U }

program.readLines().forEachIndexed { index, it ->
	currentLine = index

	val opStr = it.substringBefore(' ', "")
		.ifEmpty {
			println("Instruction #$index: Syntax error")
			exitProcess(1)
		}

	val type = Ops[opStr]

	if(type == null) {
		println("Instruction #$index: unknown instruction: '$opStr'")
		exitProcess(1)
	}

	val args = it.drop(opStr.length)
		.split(',')
		.map { it.trim() }

	type.load(args)
	val code: UInt = type.construct().toUInt()
	binary[currentLine] = code
}

File("instructions.dat").writeText(
	binary.joinToString("\n") { it
		.toString(16)
		.padStart(8, '0')
	}
)


fun getRegister(regName: String): Int {
	return Registers[regName] ?: throw CompilationException("unknown register: '$regName'")
}