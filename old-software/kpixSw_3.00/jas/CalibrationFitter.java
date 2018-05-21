import hep.aida.*;
import org.freehep.record.loop.AbstractLoopListener;
import org.freehep.record.loop.LoopEvent;
import org.freehep.record.loop.RecordEvent;
import org.freehep.record.loop.RecordListener;
import org.freehep.record.loop.RecordLoop;
import org.freehep.application.Application;
import org.freehep.application.studio.Studio;
import org.hep.io.kpixreader.KpixXMLRecord;
import org.hep.io.kpixreader.KpixDataRecord;
import org.hep.io.kpixreader.KpixRecord;
import org.hep.io.kpixreader.KpixSample;
import javax.xml.parsers.*;
import javax.xml.xpath.*;
import java.lang.String;
import java.util.*;
import java.util.Arrays;
import java.util.Vector;
import java.text.*;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import org.w3c.dom.*;
import org.xml.sax.SAXException;

public class CalibrationFitter extends AbstractLoopListener implements RecordListener {
   int                  _kpixCount;
   ICloud1D[][][][]     _baseLine;
   IProfile1D[][][][]   _calib;
   Boolean[]            _present;
   String[]             _serial;
   int                  _calChannel;
   int                  _calDac;
   int                  _calDacMin;
   int                  _calDacMax;
   int                  _calDacStep;
   String               _calState;
   int                  _minChan;
   int                  _maxChan;
   int                  _lastChan;
   String               _lastState;
   Boolean              _positive;
   Boolean              _b0CalibHigh;
   int[]                _injectTime;
   IAnalysisFactory     _af;
   ITree                _tree;
   IHistogramFactory    _hf;
   IFitFactory          _fitf;

   // Creator. Setup and init variables
   public CalibrationFitter() {
      
      // Set number of KPIXs to support
      _kpixCount  = 4;

      // Init variables
      _injectTime = new int[5];
      _present    = new Boolean[_kpixCount];
      _serial     = new String[_kpixCount];
      _calChannel = 0;
      _calDac     = 0;
      _calState   = "Idle";
      _lastChan   = 9999;
      _lastState  = "";
      _calDacMin  = 0;
      _calDacMax  = 0;
      _calDacStep = 0;

      // Init analysis 
      _af   = IAnalysisFactory.create();
      _tree = _af.createTreeFactory().create();
      _hf   = _af.createHistogramFactory(_tree);
      _fitf = _af.createFitFactory();

      // Data containers
      _baseLine = new ICloud1D[_kpixCount][1024][4][2];
      _calib    = new IProfile1D[_kpixCount][1024][4][2];

      // Each KPIX
      for (int k=0; k<_kpixCount; k++) {
         _present[k] = false;
         _serial[k]  = "";

         // One directory per KPIX
         _tree.mkdir("/kpix_" + String.format("%02d",k));
         _tree.mkdir("/kpix_" + String.format("%02d",k) + "/baseline");
         _tree.mkdir("/kpix_" + String.format("%02d",k) + "/calibration");

         // Set pointers to NULL for now
         for (int c=0; c<1024; c++) {
            for (int b=0; b<4; b++) {
               _baseLine[k][c][b][0] = null;
               _baseLine[k][c][b][1] = null;
               _calib[k][c][b][0] = null;
               _calib[k][c][b][1] = null;
            }
         }
      }
   }

   // Process and store configuration and status information
   public int processXml ( KpixXMLRecord xml ) {
      try {

         Document doc = xml.getParsedXML();
         XPathFactory xPathfactory = XPathFactory.newInstance();
         XPath xpath = xPathfactory.newXPath();
         XPathExpression expr;
         Object result;
         int    ret;

         // Extract Configuration
         if ( xml.getRecordType() == KpixRecord.KpixRecordType.CONFIG ) {

            // Target channel
            expr = xpath.compile("/config/UserDataA");
            result = expr.evaluate(doc, XPathConstants.STRING);
            ret = Integer.decode(String.valueOf(result));
            return(ret);
         }
      } catch (Exception e) {
         System.out.println("Ignoring XML Error: " + e );
      }
      return(-1);
   }

   /** Return computed injection charge */
   private double calibCharge(int dac, int bucket) {
      double volt;
      double charge;

      if ( dac >= 0xf6 ) volt = 2.5 - ((double)(0xff-dac))*50.0*0.0001;
      else volt =(double)dac * 100.0 * 0.0001;

      //if ( _positive ) charge = (2.5 - volt) * 200e-15;
      //else charge = volt * 200e-15;

      // Need to return charge in fC units to get fit to work
      if ( _positive ) charge = (2.5 - volt) * 200;
      else charge = volt * 200;

      if ( _b0CalibHigh && bucket == 0 ) charge *= 22.0;

      return(charge);
   }

