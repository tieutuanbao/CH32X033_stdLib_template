
PROJECT_NAME    =   CH32X035

PREFIX          =   ~/.local/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin/riscv-none-embed-

CC              =   $(PREFIX)gcc
AS              =   $(PREFIX)gcc -x assembler-with-cpp
CP              =   $(PREFIX)objcopy
SZ              =   $(PREFIX)size
HEX             =   $(CP) -O ihex
BIN             =   $(CP) -O binary -S

PROJECT_DIR     =   .
BUILD_DIR       =   Build

SOURCE_DIRS     =   User                                                    \
                    Drivers/Startup                                         \
                    Drivers/Core                                            \
                    Drivers/CH32X035_Driver

OBJECT_DIR      = $(BUILD_DIR)/Obj
BIN_DIR         = $(BUILD_DIR)/Bin

C_INCLUDES      =   $(addprefix -I,$(addsuffix /Inc,$(SOURCE_DIRS)))

A_SOURCES       =   $(foreach dir,$(SOURCE_DIRS),$(wildcard $(dir)/Src/*.S))

C_SOURCES       =   $(foreach dir,$(SOURCE_DIRS),$(wildcard $(dir)/Src/*.c))

OPT             =   -Og

CFLAGS          =   -march=rv32ec                                           \
                    -mabi=ilp32e                                            \
                    -Wall                                                   \
                    -fdata-sections                                         \
                    -ffunction-sections                                     \
                    $(C_INCLUDES) $(OPT)

CFLAGS          +=  -MMD -MP -MF"$(@:%.o=%.d)"

LDSCRIPT        =   Linker/ch32x035_flash.ld

LIBS            =   -lc -lm -lnosys
LDFLAGS         =   -march=rv32ec                                           \
                    -mabi=ilp32e                                            \
                    -nostartfiles -Xlinker                                  \
                    --gc-sections                                           \
                    -Wl,-Map,$(BIN_DIR)/$(PROJECT_NAME).map                 \
                    --specs=nano.specs                                      \
                    -T$(LDSCRIPT) $(LIBS) $(OPT)

OBJECTS         +=  $(addprefix $(OBJECT_DIR)/,$(C_SOURCES:.c=.o))
vpath %.c $(sort $(dir $(C_SOURCES)))

OBJECTS         +=  $(addprefix $(OBJECT_DIR)/,$(A_SOURCES:.S=.o))
vpath %.S $(sort $(dir $(A_SOURCES)))

BUILD_DIRS      =   $(sort $(dir $(OBJECTS))) $(BIN_DIR)

all: $(BIN_DIR)/$(PROJECT_NAME).elf $(BIN_DIR)/$(PROJECT_NAME).hex $(BIN_DIR)/$(PROJECT_NAME).bin

$(BUILD_DIRS):
	@mkdir -p $@

$(OBJECT_DIR)/%.o: %.s Makefile | $(BUILD_DIRS)
	@echo Compiling $<
	@$(AS) -c $(CFLAGS) $< -o $@

$(OBJECT_DIR)/%.o: %.c Makefile | $(BUILD_DIRS)
	@echo Compiling $<
	@$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(OBJECT_DIR)/$(<:.c=.lst) $< -o $@

$(BIN_DIR)/%.elf: $(OBJECTS) Makefile
	@echo Linking object...
	@$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	@$(SZ) $@

$(BIN_DIR)/%.hex: $(BIN_DIR)/%.elf
	@$(HEX) $< $@

$(BIN_DIR)/%.bin: $(BIN_DIR)/%.elf
	@$(BIN) $< $@

rebuild:
	@make --no-print-directory clean
	@make --no-print-directory all

clean: $(BUILD_DIR)
	@rm -r $(BUILD_DIR)
	@echo Cleaned all file.

-include $(wildcard $(BUILD_DIR)/*.d)
