
# Make sub directories
all:
	cd sidApi; gmake dep
	cd sidApi; gmake
	cd gui; qmake
	cd gui; gmake
	cd util; gmake

# Clean sub directories
clean:
	cd sidApi; gmake clean
	cd gui; qmake
	cd gui; gmake clean
	cd util; gmake clean
	/bin/rm -f bin/*
