void KpixAsic::getStatus ( bool *cmdPerr, bool *dataPerr, bool *tempEn, unsigned char *tempValue, bool readEn ) {

   // Get values, read once only
   *cmdPerr   = regGetBit(0x00,0,readEn);
   *dataPerr  = regGetBit(0x00,1,false);
   *tempEn    = regGetBit(0x00,2,false);
   *tempValue = (regGetValue(0x00,false) >> 24) & 0xFF;

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getStatus -> read status:";
      cout << " CmdPerr  = " << *cmdPerr;
      cout << ", DataPerr = " << *dataPerr;
      cout << ", TempEn = " << *tempEn;
      cout << ", TempValue = " << dec << (int)(*tempValue) << "\n";
   }
}







// Class Method To Convert DAC value to voltage
double KpixAsic::dacToVolt(unsigned char dacValue) {

   // Convert value
   if ( dacValue >= 0xf6 ) return(2.5 - ((double)(0xff-dacValue))*50.0*0.0001);
   else return((double)dacValue * 100.0 * 0.0001);
}


// Class Method To Convert DAC value to voltage
double KpixAsic::dacToVolt(double dacValue) {

   // Convert value
   if ( dacValue >= 246.0 ) return(2.5 - (255.0-dacValue)*50.0*0.0001);
   else return((double)dacValue * 100.0 * 0.0001);
}


// Convert DAC voltage to value
unsigned char KpixAsic::voltToDac ( double dacVoltage ) {

   // Verify range
   if ( dacVoltage > 2.5 || dacVoltage < 0 ) 
      throw string("KpixAsic::voltToDac -> Voltage Out Of Range");

   // Upper values are 5mv steps
   if ( dacVoltage > 2.45 ) return(0xff - (int)((2.5 - dacVoltage) / 0.0050));

   // Lower values are 10mv steps
   else return((unsigned char)(dacVoltage / 0.01));
}


// Class Method to retrieve the current value of the calibration charge
// For settings provided by external code.
// Pass the following values
// bucket    - Bucket number for conversion
// calDac    - Calibration DAC value
// posPixel  - State of posPixel flag
// calibHigh - State of high range calibration flag
double KpixAsic::computeCalibCharge ( unsigned char bucket, unsigned char calDac,
                                             bool posPixel,  bool calibHigh ) {

   double temp;
   double charge;

   // Get value from DAC4 register
   temp = dacToVolt(calDac);

   // Compute charge based on posPix
   if ( posPixel ) charge = (2.5 - temp) * 200e-15;
   else charge = temp * 200e-15;

   // Expanded range for channel 0
   if ( bucket == 0 && calibHigh ) charge = charge * 22;
   return(charge);
}


// Method to retrieve the current value of the calibration charges
// This method will determine the calibartion charge for each 
// bucket based upon the current settings of the Kpix ASIC.
// Pass 4 position array to store values
void KpixAsic::getCalibCharges ( double calCharge[] ) {

   unsigned char x;
   unsigned char calDac;
   bool          posPixel;
   bool          calibHigh;

   // get configuration state
   calDac    = getDacCalib(false);
   posPixel  = getCntrlPosPixel(false);
   calibHigh = getCntrlCalibHigh(false);

   // Get Charge for each bucket
   for (x=0; x < 4; x++) 
      calCharge[x] = computeCalibCharge(x,calDac,posPixel,calibHigh);
}


// Deconstructor
KpixAsic::~KpixAsic ( ) { }


// Turn on or off debugging for the class
void KpixAsic::kpixDebug ( bool debug ) { 

   // Debug if enabled
   if ( enDebug ) 
      cout << "KpixAsic::kpixDebug -> updating debug to " << debug << "\n";
   else if ( debug ) 
      cout << "KpixAsic::kpixDebug -> enabling debug\n";

   // Local debug flag
   enDebug = debug;
}


// Get debug flag
bool KpixAsic::kpixDebug ( ) { return(enDebug); }


// Return current KPIX Version
unsigned short KpixAsic::getVersion ( ) { return(kpixVersion); }

// Return current KPIX Address
unsigned short KpixAsic::getAddress ( ) { return(kpixAddress); }

