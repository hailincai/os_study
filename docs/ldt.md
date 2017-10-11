To use LGT in the code, we need to do following things

* Same as GDT, we need to create the LGT section. In this section, we need to define the Descriptor and Selector same as GDT. But need to make sure Selector has **TI** field been set to 1. When this field is set, when code load the Selector into segment register, the cpu will look up Descriptor for the Selector in current loaded LGT 
```asm
[SECTION .lgt]
LABEL_LGT:
LABEL_LGT_DESC_CODEA: Descriptor 0, SegCodeALen - 1, DA_C + DA_32 ;means 32 bit code segment
LgtLen	equ $ - LABEL_LGT

SelectorLGTCodeA	equ	LABEL_LGT_DESC_CODEA - LABEL_LGT + SA_TIL
```

* In the GDT, we need to add the LGT section into the GDT label, including the Descriptor and Selector. Make sure the Descriptor has **DA_LDT**. Means this Descriptor is a LDT Descriptor
```asm
[SECTION .gdt]
LABEL_DESC_GDT:	Descriptor	0, 0, 0 ;GDT requires the first entry is an empty descriptor
LABEL_DESC_LGT: Descriptor  0, LgtLen - 1, DA_LDT

GdtLen	equ $ - LABEL_DESC_GDT
GdtPtr	dw GdtLen - 1
		dd 0

SelectorLGT equ	LABEL_DESC_LGT - LABEL_DESC_GDT
```

* In the code, when you want to call the code in LGT, do following
```asm
; load LGT table into memory
mov ax, SelectorLGT
llgt ax

; because SelectorLGTCodeA has TI been set, so cpu will find LABEL_LGT_DESC_CODEA in LGT table just loaded
jmp SelectorLGTCodeA:0
```