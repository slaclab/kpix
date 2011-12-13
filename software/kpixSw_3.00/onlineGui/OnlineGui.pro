
TEMPLATE = app
FORMS    = 
HEADERS  = ../generic/Data.h ../offline/KpixEvent.h ../offline/KpixSample.h UdpServer.h
SOURCES  = ../generic/Data.cpp ../offline/KpixEvent.cpp ../offline/KpixSample.cpp OnlineGui.cpp UdpServer.cpp
TARGET   = ../bin/onlineGui
QT       += network xml
INCLUDEPATH += ../generic/ ../offline/

QMAKE_CFLAGS   += -m32
QMAKE_CXXFLAGS += -m32
QMAKE_LFLAGS   += -m32