// Return current KPIX Serial Number
unsigned short KpixAsic::getSerial ( ) { return(kpixSerial); }

// Change KPIX Serial Number
void KpixAsic::setSerial ( unsigned short serial ) { kpixSerial=serial; }

#ifdef ONLINE_EN
// Return SID Link Object Pointer
SidLink * KpixAsic::getSidLink () { return(sidLink); }
#endif


// Set Defaults
// Pass clock period to use
void KpixAsic::setDefaults ( unsigned int clkPeriod, bool writeEn ) {

   unsigned int x;
   KpixChanMode modes[1024];

   // Configure Control Registers
   setCfgTestData       ( false,          false   );
   setCfgAutoReadDis    ( false,          false   );
   setCfgForceTemp      ( false,          false   );
   setCfgDisableTemp    ( false,          false   );
   setCfgAutoStatus     ( false,          writeEn );
   setCntrlCalibHigh    ( false,          false   );
   setCntrlCalDacInt    ( true,           false   );
   setCntrlForceLowGain ( false,          false   );
   setCntrlLeakNullDis  ( true,           false   );
   setCntrlDoubleGain   ( false,          false   );
   setCntrlNearNeighbor ( false,          false   );
   setCntrlPosPixel     ( true,           false   );
   setCntrlDisPerRst    ( true,           false   );
   setCntrlEnDcRst      ( true,           false   );
   setCntrlCalSrc       ( KpixDisable,    false   );
   setCntrlTrigSrc      ( KpixDisable,    false   );
   setCntrlShortIntEn   ( false,          false   );
   setCntrlDisPwrCycle  ( false,          false   );
   setCntrlFeCurr       ( FeCurr_121uA,   false   );
   setCntrlHoldTime     ( HoldTime_64x,   false   );
   setCntrlTrigDisable  ( true,           false   );
   setCntrlMonSrc       ( KpixMonNone,    writeEn );

   // Set timing values
   setTiming ( clkPeriod, // Clock Period
               700,       // Reset On Time
               120000,    // Reset off Time
               200,       // Leakage Null Off
               100500,    // Offset Null Off
               101500,    // Thresh Off
               0,         // Trig Inhibit Off (bunch periods)
               900,       // Power Up On
               6900,      // Desel Sequence
               467500,    // Bunch Clock Delay
               10000,     // Digitization Delay
               2890,      // Bunch Clock Count
               true,      // Checking Enable
               writeEn
             );

   // Setup DACs
   setDacCalib          ( (unsigned char)0x00, writeEn );
   setDacRampThresh     ( (unsigned char)0xE0, writeEn );
   setDacRangeThresh    ( (unsigned char)0x00, writeEn );
   setDacDefaultAnalog  ( (unsigned char)0xBD, writeEn );
   setDacEventThreshRef ( (unsigned char)0x50, writeEn );
   setDacShaperBias     ( (unsigned char)0x78, writeEn );

   // Set Threshold DACs
   setDacThreshRangeA ( (unsigned char)0x00, // Range A Reset Inhibit Threshold
                        (unsigned char)0x00, // Range A Trigger Threshold
                        writeEn);
   setDacThreshRangeB ( (unsigned char)0x00, // Range A Reset Inhibit Threshold
                        (unsigned char)0x00, // Range A Trigger Threshold
                        writeEn);

   // Init Channel Modes
   for(x=0; x < 1024; x++) modes[x] = KpixChanDisable;
   setChannelModeArray(modes,writeEn);

   // Setup calibration strobes
   setCalibTime ( 4,      // Calibration Count
                  0x28A,  // Calibration 0 Delay
                  0x28A,  // Calibration 1 Delay
                  0x28A,  // Calibration 2 Delay
                  0x28A,  // Calibration 3 Delay
                  writeEn);
}


