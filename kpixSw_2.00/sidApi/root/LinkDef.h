//-----------------------------------------------------------------------------
// File          : LinkDef.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 06/22/2009
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Link definition file to generating sidApi dictionary.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 06/22/2009: Created.
//-----------------------------------------------------------------------------
#pragma link off all globals;
#pragma link off all classes;
#pragma link off all functions;

#pragma link C++ nestedclasses;
#pragma link C++ nestedtypedefs;

#pragma link C++ class sidApi::offline::KpixAsic+;
#pragma link C++ class sidApi::offline::KpixCalibRead+;
#pragma link C++ class sidApi::offline::KpixEventVar+;
#pragma link C++ class sidApi::offline::KpixFpga+;
#pragma link C++ class sidApi::offline::KpixRunRead+;
#pragma link C++ class sidApi::offline::KpixRunVar+;
#pragma link C++ class sidApi::offline::KpixSample+;
#pragma link C++ class sidApi::offline::KpixThreshRead+;
#pragma link C++ class sidApi::online::KpixBunchTrain+;
#pragma link C++ class sidApi::online::KpixCalDist+;
#pragma link C++ class sidApi::online::KpixHistogram+;
#pragma link C++ class sidApi::online::KpixProgress+;
#pragma link C++ class sidApi::online::KpixRegisterTest+;
#pragma link C++ class sidApi::online::KpixRunWrite+;
#pragma link C++ class sidApi::online::KpixThreshScan+;
#pragma link C++ class sidApi::online::SidLink+;

#pragma link C++ namespace sidApi::online;
#pragma link C++ namespace sidApi::offline;
#pragma link C++ namespace sidApi;
