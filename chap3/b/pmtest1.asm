%include "../pm.inc"

org 0100h
	jmp LABEL_BEGIN

[SECTION .gdt]
LABEL_GDT:			Descriptor 0,		0,				  0				;empty
LABEL_DESC_CODE32:	Descriptor 0,		SegCode32Len - 1, DA_C + DA_32	;code
LABEL_DESC_VIDEO:	Descriptor 0B8000H,	0ffffh,			  DA_DRW		;video card memory

GdtLen	equ	$ - LABEL_GDT												;gdt length
GdtPtr	dw GdtLen - 1													;gdt boundary
		dd 0															;gdt base address


SelectorCode32	equ	LABEL_DESC_CODE32 - LABEL_GDT
SelectorVideo	equ	LABEL_DESC_VIDEO  - LABEL_GDT

[SECTION .s16]
[BITS 16]
LABEL_BEGIN:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0100h

	;initialize 32 code descriptor
	xor eax, eax
	mov ax, cs
	shl eax, 4
	add eax, LABEL_SEG_CODE32
	mov word [LABEL_DESC_CODE32 + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_CODE32 + 4], al
	mov byte [LABEL_DESC_CODE32 + 7], ah

	;prepare to load GDTR
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_GDT
	mov dword [GdtPtr + 2], eax

	lgdt [GdtPtr]

	cli

	;open A20
	in al, 92h
	or al, 00000010b
	out 92h, al

	;switch to protected mode
	mov eax, cr0
	or eax, 1
	mov cr0, eax

	;jmp to code32
	jmp dword SelectorCode32:0

[SECTION .s32]
[BITS 32]
LABEL_SEG_CODE32:
	mov ax, SelectorVideo
	mov gs, ax

	mov edi, (80 * 11 + 79) * 2 ;screen row 11 and col 79
	mov ah, 0Ch
	mov al, 'P'
	mov [gs:edi], ax

	jmp $ ;dead loop

SegCode32Len	equ $ - LABEL_SEG_CODE32