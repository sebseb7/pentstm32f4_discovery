# make ... for both stlink v1 and stlink v2 support
##
VPATH=src

SOURCES_LIB=stlink-common.c stlink-usb.c stlink-sg.c uglylogging.c
OBJS_LIB=$(SOURCES_LIB:.c=.o)
LDFLAGS=-L. -lstlink 

# libusb location
LDFLAGS+=`pkg-config --libs libusb-1.0`
CFLAGS+=`pkg-config --cflags libusb-1.0`

CFLAGS+=-g
#CFLAGS+=-DDEBUG=1
CFLAGS+=-std=gnu99
CFLAGS+=-Wall -Wextra


LIBRARY=libstlink.a

all:  $(LIBRARY) flash 

$(LIBRARY): $(OBJS_LIB)
	@echo "objs are $(OBJS_LIB)"
	$(AR) -cr $@ $^
	@echo "done making library"
	
%.o: %.c
	@echo "building $^ into $@"
	$(CC) $(CFLAGS) -c $^ -o $@
	@echo "done compiling"

clean:
	rm -rf $(OBJS_LIB)
	rm -rf $(LIBRARY)
	$(MAKE) -C flash clean
	
flash:
	$(MAKE) -C flash

.PHONY: clean all flash 
