# Variables
DEF     := 
CFLAGS  := -Wall `root-config --cflags` -I $(KPIX_SW)/sidApi/offline -I $(KPIX_SW)/sidApi/online
LFLAGS  := -L$(PWD)/../bin -lsidapi `root-config --libs` -lMinuit -llockdev
CC      := g++
OUT     := $(PWD)/../bin

# Sources in the nohw directory
UTIL_SRC  := $(wildcard *.cc)
UTIL_BIN  := $(patsubst %.cc,$(OUT)/%,$(UTIL_SRC))

# Default
all: $(UTIL_BIN)

# Rule to compile
$(OUT)/%: %.cc
	$(CC) $(CFLAGS) $(LFLAGS) $(DEF) -o $@ $<

clean:
	rm -f $(UTIL_BIN)
