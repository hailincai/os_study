%include "pm.inc"

org 0100h
	jmp LABEL_BEGIN

[SECTION .gdt]
LABEL_GDT:			Descriptor		0,		    0,			0
LABEL_DESC_NORMAL: 	Descriptor		0,	   0ffffh,		DA_DRW ; This is the real mode segment address range
LABEL_DESC_CODE32: 	Descriptor		0, 	SegCode32Len - 1,	DA_C + DA_32
LABEL_DESC_CODE32_RING3: Descriptor 0, SegCodeRing3Len - 1, DA_C + DA_32 + DA_DPL3
LABEL_DESC_CODE16:	Descriptor		0,	   0ffffh,		DA_C
LABEL_DESC_DATA:	Descriptor		0,	DataLen - 1,	DA_DRW
LABEL_DESC_STACK:	Descriptor		0,	TopOfStack,		DA_DRWA + DA_32 ;DA_32 means use 32 bit ESP
LABEL_DESC_STACK_RING3:	Descriptor		0,	TopOfStackRing3,		DA_DRWA + DA_32 + DA_DPL3;DA_32 means use 32 bit ESP
LABEL_DESC_TEST:	Descriptor	0500000h,	0ffffh,		DA_DRW
LABEL_DESC_VIDEO:	Descriptor	0B8000H,	0ffffh,		DA_DRW + DA_DPL3
LABEL_DESC_LGT:		Descriptor		0, LdtLen -1, DA_LDT
LABEL_DESC_CODE_DEST:	Descriptor 0,  SegCodeDestLen - 1, DA_C + DA_32
LABEL_DESC_TSS:		Descriptor	0, TSSLen - 1, DA_386TSS

; call gate definition
LABEL_CALL_GATE_DEST: Gate SelectorCodeDest, 0, 0, DA_386CGate + DA_DPL3

GdtLen	equ	$ - LABEL_GDT
GdtPtr	dw GdtLen - 1
		dd 0

;selector is 16 bits
;|15                3|2 |1--0|
;|index to desc      |TI|RPL |
;All selector's DPR is 0
SelectorNormal	equ LABEL_DESC_NORMAL - LABEL_GDT
SelectorCode32	equ LABEL_DESC_CODE32 - LABEL_GDT
SelectorCode32Ring3 equ	LABEL_DESC_CODE32_RING3 - LABEL_GDT + SA_RPL3
SelectorCode16	equ	LABEL_DESC_CODE16 - LABEL_GDT
SelectorData	equ	LABEL_DESC_DATA - LABEL_GDT
SelectorStack	equ	LABEL_DESC_STACK - LABEL_GDT
SelectorStackRing3	equ	LABEL_DESC_STACK_RING3 - LABEL_GDT + SA_RPL3
SelectorTest	equ	LABEL_DESC_TEST - LABEL_GDT
SelectorVideo	equ	LABEL_DESC_VIDEO - LABEL_GDT
SelectorLGT		equ LABEL_DESC_LGT - LABEL_GDT
SelectorCodeDest	equ	LABEL_DESC_CODE_DEST - LABEL_GDT
SelectorCallGateDest	equ	LABEL_CALL_GATE_DEST - LABEL_GDT + SA_RPL3
SelectorTSS	equ	LABEL_DESC_TSS - LABEL_GDT

;add LGT section
[SECTION .lgt]
LABEL_LGT:

LABEL_LGT_DESC_CODEA:	Descriptor	0, SegCodeALen - 1, DA_C + DA_32

LdtLen	equ $ - LABEL_LGT
;This selector has SA_TIL flag ( TI = 1 )
;So when this selector been a call, cpu will look at current LGT table
SelectorLgtCodeA	equ	LABEL_LGT_DESC_CODEA - LABEL_LGT + SA_TIL

[SECTION .data1]
ALIGN 32
[BITS 32]
LABEL_DATA:
	SPValueInRealMode	dw 0
	PMMessage:	db "In Protect Mode now ^_^", 0
	OffsetPMMessage	equ	PMMessage - $$
	StrTest:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
	OffsetStrTest	equ StrTest - $$
	DataLen	equ $ - LABEL_DATA

;global stack
[SECTION .gs]
ALIGN 32
[BITS 32]
LABEL_STACK:
	times 512 db 0

TopOfStack	equ $ - LABEL_STACK - 1

