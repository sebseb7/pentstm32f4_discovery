LIB = libSTM32_DSP_Lib.a

CC = arm-none-eabi-gcc
AR = arm-none-eabi-ar
RANLIB = arm-none-eabi-ranlib

CFLAGS = -Wall -O2 -mlittle-endian -mthumb
CFLAGS += -mcpu=cortex-m4 -ffreestanding -nostdlib -fno-strict-aliasing -ffunction-sections
CFLAGS += -funsigned-char -Wundef -Wunreachable-code -Wstrict-prototypes
CFLAGS += -I../inc -Wa,-adhlns=$(<:.c=.lst) -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wl,--gc-sections -fsingle-precision-constant 
CFLAGS += -DARM_MATH_CM4 -DARM_MATH_MATRIX_CHECK -DARM_MATH_ROUNDING -D__FPU_PRESENT=1 

SRCS=$(wildcard ../src/BasicMathFunctions/*.c ../src/CommonTables/*.c ../src/ComplexMathFunctions/*.c ../src/ControllerFunctions/*.c ../src/FastMathFunctions/*.c ../src/FilteringFunctions/*.c ../src/MatrixFunctions/*.c ../src/StatisticsFunctions/*.c ../src/SupportFunctions/*.c ../src/TransformFunctions/*.c ../src/Common/*.c) 

OBJS = $(SRCS:.c=.o)
LSTS = $(SRCS:.c=.lst)

all: $(LIB)

$(LIB): $(OBJS)
	echo $(SRCS)
	$(AR) -r $(LIB) $(OBJS)
	$(RANLIB) $(LIB)

%.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $^

clean:
	-rm -f $(OBJS)
	-rm -f $(LIB)
	-rm -f $(LSTS)

.PHONY: all clean
