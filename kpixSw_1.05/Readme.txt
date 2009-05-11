File: Readme.txt
Version: 1.05

Introduction:

   This is the current version of the KPIX Software Package. This package 
   contains two primary software blocks, the SidApi and the Kpix GUI. The
   Sid Api provides a number of classes which facilitate access to the
   KPIX hardware and its supporting FPGA. The Kpix GUI provides a user
   interface to control system, take data, perform calibrations and 
   threshold scans. The GUI also provides interactive interfaces for 
   processing the calibration, threshold scan and run data. The GUI 
   also supports external run control over a network interface.

Required Packages:

   QT and ROOT must be installed prior to compiling this package.

   QT Installation:

      QT Version 3.3.8 must be installed first. This package
      can be downloaded from the following location:

         ftp://ftp.trolltech.no/qt/source/qt-x11-free-3.3.8.tar.gz

      Once the package is downloaded and extracted it must be 
      configured with event & threading support:

         csh> ./configure -prefix /u1/local/qt_3.3.8/ -thread 

      The installation directory should be adjusted as neccessary.
      You may find it neccessary to remove other options that are not
      supported on your platform. Once configured you can build and
      install the package.

         csh> gmake
         csh> gmake install

   Root Installation:

      Root version 5.20 is installed next. This package can be 
      downloaded from the following location:

         ftp://root.cern.ch/root/root_v5.20.00.source.tar.gz

      Once the package is downloaded and extracted it must be
      configured with qt support enabled:

         csh> ./configure --enable-qt
                           --with-qt-incdir=/u1/local/qt_3.3.8/include/ 
                           --with-qt-libdir=/u1/local/qt_3.3.8/lib/
                           --disable-krb5 

      Adjust the root installation directory as neccessary. I had to disable
      krb5 to get root to compile on my machines. 

      Next compile the root package

         csh> gmake

      Before you install you must set ROOTSYS to the directory
      in which you plan to install root.

         csh> setenv ROOTSYS /u1/local/root_5.20
         csh> gmake install

Kpix Software Installation:

   Once the QT and ROOT packages are in place the Kpix Software can be
   installed. Once the tar file is extracted edit the following file
   found in the top level directory:

      setup_env.csh

   In this file set the KPIX_SW variable to the location of the top
   level directory of the Kpix Software package. 

   Next set the QTDIR variable to the location in which the QT package
   was installed (/u1/local/qt_3.3.8/).

   Next set the ROOTSYS variable to the location where the root 
   package was installed (/u1/local/root_5.20).

   Once this file has been setup if will serve as the settings file
   for this software package. Each time you logic you will need to
   type the following command from a c-shell. 

      csh> source setup_env.csh

   Once that step has been performed you can use the Kpix softare. 

   Before the Kpix software can be used it must be compiled. In
   the top level directory type the following command:

      csh> gmake

   This will compile the SidApi, the gui and any programs in the
   util directory.

   You can now start the GUI using the following command:

      csh> kpixGui

   You will see a help message which further descibes the 
   command line options and environment variable settings
   (see setup_env.csh). If you wish to perform a calibration,
   threshold scan or take data in a run type the following
   command:

      csh> kpixGui run

Directories:

   gui: 
      This directory contains the source code and makefile for the 
      KPIX GUI software. This software is written in the QT development
      environment, version 3.3.8 integrated with root version 5.20. 
      The base classes for all of the custom widgets are defined using 
      the QT designer.

   sidApi: 
      This directory contains the Sid API. This base set of classes 
      supports the low level interface to the KPIX devices and the
      support FPGA. These classes rely on root but do not have any
      know version dependencies. Three sub directories contain files
      related to the API:

      ftdi:
         This directory contains the ftdi direct USB access library.

      nohw:
         This directory contains the classes which can be used without
         any hardware dependencies. Some of these classes are stored
         in the root files to store the system configuration. Other
         classes are provided to support access to the stored classes
         and various plots. The classes in this sub directory can be 
         used within root outside of this API. This is usefull when 
         processing root files on other platforms.

      hw:
         This directory contains all other classes used in the SidApi.
         These classes can not be used outside of the SidApi 
         infrastructure. 

   bin:
      This is the directory for compiled binaries and libraries.

   util:
      This directory contains utilities which are compiled using
      the SidApi libraries. Included in this directory is a
      version of the root binary (root_sidapi) which is compiled
      with support for the SidApi classes. Also included is an 
      example file which demonstrates how to read raw event data 
      from a generated root file. New custom files can be added
      to this directoy and compiled against the SidApi using the 
      existing makefile.