[SECTION .ring3s]
ALIGN 32
[BITS 32]
LABEL_STACK_RING3:
	times 512 db 0
TopOfStackRing3	equ	$ - LABEL_STACK_RING3 - 1

;16 bit code
[SECTION .s16]
[BITS 16]
LABEL_BEGIN:
	mov ax, cs
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov	sp, 0100h

	mov	[LABEL_GO_BACK_TO_REAL+3], ax ;make the jmp 0:LABEL_REAL_ENTRY segement to be the correct real mode segment
	;save real mode sp value
	mov [SPValueInRealMode], sp

	; initialize the LGT DESC in GDT
	xor eax, eax
	mov ax, cs
	shl eax, 4
	add eax, LABEL_LGT
	mov word [LABEL_DESC_LGT + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_LGT + 4], al
	mov byte [LABEL_DESC_LGT + 7], ah

	; initialize the LGT DESC for CodeA
	xor eax, eax
	mov ax, cs
	shl eax, 4
	add eax, LABEL_SEG_CODEA
	mov word [LABEL_LGT_DESC_CODEA + 2], ax
	shr eax, 16
	mov byte [LABEL_LGT_DESC_CODEA + 4], al
	mov byte [LABEL_LGT_DESC_CODEA + 7], ah

	; 初始化 32 位代码段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE32
	mov	word [LABEL_DESC_CODE32 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32 + 4], al
	mov	byte [LABEL_DESC_CODE32 + 7], ah

	; initialize ring3 32 code
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE32_RING3
	mov	word [LABEL_DESC_CODE32_RING3 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32_RING3 + 4], al
	mov	byte [LABEL_DESC_CODE32_RING3 + 7], ah

	; 初始化数据段描述符	
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_DATA
	mov word [LABEL_DESC_DATA + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_DATA + 4], al
	mov byte [LABEL_DESC_DATA + 7], ah

	; 初始化堆栈段描述符
	xor eax, eax
	mov eax, ss
	shl eax, 4
	add eax, LABEL_STACK
	mov word [LABEL_DESC_STACK + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_STACK + 4], al
	mov byte [LABEL_DESC_STACK + 7], ah

	; initialize stack ring3
	xor eax, eax
	mov eax, ss
	shl eax, 4
	add eax, LABEL_STACK_RING3
	mov word [LABEL_DESC_STACK_RING3 + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_STACK_RING3 + 4], al
	mov byte [LABEL_DESC_STACK_RING3 + 7], ah	

	; initialize code 16 descriptor
	xor eax, eax
	mov eax, cs
	shl eax, 4
	add eax, LABEL_SEG_CODE16
	mov word [LABEL_DESC_CODE16 + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_CODE16 + 4], al
	mov byte [LABEL_DESC_CODE16 + 7], ah

	; initialize the code dest
	xor eax, eax
	mov eax, cs
	shl eax, 4
	add eax, LABEL_SEG_CODE_DEST
	mov word [LABEL_DESC_CODE_DEST + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_CODE_DEST + 4], al
	mov byte [LABEL_DESC_CODE_DEST + 7], ah

	; initialize TSS
	xor eax, eax
	mov eax, ds
	shl eax, 4
	add eax, LABEL_TSS
	mov word [LABEL_DESC_TSS + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_TSS + 4], al
	mov byte [LABEL_DESC_TSS + 7], ah

	; 为加载 GDTR 作准备s32codea
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt 基地址
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt 基地址

	lgdt [GdtPtr]

	;shutdown interrupt
	cli

	;open A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	;cr0 set PM
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax	

	;jmp to 32 bit code
	jmp dword SelectorCode32:0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LABEL_REAL_ENTRY:		; 从保护模式跳回到实模式就到了这里
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax

	mov	sp, [SPValueInRealMode]

	in	al, 92h		; ┓
	and	al, 11111101b	; ┣ 关闭 A20 地址线
	out	92h, al		; ┛

	sti			; 开中断

	mov	ax, 4c00h	; ┓
	int	21h		; ┛回到 DOS
; END of [SECTION .s16]	

;This is the code will use LGT
[SECTION .s32codea]
[BITS 32]
LABEL_SEG_CODEA:
	;jump back to real mode
	jmp SelectorCode16:0
SegCodeALen equ $ - LABEL_SEG_CODEA

