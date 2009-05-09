File: Readme.txt
Version: 1.00

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

ChangeLog:

   1.00 - 10/30/2008: 
      - Added GUI
         - Changed name of package from SidAdi to kpixSw. This name
           change reflects that addition of the GUI on top of the API.
         - Make file and directory structure of SidApi updated.
      - SidLink
         - Removed root class definition
         - Added checking for malloc errors.
      - KpixThreshScan
         - Removed root class definition
         - Added support for progress updates to calling class. Added
           iteration count run variable.
         - Added support for plot generation.
      - KpixRunWrite
         - Removed root class definition
         - Added support for calibration file string.
         - Added support for run times to be passed along.
         - Removed close function.
         - Changed treeFile to public variable.
      - KpixRegisterTest
         - Removed root class definition
         - Added support for progress update calls.
      - KpixCalDist
         - Added checking for malloc errors.
         - Removed root class definition
         - Added support for progress updates to calling class.
         - Removed fitting functions. Seperate plot & raw data enable from
           canvas and plot directory setting.
         - Moved name generation to KpixCalRead class
      - KpixBunchTrain
         - Removed root class definition
      - KpixRunRead
         - Removed root class definition
         - Tree pointer is now public for external access.
         - Kpix and FPGA classes are now loaded into local memory on open.
         - Added support for calibration timestamp string.
      - KpixFpga
         - Added method to set FPGA defaults.
         - Added method to set sidLink object.
      - KpixAsic
         - Changed timing setting readback to return trigger inhibit as
         - bunch clock counts.
         - Added method to set serial number and method to set defaults.
         - Added method to return channel count.
         - Added method to return max supported version.
         - Added method to set sidLink object.
         - Added method to get trigger inhibit time.
         - Added dac to volt conversion with double input
      - KpixCalibRead
         - Changed name from KpixCalibData
         - Changed for new calibration plot names
         - Added name and title generation methods.

   0.12 - 05/19/2008: 
      - KpixCalDist.h/KpixCalDist.cc
         - Added ability to set range for calibration fitting for each
           configured gain.

   0.11 - 02/29/2008: 
      - KpixCalDist
         - Added support for calibration plot and histogram generation 
           in addition to raw data. The resulting plots are then fit
           before being stored into root file.
      - KpixRunWrite
         - Added support for changing directories for plot storage.
      - KpixBunchTrain
         - Added badCount and empty flags to received header. Now these
           values are stored in the created sample.
      - KpixSample
         - Added badCount and empty flags.
      - KpixCalibData
         - New class to support reading of calibration data from root file.
      - KpixAsic
         - Added support for DC reset.

   0.10 - 11/15/2007: Tenth version. Changes to support KPIX 6.
      -  KpixAsic.h/KpixAsic.cc
         - Replaced threshold select and cal mask fucntions with channel 
           model selection for KPIX 6.
      -  KpixCalDist.h/KpixCalDist.cc
         - Replaced cal mask settings with channel mode setting.
      -  KpixThreshScan.h/KpixThreshScan.cc
         - Replaced cal mask settings with channel mode setting.
         - Threshold scan can now only use threshold A.

   0.9 - 10/16/2007: Ninth version. Skipped version 8 because it was 
                     distributed without a proper release.
       
      - KpixBunchTrain.h/KpixBuncTrain.cc
         - Added check for sample overrun.
         - Added external accept flag.
         - Modified format of received frame to match new format.
      - KpixCalDist.h/KpixCalDist.cc
         - Added local catching of timeout errors to allow retries.
      - KpixRegisterTest.h/KpixRegisterTest.cc
         - Fixed error in register test direction.
      - KpixCalDist.h/KpixCalDist.cc
         - Added local catching of timeout errors to allow retries.
         - Fixed broadcast of ASIC commands.
         - Added timestamp value print in debug
      - SidLink.h/SidLink.cc
         - Fixed bug which was keeping direct mode USB device 0 from working
         - Removed reset and purge from direct link open. 
         - Added direct mode access to flush. 
         - Added read/write timeout to direct mode
      - KpixAsic.h/KpixAsic.cc
         - Added ability to pass bunch clock count instead of true ns delay.
           This allows the user to keep a constant value in this field for
           different CLOCK_PERIOD settings.
      - KpixFpga.h/KpixFpga.cc
         - Added support for USB delay.
         - Added auto run type flag, added support for external run start signal.
         - Added temperature readback
         - Added raw data control flag
         - Added select polarity flag
      - KpixRunRead.h/KpixRunRead.cc
         - Fixed bug in routine to get run variable by index.

   0.7 - 05/04/2007: Seventh version. 
                     Converted to new communications protcol. 
                     Added support for multiple KPIX devices. 
                     General bugfixes. 
                     All exceptions in the API are now thrown as strings.
      - KpixBunchTrain.h/KpixBuncTrain.cc
         - Converted to new communication protocol.
         - Modified exceptions to always throw strings
         - Added local store of train number and the ability to read train number. 
         - Added ability to read dead time, parity error and last tring flags.
      - KpixCalDist.h/KpixCalDist.cc
         - Added support for multiple KPIX devices in a test. Backward compatable.
      - KpixThreshScan.h/KpixThreshScan.cc
         - Added support for multiple KPIX devices in a test. Backward compatable.
      - KpixRegisterTest.h/KpixRegisterTest.cc
         - Fixed error in debug message.
      - KpixRunWrite.h/KpixRunWrite.cc
         - Sequence number is no longer tracked by software. 
         - Added support for KpixFpga class, modified exceptions to always throw strings.
      - SidLink.h/SidLink.cc
         - Modified for new communication protocol. 
         - Modified exceptions to always throw strings.
           Removed dump from open. Added seperate dump command.
      - KpixAsic.h/KpixAsic.cc
         - Fixed bug in the setCalibMaskChan function
         - Modified for new communication protocol.
         - Added kpix version 0 for FPGA based digital core.
         - Modfied exceptions to always throw strings.
      - KpixRunRead.h/KpixRunRead.cc
         - Added method to return run duration in seconds.
         - Modified exceptions to always throw strings.
      - KpixSample.h/KpixSample.cc
         - Train number now passed during creation
         - Modified exceptions to always throw strings.

   0.6 - 04/09/2007: Sixth version of the API. Bugfixes and small changes
      - KpixRunWrite.h/KpixRunWrite.cc
         - Added internal generation of run start timestamp. 
         - Added run end timestamp to root file.
         - Constructor method was changed to remove the passing of the old
           start timestamp. 
      - KpixBunchTrain.h/KpixBunchTrain.cc
         - Fixed sorting of samples in a bunch train.
      - KpixThreshScan.h/KpixThreshScan.cc
         - Added abiity to set how pre-trigger threshold relates to
           trigger threshold during scan.
         - Added ability to choose which threshold to scan.
         - Added ability to disable charge injection during scan.
      - KpixAsic.h/KpixAsic.cc
         - Fixed bug in the setCalibMaskArray and setThreshRangeArray routines which
           could cause an error in setting the thresholds.
      - KpixRunRead.h/KpixRunWrite.cc
         - Added support for end run timestamp.
      - Example Programes:
         - calib_dist.cc:
            - Modified for new Kpix Run Write constructor
            - User is now forced to pass serial number and description as args
            - Each calibration setup is run once with forced trigger enabled and once
              with force trigger disabled.
         - thresh_scan.cc:
            - Modified for new Kpix Run Write constructor
            - User is now forced to pass serial number and description as args
            - Added call to enable/disable charge injection
            - Added call to select which threshold to use
            - Added call to set trigger/pre-trigger offset.
         - free_run.cc:
            - Modified for new Kpix Run Write constructor
            - User is now forced to pass serial number and description as args

   0.5 - 03/20/2007: Fifth release of the API. Root file Re-organization.
      - KpixAsic.h/KpixAsic.cc:
         - Added #ifdef flags to remove hardware support when not-required for analysis.
      - KpixCalDist.h/KpixCalDist.c:
         - Added EventVariables which contain the calibration charge of the 4 buckets.
         - Changed name of KpixSample to KpixBunchTrain & Changed KpixEvent to KpixSample
      - KpixEventVar.h/KpixEventVar.cc
         - Changed all stored types to Root specific types.
      - KpixRunWrite.h/KpixRunWrite.cc
         - Modifed the structure of the root file written.
         - Changed creator so that it takes the root file as an argument instead of the 
           directory.
         - Changed name of KpixSample to KpixBunchTrain & Changed KpixEvent to KpixSample
      - KpixRunRead.h/KpixRunRead.cc
         - Changed creator so that it takes the root file as an argument instead of the 
           directory.
         - Modifed the structure of the root file read.
      - KpixRunVar.h/KpixRunVar.cc
         - Changed all stored types to Root specific types.
      - KpixSample.h/KpixSample.cc
         - Changed name from KpixEvent. Changed name of internal values to match.
      - KpixBunchTrain.h/KpixBunchTrain.cc
         - Changed name from KpixSample.
      - KpixThreshScan.h/KpixThreshScan.c:
         - Added EventVariables which contain the calibration charge of the 4 buckets.
         - Changed name of KpixSample to KpixBunchTrain & Changed KpixEvent to KpixSample

   0.4 - 03/09/2007: Fourth release of the API. Root support added.
      - KpixAsic.h/KpixAsic.cc:
         - Class can now be stored in a root tree.
         - Added serial number to class.
         - Moved register data from KpixRegister class into KpixAsic class.
         - Class now contains a shadow regsiter for every address in the register
           map. This ensures compatabilty with future version of the Kpix device.
         - KpixSample class is no longer generated by the command methods of the
           KpixAsic class. This is done externally now in order to support multiple
           KPIX devices during data acquisition.
         - Remove methods for setting dac values using voltages. Added methods to
           convert dac values to voltage and back.
         - Added abilty to compute calibration charge for a bucket by passing in
           external variables. This is usefull for external tests which modify
           the calibration DAC values.
         - Added ability to dump settings in a summary print out.
      - KpixEvent.h/KpixEvent.cc:
         - Class can now be stored in a root tree.
         - Added support for sample number store. 
         - Changed names of methods use to read internal variables
         - Added ability to store a variable number of double variables. These are
           used to store changing values during runs. The key for these variables
           is stored in the KpixRunWrite class.
      - KpixSample.h/KpixSample.c
         - Added root support.
         - Class now receives sample data from the KPIX as it is created. 
         - Added sample id which when set in the class will result in associated 
           event objects also inheriting this value.
      - SidLink.h/SidLink.c
         - Added root support.
      - KpixStandardTests.h/KpixStandardTests.c
         - Class is now deleted and replaced by KpixCalDist & KpixRegisterTest classes.
      - KpixCalDist.h/KpixCalDist.c
         - Newly created class to run calibrations and distributions.
      - KpixRegisterTest.h/KpixRegisterTest.c
         - Newly created class to run a register test on the KPIX
      - KpixEventVar.h/KpixEventVar.c
         - Newly created class to act as a key for variables stored in the 
           KpixEvent class.
      - KpixRunVar.h/KpixRunVar.c
         - Newly created class to store general variables in the root file for a run.
      - KpixRunWrite.h/KpixRunWrite.c
         - Newly created class to handle the storing of run data in a root file.
      - KpixRunRead.h/KpixRunRead.c
         - Newly created class to handle the reading of run data from a root file.
      - KpixThreshScan.h/KpixThreshScan.c
         - Newly created class to perform a threshold scan ont he Kpix device.
      - root_sidapi.cc
         - Newly created source code to create a root executable with the SidApi 
           classes already compiled in. Works the same of the normal command line root program.

   0.3 - xx/xx/xxxx: Unreleased version.

   0.2 - 11/12/2006: Second release with bug fixes and minor improvements.
      - KpixAsic.h/KpixAsic.cc: 
         - Added support for neareast neighbor and double gain features introduced in KPIX4. 
         - Modifed debug statements to add 0x before all hex values printed.
         - Fixed bugs related to debug statements generated when setting DACs by voltage.
      - KpixCalibration.h/KpixCalibration.cc:
         - Modifed debug statements to add 0x before all hex values printed.
         - Changed plot to use fitted equation in gnuplot instead of computed points when
           displaying fitted line plot.
         - Added ability to add average output value to generated calibration plots.
         - Added method to compute zero crossing input charage by passing average output value.
      - KpixDistribution.h/KpixDistribution.cc:
         - Modifed debug statements to add 0x before all hex values printed.
         - Changed plot to use fitted equation in gnuplot instead of computed points when
           displaying fitted gaussian plot.
      - KpixRegister.h/KpixRegister.cc:
         - Modifed debug statements to add 0x before all hex values printed.
      - KpixSample.h/KpixSample.cc:
         - Modifed debug statements to add 0x before all hex values printed.
      - KpixStandardTests.h/KpixStandardTests.cc:
         - Modifed debug statements to add 0x before all hex values printed.
         - Added the ability to perform a force trigger average computation
           in calibration run to show zero chrage crossing on calibration plots.
         - Modified the logging method so repeated calls to log to an existing
           log file will result in new data being appended. This allows 
           the user code the option of performing and logging both test
           types a channel at a time instead performing a single test on
           all channels before moving to the second test.
      - SidLink.h/SidLink.cc:
         - Modifed debug statements to add 0x before all hex values printed.
         - Added support for linking to a KPIX analog/digital netlist level simulation.
      - example programs:
         - The programs int the "examples" directory were modified to support features added
           in the above list. See individual file headers for details.

   0.1 - 11/06/2006: Initial Release

