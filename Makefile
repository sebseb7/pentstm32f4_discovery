PROJECT=template


ifeq ($(OSTYPE),)
OSTYPE      = $(shell uname)
endif
ifneq ($(findstring Darwin,$(OSTYPE)),)
USB_DEVICE = $(shell ls /dev/cu.usbserial-A*)
else
USB_DEVICE = /dev/ttyUSB0
endif

LSCRIPT=core/stm32_flash.ld

OPTIMIZATION = -O2
DEBUG = -g

#########################################################################

SRC=$(wildcard core/*.c *.c) 
ASRC=$(wildcard core/*.s)
OBJECTS= $(SRC:.c=.o) $(ASRC:.s=.o)
LSTFILES= $(SRC:.c=.lst)
HEADERS=$(wildcard core/*.h *.h)

#  Compiler Options
GCFLAGS=  -g $(OPTIMIZATION) -mlittle-endian -mthumb -Icore -I. -Iusb
GCFLAGS+= -funsigned-char -Wundef -Wsign-compare -Wunreachable-code -Wstrict-prototypes
GCFLAGS+= -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -Wl,--gc-sections -fsingle-precision-constant -DARM_MATH_CM4 
GCFLAGS+= -Wa,-adhlns=$(<:.c=.lst)
GCFLAGS+= -ffreestanding -nostdlib -Wa,-adhlns=$(<:.c=.lst) -fno-math-errno

# stm32f4_discovery lib
GCFLAGS+=-ISTM32_DSP_Lib/inc
GCFLAGS+=-ISTM32F4xx_StdPeriph_Driver/inc
GCFLAGS+=-ISTM32F4xx_StdPeriph_Driver/inc/device_support
GCFLAGS+=-ISTM32F4xx_StdPeriph_Driver/inc/core_support 

#1803               <Define>ARM_MATH_CM4, ARM_MATH_MATRIX_CHECK, ARM_MATH_ROUNDING, __FPU_PRESENT = 1</Define>
# -ffunction-sections -fdata-sections -fmessage-length=0   -fno-builtin


LDFLAGS = -mcpu=cortex-m4 -mthumb $(OPTIMIZATION) -nostartfiles  -T$(LSCRIPT) 
LDFLAGS+= -LSTM32F4xx_StdPeriph_Driver/build -lSTM32F4xx_StdPeriph_Driver
LDFLAGS+= -LSTM32_DSP_Lib/build -lSTM32_DSP_Lib  
LDFLAGS+= -LlibPDMFilter_GCC

#  Compiler/Assembler Paths
GCC = arm-none-eabi-gcc
AS = arm-none-eabi-as
OBJCOPY = arm-none-eabi-objcopy
REMOVE = rm -f
SIZE = arm-none-eabi-size

#########################################################################

all: STM32F4xx_StdPeriph_Driver/build/STM32F4xx_StdPeriph_Driver.a STM32_DSP_Lib/build/STM32_DSP_Lib.a $(PROJECT).bin Makefile stats
#	arm-none-eabi-objdump -d $(PROJECT).elf > out.dump

STM32F4xx_StdPeriph_Driver/build/STM32F4xx_StdPeriph_Driver.a:
	make -C STM32F4xx_StdPeriph_Driver/build

STM32_DSP_Lib/build/STM32_DSP_Lib.a:
	make -C STM32_DSP_Lib/build

tools/flash/st-flash:
	make -C tools

$(PROJECT).bin: $(PROJECT).elf Makefile
	$(OBJCOPY) -R .stack -O binary $(PROJECT).elf $(PROJECT).bin

$(PROJECT).elf: $(OBJECTS) Makefile
	$(GCC) $(OBJECTS) $(LDFLAGS)  -o $(PROJECT).elf

stats: $(PROJECT).elf Makefile
	$(SIZE) $(PROJECT).elf

clean:
	$(REMOVE) $(OBJECTS)
	$(REMOVE) $(LSTFILES)
	$(REMOVE) $(PROJECT).bin
	$(REMOVE) $(PROJECT).elf
	make -C STM32F4xx_StdPeriph_Driver/build clean
	make -C STM32_DSP_Lib/build clean
	make -C tools clean

#########################################################################

%.o: %.c Makefile $(HEADERS)
	$(GCC) $(GCFLAGS) -o $@ -c $<

%.o: %.s Makefile 
	$(AS) $(ASFLAGS) -o $@  $< 

#########################################################################

flash: tools/flash/st-flash all

	tools/flash/st-flash write $(PROJECT).bin 0x08000000 

