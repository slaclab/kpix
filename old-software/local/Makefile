# Variables
DEF     := -DONLINE_EN
CFLAGS  := -Wall `root-config --cflags` -I $(KPIX_SW)/sidApi/offline -I $(KPIX_SW)/sidApi/online
#CFLAGS  := -Wall `root-config --cflags` -I $(KPIX_SW)/sidApi/offline -I $(KPIX_SW)/sidApi/online -m32
LFLAGS  := -L$(PWD)/../kpixSw/bin -lsidapi `root-config --libs` -lMinuit -llockdev -lXMLParser
#LFLAGS  := -L$(PWD)/../kpixSw/bin -lsidapi `root-config --libs` -lMinuit -llockdev -lXMLParser -m32
CC      := g++
OUT     := $(PWD)/../kpixSw/bin

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