// Read from all registers will debug enabled to display all of the current settings
void KpixAsic::dumpSettings () {

   unsigned int  clkPeriod;
   unsigned int  resetOn;
   unsigned int  resetOff;
   unsigned int  leakNullOff;
   unsigned int  offNullOff;
   unsigned int  threshOff;
   unsigned int  trigInhOff;
   unsigned int  pwrUpOn;
   unsigned int  deselDly;
   unsigned int  bunchClkDly;
   unsigned int  digDelay;
   unsigned int  bunchCount;
   unsigned int  calCount;
   unsigned int  cal0Delay;
   unsigned int  cal1Delay;
   unsigned int  cal2Delay;
   unsigned int  cal3Delay;
   unsigned char rstTholdA;
   unsigned char trigTholdA;
   unsigned char rstTholdB;
   unsigned char trigTholdB;
   KpixChanMode  modes[1024];
   unsigned int  x;

   // Get some values
   getTiming ( &clkPeriod,  &resetOn, &resetOff,   &leakNullOff,
               &offNullOff, &threshOff, &trigInhOff, &pwrUpOn,
               &deselDly,   &bunchClkDly, &digDelay, &bunchCount, false, false);
   getCalibTime ( &calCount, &cal0Delay, &cal1Delay, &cal2Delay, &cal3Delay, false );
   getDacThreshRangeA ( &rstTholdA, &trigTholdA, false );
   getDacThreshRangeB ( &rstTholdB, &trigTholdB, false );

   // Display data
   cout << "       KpixAddress = " << dec << kpixAddress << "\n";
   cout << "        KpixSerial = " << dec << kpixSerial  << "\n";
   cout << "       KpixVersion = " << dec << kpixVersion << "\n";
   cout << "       CfgTestData = " << getCfgTestData(false) << "\n";
   cout << "    CfgAutoReadDis = " << getCfgAutoReadDis(false) << "\n";
   cout << "      CfgForceTemp = " << getCfgForceTemp(false) << "\n";
   cout << "    CfgDisableTemp = " << getCfgDisableTemp(false) << "\n";
   cout << "     CfgAutoStatus = " << getCfgAutoStatus(false) << "\n";
   cout << "     CntrlHoldTime = " << getCntrlHoldTime(false) << "\n";
   cout << "    CntrlCalibHigh = " << getCntrlCalibHigh(false) << "\n";
   cout << "    CntrlCalDacInt = " << getCntrlCalDacInt(false) << "\n";
   cout << " CntrlForceLowGain = " << getCntrlForceLowGain(false) << "\n";
   cout << "  CntrlLeakNullDis = " << getCntrlLeakNullDis(false) << "\n";
   cout << "     CntrlPosPixel = " << getCntrlPosPixel(false) << "\n";
   cout << "       CntrlCalSrc = " << getCntrlCalSrc(false) << "\n";
   cout << "      CntrlTrigSrc = " << getCntrlTrigSrc(false) << "\n";
   cout << " CntrlNearNeighbor = " << getCntrlNearNeighbor(false) << "\n";
   cout << "   CntrlDoubleGain = " << getCntrlDoubleGain(false) << "\n";
   cout << "    CntrlDisPerRst = " << getCntrlDisPerRst(false) << "\n";
   cout << "      CntrlEnDcRst = " << getCntrlEnDcRst(false) << "\n";
   cout << "   CntrlShortIntEn = " << getCntrlShortIntEn(false) << "\n";
   cout << "  CntrlDisPwrCycle = " << getCntrlDisPwrCycle(false) << "\n";
   cout << "       CntrlFeCurr = " << getCntrlFeCurr(false) << "\n";
   cout << "  CntrlTrigDisable = " << getCntrlTrigDisable(false) << "\n";
   cout << "       CntrlMonSrc = " << getCntrlMonSrc(false) << "\n";
   cout << "          DacCalib = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacCalib(false) << "\n";
   cout << "     DacRampThresh = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacRampThresh(false) << "\n";
   cout << "    DacRangeThresh = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacRangeThresh(false) << "\n";
   cout << " DacEventThreshRef = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacEventThreshRef(false) << "\n";
   cout << "     DacShaperBias = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacShaperBias(false) << "\n";
   cout << "  DacDefaultAnalog = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacDefaultAnalog(false) << "\n";
   cout << "         ClkPeriod = " << dec << clkPeriod << "ns\n";
   cout << "           ResetOn = " << dec << resetOn << "ns\n";
   cout << "          ResetOff = " << dec << resetOff << "ns\n";
   cout << "       LeakNullOff = " << dec << leakNullOff << "ns\n";
   cout << "        OffNullOff = " << dec << offNullOff << "ns\n";
   cout << "         ThreshOff = " << dec << threshOff << "ns\n";
   cout << "        TrigInhOff = " << dec << trigInhOff << "(bunch clock)\n";
   cout << "        TrigInhOff = " << dec << getTrigInh ( false, true ) << "ns\n";
   cout << "           PwrUpOn = " << dec << pwrUpOn << "ns\n";
   cout << "          DeselDly = " << dec << deselDly << "ns\n";
   cout << "       BunchClkDly = " << dec << bunchClkDly << "ns\n";
   cout << "          DigDelay = " << dec << digDelay << "ns\n";
   cout << "        BunchCount = " << dec << bunchCount << "\n";
   cout << "          CalCount = " << dec << setw(1) << setfill('0') << (int)calCount << "\n";
   cout << "         Cal0Delay = 0x" << hex << setw(3) << setfill('0') << cal0Delay << "\n";
   cout << "         Cal1Delay = 0x" << hex << setw(3) << setfill('0') << cal1Delay << "\n";
   cout << "         Cal2Delay = 0x" << hex << setw(3) << setfill('0') << cal2Delay << "\n";
   cout << "         Cal3Delay = 0x" << hex << setw(3) << setfill('0') << cal3Delay << "\n";
   cout << "         RstTholdA = 0x" << hex << setw(2) << setfill('0') << (int)rstTholdA << "\n";
   cout << "        TrigTholdA = 0x" << hex << setw(2) << setfill('0') << (int)trigTholdA << "\n";
   cout << "         RstTholdB = 0x" << hex << setw(2) << setfill('0') << (int)rstTholdB << "\n";
   cout << "        TrigTholdB = 0x" << hex << setw(2) << setfill('0') << (int)trigTholdB << "\n";

   // Get channel modes
   getChannelModeArray(modes,false);
   for ( x=0; x < getChCount(); x++) {
      if ( x % 32 == 0 ) {
         cout << " Chan Mode ";
         cout << dec << setfill('0') << setw(3) << x;
         cout << ":";
         cout << dec << setfill('0') << setw(3) << x+31;
         cout << " = ";
      }
      if ( x % 4 == 0 && x % 32 != 0 ) cout << " ";
      if ( modes[x] == KpixChanDisable    ) cout << "D";
      if ( modes[x] == KpixChanThreshACal ) cout << "C";
      if ( modes[x] == KpixChanThreshA    ) cout << "A";
      if ( modes[x] == KpixChanThreshB    ) cout << "B";
      if ( x % 32 == 31 ) cout << "\n";
   }
}


