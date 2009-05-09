# Set Kpix Software Base Directory
setenv KPIX_SW /u/ey/rherbst/projects/w_si/src/kpixSw_1.01

# QT Base Directory
setenv QTDIR /afs/slac/g/reseng/qt/qt_3.3.8

# Root Base Directory
setenv ROOTSYS /afs/slac/g/reseng/root/root_5.20

# Kpix GUI Settings. run 'kpixGui -h' for more info
setenv KPIX_DEVICE   0
setenv KPIX_BASE_DIR /u1/w_si/samples/
setenv KPIX_VERSION  7
setenv KPIX_CLK_PER  50
setenv KPIX_CAL_FILE

# Setup path
if ($?PATH) then
   setenv PATH ${QTDIR}/bin:${ROOTSYS}/bin:${KPIX_SW}/bin:${PATH}
else
   setenv PATH ${QTDIR}/bin:${ROOTSYS}/bin:${KPIX_SW}/bin
endif

# Setup library path
if ($?LD_LIBRARY_PATH) then
   setenv LD_LIBRARY_PATH ${QTDIR}/lib:${ROOTSYS}/lib:${KPIX_SW}/bin:${LD_LIBRARY_PATH}
else
   setenv LD_LIBRARY_PATH ${QTDIR}/lib:${ROOTSYS}/lib:${KPIX_SW}/bin
endif