;This is the call will go through call gate
[SECTION .sdest]
[BITS 32]
LABEL_SEG_CODE_DEST:
	mov ax, SelectorVideo
	mov gs, ax

	mov edi, ( 80 * 12 + 0 ) *2
	mov ah, 0Ch
	mov al, 'C'
	mov [gs:edi], ax

	;load LGT and then call LGT code
	mov ax, SelectorLGT	
	lldt ax
	jmp SelectorLgtCodeA:0	

	;retf ;because this code will call go through the call gate will be a far call, so using retf

SegCodeDestLen	equ $ - LABEL_SEG_CODE_DEST

;32 bit code
[SECTION .s32]
[BITS 32]
LABEL_SEG_CODE32:
	mov ax, SelectorData	
	mov ds, ax
	mov ax, SelectorTest
	mov es, ax ;es points to test memory starts from 5M
	mov ax, SelectorVideo
	mov gs, ax

	mov ax, SelectorStack
	mov es, ax

	mov esp, TopOfStack ;because stack descriptor D=1 said we will use ESP as the stack pointer

	;disp one character
	mov ah, 0Ch
	xor esi, esi
	xor edi, edi
	mov esi, OffsetPMMessage
	mov edi, (80 * 10 + 0) * 2
	cld
.1:
	lodsb
	test al, al
	jz .2
	mov [gs:edi], ax
	add edi, 2
	jmp .1
.2:
	call DispReturn

	; select tss
	mov ax, SelectorTSS
	ltr ax

	push SelectorStackRing3
	push TopOfStackRing3
	push SelectorCode32Ring3
	push 0
	retf

; ------------------------------------------------------------------------
DispReturn:
	push	eax
	push	ebx
	mov	eax, edi
	mov	bl, 160
	div	bl
	and	eax, 0FFh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop	ebx
	pop	eax

	ret
; DispReturn 结束---------------------------------------------------------	
SegCode32Len equ	$ - LABEL_SEG_CODE32

;---- 16 code with 32 bit aligment, will be called by 32 bit code to jump back to real mode
[SECTION .s16code]
ALIGN 32 ;32 ALIGMENT address make jmp from 32 bit code to here possible
[BITS 16]
LABEL_SEG_CODE16:
	;make all selector to be real mode address range
	mov ax, SelectorNormal
	mov ds, ax ;before is mov cs, ax wrong because you can't change cs, if cs change, whole code fly away
	mov ss, ax
	mov es, ax
	mov gs, ax
	mov fs, ax

	;change pm mode flag in cr0
	;this will quit the protected mode
	mov eax, cr0
	and al, 11111110b
	mov cr0, eax

LABEL_GO_BACK_TO_REAL:
	;asm code for this is 
	;byte1    byte2       byte3        byte4    byte5
	;OEAh     Offset                   Segment
	;Segment value is set at init code
	jmp 0:LABEL_REAL_ENTRY 

Code16Len	equ $ - LABEL_SEG_CODE16

[SECTION .s32codering3]
[BITS 32]
LABEL_SEG_CODE32_RING3:
	mov ax, SelectorVideo
	mov gs, ax

	mov edi, ( 80 * 14 + 0 ) *2
	mov ah, 0Ch
	mov al, '3'
	mov [gs:edi], ax

	call SelectorCallGateDest:0

	jmp $

SegCodeRing3Len	equ $ - LABEL_SEG_CODE32_RING3

[SECTION .tss]
ALIGN 32
[BITS 32]
LABEL_TSS:
	DD 0				; Back
	DD TopOfStack		; ring 0 stack
	DD SelectorStack 	;
	DD 0				; ring 1 stack
	DD 0
	DD 0				; ring2 stack
	DD 0
	DD 0				; CR3
	DD 0				; EIP
	DD 0				; EFLAGS
	DD 0				; EAX
	DD 0				; ECX
	DD 0				; EDX
	DD 0				; EBX
	DD 0				; ESP
	DD 0				; EBP
	DD 0				; ESI
	DD 0				; EDI
	DD 0				; ES
	DD 0				; CS
	DD 0				; SS
	DD 0				; DS
	DD 0				; FS
	DD 0				; GS
	DD 0				; LDT
	DW 0				; DEBUG TRACE FLAG
	DW $ - LABEL_TSS + 2	; I/O bitmap base address
	DB 0ffh				; I/O bitmap end flag
TSSLen	equ	$ - LABEL_TSS