// Get Channel COunt
unsigned int KpixAsic::getChCount() { 
   if ( kpixVersion < 8 ) return(64);
   if ( kpixVersion < 9 ) return(256);
   if ( kpixVersion < 10 ) return(512);
   else return(1024);
}


// Class Method To Convert DAC value to temperature
double KpixAsic::convertTemp(unsigned int tempAdc, unsigned int* decimalValue) {
   int    g[8];
   int    d[8];
   int    de;
   int    i;
   double temp;

   // Convert number to binary
   for (i=7; i >= 0; i--) {
      if ( tempAdc >= (unsigned int)pow(2,i) ) {
         g[i] = 1;
         tempAdc -= (unsigned int)pow(2,i);
      }
      else g[i] = 0;
   }

   // Convert grey code to decimal
   d[7] = g[7];
   for (i=6; i >= 0; i--) d[i]=d[i+1]^g[i];

   // Convert back to an integer
   de = 0;
   for (i=0; i<8; i++) if ( d[i] != 0 ) de += (int)pow(2,i);
   cout << "Decimal=0x" << hex << de << "," << dec << de << endl;

   // Convert to temperature
   temp=-30.2+127.45/233*(255-de-20.75);
   //if ( (object)decimalValue != NULL ) { 
   if ( decimalValue != NULL ) { 
	   decimalValue = (unsigned int*) (255 - de); 
	   //cout << "in decimal: " << dec << decimalValue << endl;
	   }
   return(temp);
}
