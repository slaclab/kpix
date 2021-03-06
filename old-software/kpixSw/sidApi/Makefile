# Variables
DEF     := -DONLINE_EN
CC      := g++
OUT     := $(PWD)/../bin
OBJ     := $(PWD)/.obj
DEP     := $(PWD)/.dep
TAR     := $(OUT)/libsidapi.so
PRC     := $(shell uname -p)
#CFLAGS  := -Wall `root-config --cflags` -fPIC -m32
CFLAGS  := -Wall `root-config --cflags` -fPIC 
LFLAGS  := -lpthread -ldl -lftd2xx -L ftdi/$(PRC) -L$(OUT) `root-config --libs` -lMinuit -llockdev -lXMLParser -lrt
#LFLAGS  := -lpthread -ldl -lftd2xx -L ftdi/i386 -L$(OUT) `root-config --libs` -lMinuit -llockdev -lXMLParser -lrt -m32

# Sources in the hw directory
ON_DIR    := $(PWD)/online
ON_SRC    := $(wildcard $(ON_DIR)/*.cc)
ON_HDR    := $(wildcard $(ON_DIR)/*.h)
ON_OBJ    := $(patsubst $(ON_DIR)/%.cc,$(OBJ)/%.o,$(ON_SRC))
ON_DEPS   := $(patsubst $(OBJ)/%.o,$(DEP)/%.d,$(ON_OBJ))

# Sources in the nohw directory
OFF_DIR  := $(PWD)/offline
OFF_SRC  := $(wildcard $(OFF_DIR)/*.cc)
OFF_HDR  := $(wildcard $(OFF_DIR)/*.h)
OFF_OBJ  := $(patsubst $(OFF_DIR)/%.cc,$(OBJ)/%.o,$(OFF_SRC))
OFF_DEPS := $(patsubst $(OBJ)/%.o,$(DEP)/%.d,$(OFF_OBJ))

# Root Sources
ROOT_DIR   := $(PWD)/root
ROOT_SRC   := $(wildcard $(ROOT_DIR)/*.cc)
ROOT_BIN   := $(patsubst $(ROOT_DIR)/%.cc,$(OUT)/%,$(ROOT_SRC))
#ROOT_DEF   := $(PWD)/root/LinkDef.h
ROOT_DEF   := 
ROOT_FLAGS := -L$(OUT) -lsidapi 

# Default
all: dirs $(TAR) $(ROOT_BIN)

# Create object directory
dirs:
	test -d $(OBJ) || mkdir $(OBJ)

# Clean up the build
clean:
	rm -f $(DEP)/* $(OBJ)/* $(TAR) $(ROOT_BIN)

# Pre-process the headers for root
$(OBJ)/sidapi.C: $(ON_HDR) $(OFF_HDR)
	rootcint -f $(OBJ)/sidapi.C -c $(DEF) $(ON_HDR) $(OFF_HDR) $(ROOT_DEF)

# Build the root sepcific object file
$(OBJ)/sidapi.o: $(OBJ)/sidapi.C
	$(CC) $(CFLAGS) $(DEF) -o $(OBJ)/sidapi.o -c $(OBJ)/sidapi.C

# Build the library
$(TAR): $(ON_OBJ) $(OFF_OBJ) $(OBJ)/sidapi.o
	$(CC) $(CFLAGS) $(DEF) -shared -o $(TAR) $(ON_OBJ) $(OFF_OBJ) $(OBJ)/sidapi.o $(LFLAGS)

# Rule to compile sources in the ON_DIR
$(OBJ)/%.o: $(ON_DIR)/%.cc
	$(CC) -c $(CFLAGS) $(DEF) -o $@ $<

# Rule to compile sources in the OFF_DIR
$(OBJ)/%.o: $(OFF_DIR)/%.cc
	$(CC) -c $(CFLAGS) $(DEF) -o $@ $<

# Rule to compile sources in the root directory
$(OUT)/%: $(ROOT_DIR)/%.cc
	$(CC) $(CFLAGS) $(LFLAGS) $(ROOT_FLAGS) $(DEF) -o $@ $<

# Generate dependencies
dep: $(ON_SRC) $(OFF_SRC) $(ON_HDR) $(OFF_HDR)
	test -d $(DEP) || mkdir $(DEP)
	cd $(DEP); $(CC) $(CFLAGS) $(DEF) -MD -E $(ON_SRC) $(OFF_SRC) > /dev/null

# Generate documentation
docs: 
	cd ./doc; doxygen doxygen.cfg
	cd ./doc/latex; make
	cp ./doc/latex/refman.pdf ./doc/sidApi.pdf

# Include dependencies
-include ($ON_DEPS)
-include ($OFF_DEPS)
