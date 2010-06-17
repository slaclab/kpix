# Variables
DEF     := -DONLINE_EN
CFLAGS  := -Wall `root-config --cflags` -I ../sidApi/online -I ../sidApi/offline
LFLAGS  := -L../../bin -lsidapi `root-config --libs` -lMinuit -llockdev -lXMLParser
CC      := g++
OUT     := $(PWD)/../../bin
DEP     := $(PWD)/.dep

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
