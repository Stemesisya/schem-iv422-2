#!/usr/bin/env kotlin

import java.io.File
import java.util.regex.Pattern
import kotlin.system.exitProcess

var currentLine = 0

class CompilationException(string: String) : IllegalArgumentException("Instruction #$currentLine: $string")

fun getMask(n: Int) = ((1 shl n) - 1).toUInt()
fun UInt.slice(lbound: Int, hbound: Int) = (this shr lbound) and getMask (hbound-lbound+1)
fun UInt.slice(from: Int) = (this shr from) and 0x1U

class OffsettedBase(string: String) {
	companion object {
		val pattern: Pattern = Pattern.compile("(-?\\d*)\\(([a-z0-9]*)\\)")
	}

	val offset: UInt
	val base: UInt

	init {
		val matcher = pattern.matcher(string)
		if (!matcher.matches())
			throw CompilationException("invalid offsetted value '$string'")
		offset = matcher.group(1).toInt().toUInt()
		base = getRegister(matcher.group(2))

		if (offset % 4U != 0U)
			throw CompilationException("Offset should be divisible by 4.")
	}

}

val Registers = HashMap<String, UInt>().apply {
	var addr = 0U
	fun reg(name: String) {
		put(name, addr++)
	}

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
	put("lw", TypeI(0x03, 0x2U, 0x00U))
	put("sw", TypeS(0x23, 0x2U, 0x00U))

	put("add", TypeR(0x33, 0x0U, 0x00U))
	put("sub", TypeR(0x33, 0x0U, 0x20U))
	put("and", TypeR(0x33, 0x7U, 0x00U))
	put("or", TypeR(0x33, 0x6U, 0x00U))
	put("slt", TypeR(0x33, 0x2U, 0x00U))

	put("beq", TypeB(0x63, 0x0U, 0x00U))
	put("jal", TypeJ(0x6F, 0x0U, 0x00U))
}

abstract class InstructionType(val name: String, val op: Int, val funct3: UInt, val funct7: UInt) {
	companion object {
		const val RD_OFFSET = 7
		const val FUNC3_OFFSET = 12
		const val FUNC7_OFFSET = 25
		const val RS1_OFFSET = 15
		const val RS2_OFFSET = 20
		const val IMM_OFFSET = 20
	}

	var binary = 0U

	abstract fun load(list: List<String>)

	open fun construct(): UInt {
		binary = op.toUInt()
		binary = binary or (funct3 shl FUNC3_OFFSET)
		binary = binary or (funct7 shl FUNC7_OFFSET)
		println(binary.toString(2).padStart(32, '0'))
		return binary
	}

	fun requireNArgs(args: List<String>, n: Int) {
		if (args.size < n)
			throw CompilationException("not enough args for type '$name'. $n required")
		else if (args.size > n)
			throw CompilationException("too much args for type '$name'. $n required")
	}
}

class TypeI(op: Int, funct3: UInt, funct7: UInt) : InstructionType("I", op, funct3, funct7) {
	var rd = 0U
	var rs1 = 0U
	var imm = 0U

	override fun load(list: List<String>) {
		requireNArgs(list, 2)
		rd = getRegister(list[0])
		val base = OffsettedBase(list[1])
		rs1 = base.base
		imm = base.offset
	}

	override fun construct(): UInt {
		super.construct()
		binary = binary or (rd shl RD_OFFSET)
		binary = binary or (rs1 shl RS1_OFFSET)
		binary = binary or (imm shl IMM_OFFSET)
		return binary
	}
}

class TypeS(op: Int, funct3: UInt, funct7: UInt) : InstructionType("S", op, funct3, funct7) {
	var rs1 = 0U
	var rs2 = 0U
	var imm = 0U

	override fun load(list: List<String>) {
		requireNArgs(list, 2)
		rs2 = getRegister(list[0])
		val base = OffsettedBase(list[1])
		rs1 = base.base
		imm = base.offset
	}

	override fun construct(): UInt {
		super.construct()
		binary = binary or (rs1 shl RS1_OFFSET)
		binary = binary or (rs2 shl RS2_OFFSET)
		binary = binary or (imm.slice(0, 4) shl 7)
		binary = binary or (imm.slice(5, 11) shl 25)
		return binary
	}
}

class TypeR(op: Int, funct3: UInt, funct7: UInt) : InstructionType("R", op, funct3, funct7) {
	var rs1 = 0U
	var rs2 = 0U
	var rd = 0U

	override fun load(list: List<String>) {
		requireNArgs(list, 3)
		rd = getRegister(list[0])
		rs1 = getRegister(list[1])
		rs2 = getRegister(list[2])
	}

	override fun construct(): UInt {
		super.construct()
		binary = binary or (rd shl RD_OFFSET)
		binary = binary or (rs1 shl RS1_OFFSET)
		binary = binary or (rs2 shl RS2_OFFSET)
		return binary
	}
}

class TypeB(op: Int, funct3: UInt, funct7: UInt) : InstructionType("R", op, funct3, funct7) {
	var rs1 = 0U
	var rs2 = 0U
	var imm = 0U

	override fun load(list: List<String>) {
		requireNArgs(list, 3)
		rs1 = getRegister(list[0])
		rs2 = getRegister(list[1])
		imm = list[2].toIntOrNull()?.toUInt() ?: throw CompilationException("Immediate should be a number")
		if (imm % 4U != 0U)
			throw CompilationException("Immediate should be divisible by 4.")
	}

	override fun construct(): UInt {
		super.construct()
		binary = binary or (rs1 shl RS1_OFFSET)
		binary = binary or (rs2 shl RS2_OFFSET)
		binary = binary or (imm.slice(11) shl 7)
		binary = binary or (imm.slice(1, 4) shl 8)
		binary = binary or (imm.slice(5, 10) shl 25)
		println(imm.slice(12))
		println(imm.toString(2))
		binary = binary or (imm.slice(12) shl 31)
		return binary
	}
}

class TypeJ(op: Int, funct3: UInt, funct7: UInt) : InstructionType("R", op, funct3, funct7) {
	var rd = 0U
	var imm = 0U

	override fun load(list: List<String>) {
		requireNArgs(list, 2)
		rd = getRegister(list[0])
		imm = list[1].toUIntOrNull() ?: throw CompilationException("Immediate should be a number")
		if (imm % 4U != 0U)
			throw CompilationException("Immediate should be divisible by 4.")
	}

	override fun construct(): UInt {
		super.construct()
		binary = binary or (rd shl RD_OFFSET)
		binary = binary or (imm.slice(12, 19) shl 12)
		binary = binary or (imm.slice(11) shl 20)
		binary = binary or (imm.slice(21, 30) shl 21)
		binary = binary or (imm.slice(31) shl 31)
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

	if (type == null) {
		println("Instruction #$index: unknown instruction: '$opStr'")
		exitProcess(1)
	}

	val args = it.drop(opStr.length)
		.split(',')
		.map { it.trim() }

	type.load(args)
	val code = type.construct()
	println("#$currentLine: '$it' -> (0x${code.toString(16).padStart(8, '0')}) ${code.toString(2).padStart(32, '0')}")
	binary[currentLine] = code
}

File("instructions.dat").writeText(
	binary.joinToString("\n") {
		it
			.toString(16)
			.padStart(8, '0')
	}
)


fun getRegister(regName: String): UInt {
	return Registers[regName] ?: throw CompilationException("unknown register: '$regName'")
}