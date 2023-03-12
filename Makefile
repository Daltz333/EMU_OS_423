# Makefile of os423V0x.asm (x=[1,2,3])
# Custom makefile rewritten from the one provided in class
# Expanded to export assembly artifacts into build directory
# and make clean command more flexible

VER         =
ASM         = nasm
ASM_DIR     = asm
ASMFLAGS    = -f bin
IMG         = out.img
BUILD_DIR   = build
FILES_DIR	= files

MBR         = bootloaderV.asm
LDR         = kernelV.asm
DATE		= date_utilV.asm
MBR_SRC     = $(subst V,$(VER),$(MBR))
MBR_BIN     = $(subst .asm,.bin,$(MBR_SRC))
LDR_SRC     = $(subst V,$(VER),$(LDR))
LDR_BIN     = $(subst .asm,.bin,$(LDR_SRC))
DATE_SRC	= $(subst V,$(VER),$(DATE))
DATE_BIN	= $(subst .asm,.bin,$(DATE_SRC))
MSG_FILE	= message.txt

.PHONY : everything clean blankimg


everything : pre-build $(BUILD_DIR)/$(MBR_BIN) $(BUILD_DIR)/$(LDR_BIN) $(BUILD_DIR)/$(DATE_BIN) $(IMG)
	dd if=$(BUILD_DIR)/$(MBR_BIN) of=$(BUILD_DIR)/$(IMG) bs=512 count=1 conv=notrunc
	dd if=$(BUILD_DIR)/$(LDR_BIN) of=$(BUILD_DIR)/$(IMG) bs=512 count=2 seek=37 conv=notrunc
	dd if=$(BUILD_DIR)/$(DATE_BIN) of=$(BUILD_DIR)/$(IMG) bs=512 count=1 seek=38 conv=notrunc
	dd if=$(FILES_DIR)/$(MSG_FILE) of=$(BUILD_DIR)/$(IMG) bs=512 count=1 seek=39 conv=notrunc

pre-build:
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/$(MBR_BIN) : $(ASM_DIR)/$(MBR_SRC)
	$(ASM) $(ASMFLAGS) $< -o $@

$(BUILD_DIR)/$(LDR_BIN) : $(ASM_DIR)/$(LDR_SRC)
	$(ASM) $(ASMFLAGS) $< -o $@

$(BUILD_DIR)/$(DATE_BIN) : $(ASM_DIR)/$(DATE_SRC)
	$(ASM) $(ASMFLAGS) $< -o $@

$(IMG) :
	dd if=/dev/zero of=$(BUILD_DIR)/$(IMG) bs=512 count=2880

clean :
	rm -rf $(BUILD_DIR) $(IMG)

blankimg:
	mkdir -p $(BUILD_DIR)
	dd if=/dev/zero of=$(BUILD_DIR)/$(IMG) bs=512 count=2880
