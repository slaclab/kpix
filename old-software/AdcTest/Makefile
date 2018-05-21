# Library Sources
LIB_DIR  := ./lib
LIB_SRC  := $(wildcard $(LIB_DIR)/*.cc)
LIB_OBJ  := $(patsubst %.cc,%.o,$(LIB_SRC))

# Sources in the local directory
LOC_SRC  := $(wildcard *.cc)
LOC_BIN  := $(patsubst %.cc,%,$(LOC_SRC))

# Variables
DEF     := 
CFLAGS  := -Wall 
LFLAGS  := 
CC      := g++

# Default
all: $(LIB_OBJ) $(LOC_BIN)

# Rule to compile lib code
$(LIB_DIR)/%.o: $(LIB_DIR)/%.cc
	$(CC) -c $(CFLAGS) $(DEF) -o $@ $<

# Rule to compile local code
%: %.cc $(LIB_OBJ)
	$(CC) $(CFLAGS) $(DEF) -o $@ $(LIB_OBJ) $< $(LFLAGS) 

clean:
	rm -f $(LIB_OBJ) $(LOC_BIN)

