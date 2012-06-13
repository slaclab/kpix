
TEMPLATE = app
FORMS    = 
HEADERS  = ../generic/Data.h ../kpix/KpixEvent.h ../kpix/KpixSample.h UdpServer.h MainWindow.h HistWindow.h KpixHistogram.h CalibWindow.h TimeWindow.h
SOURCES  = ../generic/Data.cpp ../kpix/KpixEvent.cpp ../kpix/KpixSample.cpp OnlineGui.cpp UdpServer.cpp MainWindow.cpp HistWindow.cpp KpixHistogram.cpp CalibWindow.cpp TimeWindow.cpp
TARGET   = ../bin/onlineGui
QT       += network xml
INCLUDEPATH += ../generic/ ../kpix/ ${QWTDIR}/include ${QWTDIR}
LIBS        += -L${QWTDIR}/lib -lqwt 

