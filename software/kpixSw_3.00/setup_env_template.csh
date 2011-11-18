# Template setup_env.csh script. You should make a copy of this and 
# rename it to setup_env.csh after checkout

# Base directory
setenv BASE ${PWD}

# QT Base Directory
setenv QTDIR   /afs/slac/g/reseng/qt/qt_4.6.3

# Root base directory
setenv ROOTSYS /afs/slac/g/reseng/root/root_5.20_x64

# Setup path
if ($?PATH) then
   setenv PATH ${BASE}/bin:${ROOTSYS}/bin:${QTDIR}/bin:${PATH}
else
   setenv PATH ${BASE}/bin:${ROOTSYS}/bin:${QTDIR}/bin
endif

# Setup library path
if ($?LD_LIBRARY_PATH) then
   setenv LD_LIBRARY_PATH ${ROOTSYS}/lib:${QTDIR}/lib:${LD_LIBRARY_PATH}
else
   setenv LD_LIBRARY_PATH ${ROOTSYS}/lib:${QTDIR}/lib
endif