   /** This method is called for every record read from the data source. */
   public void recordSupplied(RecordEvent re) {
      int      amplitude;
      int      channel;
      int      bucket;
      int      time;
      int      addr;
      int      pt;
      double[] xEdges;
      int      xSize;
      int      x;
      int      y;
      int      range;
      String   tString;
    
      // Ignore records unless they are KPIX events
      Object record = re.getRecord();
      if (! (record instanceof KpixRecord)) return;
      KpixRecord event = (KpixRecord) record;
    
      // Process XML records
      if (record instanceof KpixXMLRecord) processXml((KpixXMLRecord)event);

      // Ignore all KPIX events except data records
      if (! (record instanceof KpixDataRecord)) return;
      KpixDataRecord data = (KpixDataRecord) event;
    
      // Show read status
      if ( _lastChan != _calChannel || ! _calState.equals(_lastState) ) {
         _lastChan  = _calChannel;
         _lastState = _calState;
         System.out.println("Reading data. State: " + _lastState + " Channel: " + _lastChan);
      }

      // Loop over samples in the data and fill fistograms
      for (KpixSample sample : data.getSamples()) {
      
         // Apply cuts :
         if (sample.isBadEvent() || sample.isEmpty()) continue;

         // Processing ADC samples
         if (sample.getType() == KpixSample.KpixSampleType.KPIX) {
            amplitude = sample.getAdc();
            channel   = sample.getChannel();
            bucket    = sample.getBucket();
            time      = sample.getTime();
            addr      = sample.getAddress();

            // Determine range
            if (sample.getAdcRange() == KpixSample.ADCRange.LOWGAIN) range = 1;
            else range = 0;

            // Filter for time
            if ( time > _injectTime[bucket] && time < _injectTime[bucket+1] ) {

               // Baseline fill
               if ( _calState.equals("Baseline") ) {

                  // Create histogram if it does not exist.
                  if ( _baseLine[addr][channel][bucket][range] == null ) {
                     _tree.cd("/kpix_" + String.format("%02d",addr) + "/baseline");
                     _baseLine[addr][channel][bucket][range] =
                        _hf.createCloud1D("Channel_" + String.format("%04d",channel) + "_" + bucket + "_" + range);
                  }
                  
                  // Fill baseline data
                  _baseLine[addr][channel][bucket][range].fill(amplitude);
               }

               // Inject curve
               if ( _calState.equals("Inject") && _calChannel == channel ) {

                  // Create histogram if it does not exist.
                  if ( _calib[addr][channel][bucket][range] == null ) {

                     // Setup bins to match calibration settings
                     xSize = (((_calDacMax - _calDacMin) + 1) / _calDacStep);
                     xEdges = new double[xSize];
                     y = 0;
                     for (x=_calDacMin; x < _calDacMax; x = x+_calDacStep) xEdges[y++] = calibCharge(x,bucket);
                     Arrays.sort(xEdges);

                     // Create histogram
                     _tree.cd("/kpix_" + String.format("%02d",addr) + "/calibration");
                     tString = "Channel_" + String.format("%04d",channel) + "_" + bucket + "_" + range;
                     _calib[addr][channel][bucket][range] = _hf.createProfile1D(tString,tString,xEdges);
                  }

                  // Add point
                  _calib[addr][channel][bucket][range].fill(calibCharge(_calDac,bucket),amplitude);
               }
            }
         }
      }
   }

   /** This method is called at the start of an analysis session. */
   protected void start(LoopEvent event) {
      _lastChan   = 9999;
      _lastState  = "";

      System.out.println("Init data structures");

      for (int k=0; k<_kpixCount; k++) {
         _present[k] = false;
         _serial[k]  = "";
         for (int c=0; c<1024; c++) {
            for (int b=0; b<4; b++) {
               _baseLine[k][c][b][0] = null;
               _baseLine[k][c][b][1] = null;
               _calib[k][c][b][0] = null;
               _calib[k][c][b][1] = null;
            }
         }
      }
   }
  
