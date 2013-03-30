
TEMPLATE = app
FORMS    = 
HEADERS  = ../generic/DataRead.h ../generic/Data.h ../kpix/KpixEvent.h ../kpix/KpixSample.h SharedMem.h MainWindow.h HistWindow.h KpixHistogram.h CalibWindow.h TimeWindow.h HitWindow.h ../generic/XmlVariables.h
SOURCES  = ../generic/DataRead.cpp ../generic/Data.cpp ../kpix/KpixEvent.cpp ../kpix/KpixSample.cpp OnlineGui.cpp SharedMem.cpp MainWindow.cpp HistWindow.cpp KpixHistogram.cpp CalibWindow.cpp TimeWindow.cpp HitWindow.cpp ../generic/XmlVariables.cpp
TARGET   = ../bin/onlineGui
QT       += network xml
INCLUDEPATH += ../generic/ ../kpix/ ${QWTDIR}/include ${QWTDIR} /usr/include/libxml2
LIBS        += -L${QWTDIR}/lib -lqwt -lxml2 -lz -lm
