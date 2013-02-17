PROJECT_NAME=usb2lcd

# install paths
ARDUINO=/home/neil/Projects/digispark/arduino-1.0.3
HARDWARE=$(ARDUINO)/hardware
LIBS=$(ARDUINO)/libraries
TINY=$(ARDUINO)/hardware/tiny-digispark/cores/tiny

# chip and programmer settings
MCU=attiny85
CPU=16000000L
PROGRAMMER=arduino
PORT=/dev/ttyUSB0
BAUDRATE=115200

# tool paths
CC=$(HARDWARE)/tools/avr/bin/avr-gcc
CPP=$(HARDWARE)/tools/avr/bin/avr-g++
AR=$(HARDWARE)/tools/avr/bin/avr-ar rcs
OBJ=$(HARDWARE)/tools/avr/bin/avr-objcopy
MICRONUCLEUS=$(HARDWARE)/tools/micronucleus

# tool flags
EEPFLAGS=-O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0
HEXFLAGS=-O ihex -R .eeprom
CFLAGS=-Os -Wall -fno-exceptions -ffunction-sections -fdata-sections -mmcu=$(MCU) -DF_CPU=$(CPU) -DUSB_VID=null -DUSB_PID=null -DARDUINO=101 -I$(TINY) $(addprefix -I,$(wildcard $(LIBS)/*))
LDFLAGS=-Os -Wl,--gc-sections -mmcu=$(MCU) $(addprefix -L,$(wildcard $LIBS/*)) -L. -lm

# sources
SOURCES_PROJECT=$(join $(PROJECT_NAME),.cpp)
SOURCES_TINY=$(TINY)/wiring_digital.c $(TINY)/WInterrupts.c $(TINY)/wiring_pulse.c $(TINY)/pins_arduino.c $(TINY)/wiring_analog.c $(TINY)/wiring.c $(TINY)/wiring_shift.c $(TINY)/Tone.cpp $(TINY)/WMath.cpp $(TINY)/WString.cpp $(TINY)/main.cpp $(TINY)/TinyDebugSerial.cpp $(TINY)/Print.cpp $(TINY)/HardwareSerial.cpp
SOURCES_LIBS=$(LIBS)/DigisparkLCD/LiquidCrystal_I2C.cpp $(LIBS)/LiquidCrystal/LiquidCrystal.cpp $(LIBS)/DigisparkUSB/DigiUSB.cpp $(LIBS)/DigisparkUSB/osccal.c $(LIBS)/DigisparkKeyboard/usbdrvasm.S $(LIBS)/DigisparkKeyboard/usbdrv.c $(LIBS)/TinyWireM_Digispark/TinyWireM.cpp $(LIBS)/TinyWireM_Digispark/USI_TWI_Master.cpp

# objects
OBJECTS_PROJECT=$(SOURCES_PROJECT:.cpp=.o)
OBJECTS_TINY_C=$(SOURCES_TINY:.c=.o)
OBJECTS_LIBS_C=$(SOURCES_LIBS:.c=.o)
OBJECTS_TINY_S=$(OBJECTS_TINY_C:.S=.o)
OBJECTS_LIBS_S=$(OBJECTS_LIBS_C:.S=.o)
OBJECTS_TINY=$(OBJECTS_TINY_S:.cpp=.o)
OBJECTS_LIBS=$(OBJECTS_LIBS_S:.cpp=.o)

# libraries
LIB_TINY=libtiny.a
LIB_LIBS=liblibs.a

# binaries
ELF=$(join $(PROJECT_NAME),.elf)
EEP=$(join $(PROJECT_NAME),.eep)
HEX=$(join $(PROJECT_NAME),.hex)

all: $(ELF)

$(LIB_TINY): $(OBJECTS_TINY)
	@echo === creating $@ ===
	$(AR) $@ $^
	@echo

$(LIB_LIBS): $(OBJECTS_LIBS)
	@echo === creating $@ ===
	$(AR) $@ $^
	@echo

%.o: %.c
	@echo === compiling $@ ===
	$(CC) $(CFLAGS) -c $< -o $@
	@echo

%.o: %.cpp
	@echo === compiling $@ ===
	$(CPP) $(CFLAGS) -c $< -o $@
	@echo

%.o: %.S
	@echo === compiling $@ ===
	$(CC) $(CFLAGS) -c $< -o $@
	@echo

$(ELF): $(OBJECTS_PROJECT) $(LIB_TINY) $(LIB_LIBS)
	@echo === linking $@ ===
	$(CC) $(LDFLAGS) $(OBJECTS_PROJECT) -ltiny -llibs -o $@
	@echo

$(EEP): $(ELF)
	@echo === creating $@ ===
	$(OBJ) $(EEPFLAGS) $(ELF) $@
	@echo

$(HEX): $(ELF)
	@echo === creating $@ ===
	$(OBJ) $(HEXFLAGS) $(ELF) $@
	@echo

clean:
	rm -rf $(OBJECTS_PROJECT) $(OBJECTS_TINY) $(OBJECTS_LIBS) $(ELF) $(EEP) $(HEX) $(LIB_TINY) $(LIB_LIBS)

upload: $(HEX)
	@echo === uploading $< ===
	$(MICRONUCLEUS) $(HEX)