   /** This method is called at the end of an analysis session. */
   protected void finish(LoopEvent event) {
      IFitResult       fithr;
      IFitResult       fitcr;
      IHistogram1D     hist;
      int              binl;
      int              binh;
      int              binc;
      double[]         fitPars;
      double[]         fitParErrs;
      IFitData         data;
      PrintStream      out;
      String           outName;
      Date             dNow;
      SimpleDateFormat ft;
      String           chanString;
      String           bucketString;
      String           rangeString;

      // Attempt to fine source name
      RecordLoop loop = (RecordLoop) 
         ((Studio)(Application.getApplication())).getLookup().lookup(RecordLoop.class);
      outName = loop.getRecordSource().getName() + ".xml";

      // Open the file
      try {
         out = new PrintStream(new FileOutputStream(outName));
      } catch (FileNotFoundException e) {
         System.out.println("Failed to open output file: " + outName);
         return;
      }

      // Start file
      out.println("<calibrationData>");

      // Add notes
      out.println("   <sourceFile></sourceFile>");
      out.println("   <user>" + System.getProperty("user.name") + "</user>");
      //out.println("   <r0MinFit>" + fitMin[0] + "</r0MinFit>");
      //out.println("   <r0MaxFit>" + fitMax[0] + "</r0MaxFit>");
      //out.println("   <r1MinFit>" + fitMin[1] + "</r1MinFit>");
      //out.println("   <r1MaxFit>" + fitMax[1] + "</r1MaxFit>");

      // Add timestamp
      dNow = new Date();
      ft = new SimpleDateFormat ("yyyy_MM_dd_HH_mm_ss");
      out.println("   <timestamp>" + ft.format(dNow) + "</timestamp>");

      // Create fitters for baseline and calibration
      IFitter fith = _fitf.createFitter("Chi2");
      IFitter fitc = _fitf.createFitter("Chi2","jminuit");

      // Each kpix if enabled
      for (int k=0; k<_kpixCount; k++) {
         if ( _present[k] ) {
            System.out.println("Fitting plots for kpix " + k + " Serial " + _serial[k]);

            // Add KPIX to XML
            out.println("   <kpixAsic id=\"" + _serial[k] + "\">");

            // Each channel
            for (int c=0; c<1024; c++) {
               chanString = ""; 

               // Each bucket
               for (int b=0; b<4; b++) {
                  bucketString = "";

                  // Each range
                  for (int r=0; r<2; r++) {
                     rangeString = "";

                     // Baseline data exists
                     if ( _baseLine[k][c][b][r] != null ) {

                        // Convert cloud to histogram
                        binl = (int)_baseLine[k][c][b][r].lowerEdge() - 1;
                        binh = (int)_baseLine[k][c][b][r].upperEdge() + 1;
                        binc = (binh - binl);
                        _baseLine[k][c][b][r].convert(binc,binl,binh);

                        // Fit histogram
                        fithr      = fith.fit(_baseLine[k][c][b][r].histogram(),"g");
                        fitPars    = fithr.fittedParameters();
                        fitParErrs = fithr.errors();

                        // Get histogram values
                        rangeString += genXml(15,"BaseMean",_baseLine[k][c][b][r].mean());
                        rangeString += genXml(15,"BaseRms",_baseLine[k][c][b][r].rms());
                        rangeString += genXml(15,"BaseFitMean",fitPars[1]);
                        rangeString += genXml(15,"BaseFitSigma",fitPars[2]);
                        rangeString += genXml(15,"BaseFitMeanErr",fitParErrs[1]);
                        rangeString += genXml(15,"BaseFitSigmaErr",fitParErrs[2]);
                     }

                     // Calibration data exists
                     if ( _calib[k][c][b][r] != null ) {

                        // Fit curve
                        fitcr      = fitc.fit(_calib[k][c][b][r],"p1");
                        fitPars    = fitcr.fittedParameters();
                        fitParErrs = fitcr.errors();

                        // Get calibration values
                        rangeString += genXml(15,"CalibGain",fitPars[1] * 1e15);
                        rangeString += genXml(15,"CalibIntercept",fitPars[0]);
                        rangeString += genXml(15,"CalibGainErr",fitParErrs[1] * 1e15);
                        rangeString += genXml(15,"CalibInterceptErr",fitParErrs[0]);
                        //rangeString += genXml(,15,"CalibGainRms",0); // Not sure how to get proper linear fit RMS

                        // Display the results
                        if ( k == 0 && c == 0 && b == 0 && r == 0 ) {
                           IPlotter plotter = _af.createPlotterFactory().create("Fit and Plot an IProfile");
                           plotter.createRegions(1,1);
                           plotter.region(0).plot( _calib[k][c][b][r] );
                           plotter.region(0).plot( fitcr.fittedFunction() );
                           plotter.show();
                        }
                     }

                     // End range
                     if ( ! rangeString.equals("") ) {
                        bucketString += "            <Range id=\"" + r + "\">\n";
                        bucketString += rangeString;
                        bucketString += "            </Range>\n";
                     }
                  }

                  // End bucket
                  if ( ! bucketString.equals("") ) {
                     chanString += "         <Bucket id=\"" + b + "\">\n";
                     chanString += bucketString;
                     chanString += "         </Bucket>\n";
                  }
               }

               // End channel
               if ( ! chanString.equals("") ) {
                  out.println("      <Channel id=\"" + c + "\">");
                  out.println("         <BadChannel>0</BadChannel>");
                  out.println(chanString + "      </Channel>");
               }
            }

            // Close ASIC
            out.println("   </kpixAsic>");
         }
      }

      // End file
      out.println("</calibrationData>");
      out.close();

      // This is how you print to Jas3 console:
      System.out.println("Write data to: " + outName);
      System.out.println("Finished analysis");
   }

   // Generate XML string
   private static String genXml ( int indent, String tag, double value ) {
      String ret = "";

      if ( ! Double.isNaN(value) ) {
         for (int x=0; x < indent; x++) ret += " ";
         ret += "<" + tag + ">" + value + "</" + tag + ">\n";
      }
      return(ret);
   }

   // Avoid error on load 
   public static void main (String [] args) {
   }
}

