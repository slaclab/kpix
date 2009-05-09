# Variables
DEF     := -DHW_EN
CFLAGS  := -Wall `root-config --cflags`
LFLAGS  := -lpthread -ldl -lftd2xx -L ftdi `root-config --libs` -lMinuit -llockdev
CC      := g++
OUT     := $(PWD)/../bin
OBJ     := $(PWD)/.obj
DEP     := $(PWD)/.dep
TAR     := $(OUT)/libsidapi.so

# Sources in the hw directory
HW_DIR    := $(PWD)/hw
HW_SRC    := $(wildcard $(HW_DIR)/*.cc)
HW_HDR    := $(wildcard $(HW_DIR)/*.h)
HW_OBJ    := $(patsubst $(HW_DIR)/%.cc,$(OBJ)/%.o,$(HW_SRC))
HW_DEPS   := $(patsubst $(OBJ)/%.o,$(DEP)/%.d,$(HW_OBJ))

# Sources in the nohw directory
NOHW_DIR  := $(PWD)/nohw
NOHW_SRC  := $(wildcard $(NOHW_DIR)/*.cc)
NOHW_HDR  := $(wildcard $(NOHW_DIR)/*.h)
NOHW_OBJ  := $(patsubst $(NOHW_DIR)/%.cc,$(OBJ)/%.o,$(NOHW_SRC))
NOHW_DEPS := $(patsubst $(OBJ)/%.o,$(DEP)/%.d,$(NOHW_OBJ))

# Default
all: dirs $(OUT)/libsidapi.so

# Create object directory
dirs:
	test -d $(OBJ) || mkdir $(OBJ)

# Clean up the build
clean:
	rm -f $(DEP)/* $(OBJ)/* $(TAR) 

# Pre-process the headers for root
$(OBJ)/sidapi.C: $(HW_HDR) $(NOHW_HDR)
	rootcint -f $(OBJ)/sidapi.C -c $(DEF) $(HW_HDR) $(NOHW_HDR)

# Build the root sepcific object file
$(OBJ)/sidapi.o: $(OBJ)/sidapi.C
	$(CC) $(CFLAGS) $(DEF) -o $(OBJ)/sidapi.o -c $(OBJ)/sidapi.C

# Build the library
$(TAR): $(HW_OBJ) $(NOHW_OBJ) $(OBJ)/sidapi.o
	$(CC) $(CFLAGS) $(DEF) -shared -o $(TAR) $(HW_OBJ) $(NOHW_OBJ) $(OBJ)/sidapi.o $(LFLAGS)

# Rule to compile sources in the HW_DIR
$(OBJ)/%.o: $(HW_DIR)/%.cc
	$(CC) -c $(CFLAGS) $(DEF) -o $@ $<

# Rule to compile sources in the NOHW_DIR
$(OBJ)/%.o: $(NOHW_DIR)/%.cc
	$(CC) -c $(CFLAGS) $(DEF) -o $@ $<

# Generate dependencies
dep: $(HW_SRC) $(NOHW_SRC) $(HW_HDR) $(NOHW_HDR)
	test -d $(DEP) || mkdir $(DEP)
	cd $(DEP); $(CC) $(CFLAGS) $(DEF) -MD -E $(HW_SRC) $(NOHW_SRC) > /dev/null

# Include dependencies
-include ($HW_DEPS)
-include ($NOHW_DEPS)
