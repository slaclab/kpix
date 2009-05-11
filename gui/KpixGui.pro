TEMPLATE	= app
LANGUAGE	= C++

CONFIG	+= qt warn_on release thread

LIBS	+= -L../bin -lsidapi -lMinuit

DEFINES	+= ONLINE_EN

INCLUDEPATH	+= ../sidApi/online ../sidApi/offline

HEADERS	+= KpixGuiInject.h \
	KpixGuiConfig.h \
	KpixGuiFpga.h \
	KpixGuiMain.h \
	KpixGuiTiming.h \
	KpixGuiTrig.h \
	KpixGuiTop.h \
	KpixGuiError.h \
	KpixGuiRegTest.h \
	KpixGuiCalibrate.h \
	KpixGuiThreshScan.h \
	KpixGuiEventStatus.h \
	KpixGuiEventError.h \
	KpixGuiViewConfig.h \
	KpixGuiList.h \
	KpixGuiCalFit.h \
	KpixGuiRunView.h \
	KpixGuiRun.h \
	KpixGuiSampleView.h \
	KpixGuiThreshView.h \
	KpixGuiRunNetwork.h \
	KpixGuiEventData.h \
	KpixGuiStatus.h

SOURCES	+= KpixGuiInject.cc \
	KpixGuiConfig.cc \
	KpixGuiFpga.cc \
	KpixGuiMain.cc \
	KpixGuiTiming.cc \
	KpixGuiTrig.cc \
	KpixGuiTop.cc \
	KpixGuiError.cc \
	KpixGuiRegTest.cc \
	KpixGui.cc \
	KpixGuiCalibrate.cc \
	KpixGuiThreshScan.cc \
	KpixGuiEventStatus.cc \
	KpixGuiEventError.cc \
	KpixGuiViewConfig.cc \
	KpixGuiList.cc \
	KpixGuiCalFit.cc \
	KpixGuiRunView.cc \
	KpixGuiRun.cc \
	KpixGuiSampleView.cc \
	KpixGuiThreshView.cc \
	KpixGuiRunNetwork.cc \
	KpixGuiEventData.cc \
	KpixGuiStatus.cc

FORMS	= KpixGuiInjectForm.ui \
	KpixGuiConfigForm.ui \
	KpixGuiStatusForm.ui \
	KpixGuiFpgaForm.ui \
	KpixGuiListForm.ui \
	KpixGuiMainForm.ui \
	KpixGuiTopForm.ui \
	KpixGuiTimingForm.ui \
	KpixGuiTrigForm.ui \
	KpixGuiViewConfigForm.ui \
	KpixGuiErrorForm.ui \
	KpixGuiRegTestForm.ui \
	KpixGuiCalibrateForm.ui \
	KpixGuiThreshScanForm.ui \
	KpixGuiCalFitForm.ui \
	KpixGuiRunViewForm.ui \
	KpixGuiRunForm.ui \
	KpixGuiThreshViewForm.ui \
	KpixGuiSampleViewForm.ui

IMAGES	= images/editcopy \
	images/editcut \
	images/editpaste \
	images/filenew \
	images/fileopen \
	images/filesave \
	images/print \
	images/redo \
	images/searchfind \
	images/undo \
	images/filenew_1 \
	images/fileopen_1 \
	images/filesave_1 \
	images/print_1 \
	images/undo_1 \
	images/redo_1 \
	images/editcut_1 \
	images/editcopy_1 \
	images/editpaste_1 \
	images/searchfind_1 \
	images/filenew_2 \
	images/fileopen_2 \
	images/filesave_2 \
	images/print_2 \
	images/undo_2 \
	images/redo_2 \
	images/editcut_2 \
	images/editcopy_2 \
	images/editpaste_2 \
	images/searchfind_2

TARGET  = kpixGui
DESTDIR = ../bin





include("$(ROOTSYS)/include/rootcint.pri")
unix {
  UI_DIR = .ui
  MOC_DIR = .moc
  OBJECTS_DIR = .obj
}
QMAKE_CFLAGS_RELEASE -= -fno-exceptions
QMAKE_CXXFLAGS_RELEASE -= -fno-exceptions
