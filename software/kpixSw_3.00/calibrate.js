// gui.setValue         ( name, value );            // Set variable value
// gui.sendCommand      ( command, arg );           // Send command
// gui.setDefaults      ();                         // Set defaults
// gui.loadConfig       ( file );                   // Load configuration from file
// gui.saveConfig       ( file );                   // Save configuration to file
// gui.openFile         ( file );                   // Open data file
// gui.closeFile        ();                         // Close data file
// gui.setRunParameters ( period, count, command ); // Set run parameters (period in uS)
// gui.setRunWait       ( uint time );              // Set time before run start (in mS, min=1mS)
// gui.iter             ( );                        // Returns iteration count

// Run baseline and calibrations
//gui.setDefaults();
gui.setRunParameters(10000,4000,"ApvSWTrig");
gui.setRunWait(1000);

print("Starting Calibration.");

// Before run callback
gui.run = function () {
   gui.closeFile();

   // Done after 9 iterations
   if ( gui.iter() >= 9 ) {
      print("Done.");
      return(0); // Stop run
   }

   if ( gui.iter() == 8 ) {
      gui.setValue("cntrlFpga:hybrid:apv25:CalibInhibit","True");
      gui.setValue("cntrlFpga:hybrid:apv25:CalGroup","0");
      gui.openFile("data/cms_01_baseline.bin");
      print("Running baseline");
   }
   else {
      gui.setValue("cntrlFpga:hybrid:apv25:CalibInhibit","False");
      gui.setValue("cntrlFpga:hybrid:apv25:CalGroup",gui.iter());
      gui.openFile("data/cms_01_cal_" + gui.iter() + ".bin");
      print("Running cal. Group: " + gui.iter());
   }

   return (1); // Start run
}

