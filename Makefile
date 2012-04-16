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

OPTIMIZATION = 2
DEBUG = -g

#########################################################################

SRC=$(wildcard core/*.c *.c) 
ASRC=$(wildcard core/*.s)
OBJECTS= $(SRC:.c=.o) $(ASRC:.s=.o)
HEADERS=$(wildcard core/*.h *.h)

#  Compiler Options
GCFLAGS=-g -O2 -mlittle-endian -mthumb -Icore
GCFLAGS+=-mcpu=cortex-m4	
GCFLAGS+=-ffreestanding -nostdlib

# to run from FLASH
#GCFLAGS+=-Wl,-T,stm32_flash.ld

# stm32f4_discovery lib
GCFLAGS+=-ISTM32F4xx_StdPeriph_Driver/inc
GCFLAGS+=-ISTM32F4xx_StdPeriph_Driver/inc/device_support
GCFLAGS+=-ISTM32F4xx_StdPeriph_Driver/inc/core_support

#GCFLAGS = -std=gnu99 -Wall -fno-common -mcpu=cortex-m3 -mthumb -O$(OPTIMIZATION) $(DEBUG) -Ilpc_drivers -I. -Idrivers -Icore 
# -ffunction-sections -fdata-sections -fmessage-length=0   -fno-builtin
#GCFLAGS += -D__RAM_MODE__=0  -D__BUILD_WITH_EXAMPLE__ 
LDFLAGS = -mcpu=cortex-m4 -mthumb -O$(OPTIMIZATION) -nostartfiles  -T$(LSCRIPT) -LSTM32F4xx_StdPeriph_Driver/build -lSTM32F4xx_StdPeriph_Driver
ASFLAGS = -mcpu=cortex-m4 

#  Compiler/Assembler Paths
GCC = arm-none-eabi-gcc
AS = arm-none-eabi-as
OBJCOPY = arm-none-eabi-objcopy
REMOVE = rm -f
SIZE = arm-none-eabi-size

#########################################################################

all: $(PROJECT).bin Makefile stats
	make -C STM32F4xx_StdPeriph_Driver/build
	make -C tools

$(PROJECT).bin: $(PROJECT).elf Makefile
	$(OBJCOPY) -R .stack -O binary $(PROJECT).elf $(PROJECT).bin

$(PROJECT).elf: $(OBJECTS) Makefile
	$(GCC) $(OBJECTS) $(LDFLAGS)  -o $(PROJECT).elf

stats: $(PROJECT).elf Makefile
	$(SIZE) $(PROJECT).elf

clean:
	$(REMOVE) $(OBJECTS)
	$(REMOVE) $(PROJECT).bin
	$(REMOVE) $(PROJECT).elf
	make -C STM32F4xx_StdPeriph_Driver/build clean
	make -C tools clean

#########################################################################

%.o: %.c Makefile $(HEADERS)
	$(GCC) $(GCFLAGS) -o $@ -c $<

%.o: %.s Makefile 
	$(AS) $(ASFLAGS) -o $@  $< 

#########################################################################

flash: all

	tools/flash/st-flash write $(PROJECT).bin 0x08000000
#	lpc21isp $(PROJECT).hex  $(USB_DEVICE) 230400 14746
#	lpc21isp -verify $(PROJECT).hex  $(USB_DEVICE) 19200 14746

