
TEMPLATE = app
FORMS    = 
HEADERS  = ../generic/Data.h ../kpix/KpixEvent.h ../kpix/KpixSample.h UdpServer.h MainWindow.h
SOURCES  = ../generic/Data.cpp ../kpix/KpixEvent.cpp ../kpix/KpixSample.cpp OnlineGui.cpp UdpServer.cpp MainWindow.cpp
TARGET   = ../bin/onlineGui
QT       += network xml
INCLUDEPATH += ../generic/ ../kpix/

