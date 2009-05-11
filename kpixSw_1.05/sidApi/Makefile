# Variables
DEF     := -DONLINE_EN
CFLAGS  := -Wall `root-config --cflags`
LFLAGS  := -lpthread -ldl -lftd2xx -L ftdi `root-config --libs` -lMinuit -llockdev
CC      := g++
OUT     := $(PWD)/../bin
OBJ     := $(PWD)/.obj
DEP     := $(PWD)/.dep
TAR     := $(OUT)/libsidapi.so

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

# Default
all: dirs $(TAR)

# Create object directory
dirs:
	test -d $(OBJ) || mkdir $(OBJ)

# Clean up the build
clean:
	rm -f $(DEP)/* $(OBJ)/* $(TAR) 

# Pre-process the headers for root
$(OBJ)/sidapi.C: $(ON_HDR) $(OFF_HDR)
	rootcint -f $(OBJ)/sidapi.C -c $(DEF) $(ON_HDR) $(OFF_HDR)

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

# Generate dependencies
dep: $(ON_SRC) $(OFF_SRC) $(ON_HDR) $(OFF_HDR)
	test -d $(DEP) || mkdir $(DEP)
	cd $(DEP); $(CC) $(CFLAGS) $(DEF) -MD -E $(ON_SRC) $(OFF_SRC) > /dev/null

# Include dependencies
-include ($ON_DEPS)
-include ($OFF_DEPS)
