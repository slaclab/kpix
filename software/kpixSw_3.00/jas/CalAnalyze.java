
import hep.aida.*;
import org.freehep.record.loop.AbstractLoopListener;
import org.freehep.record.loop.LoopEvent;
import org.freehep.record.loop.RecordEvent;
import org.freehep.record.loop.RecordListener;
import org.hep.io.kpixreader.KpixDataRecord;
import org.hep.io.kpixreader.KpixRecord;
import org.hep.io.kpixreader.KpixSample;
import org.hep.io.kpixreader.calibration.KpixCalibrationSet;
import org.hep.io.kpixreader.calibration.KpixCalibration;
import org.hep.io.kpixreader.calibration.KpixCalibrationException;
import java.io.PrintStream;

public class CalAnalyze extends AbstractLoopListener implements RecordListener {

    int n_Sensors = 9;
    int n_data_records = 0;
    int EventNumber;
    int calChan = 0;
    int calIndex;
    int sensor_index;
    int Sensor_Address;
    int KPiX_Bucket;
    int KPiX_Channel;
    double Cal_Amplitude;
    int Bunch_Time;
    int nhits_cut = 200;
    double Cal_Amplitude_min = -1000;
    double Cal_Amplitude_max = 1000;
    boolean hits_ok;
    boolean trigger_ok;
    boolean sensor_first_last;
    int N_Triggers;
    int TS_Max = 10;
    double Cal_Amplitude_Droop_Offset = 0.;
    int Bunch_Trigger_Time_min = 1;
    int Bunch_Trigger_Time_max = 4; // use > < for test
    int nprinted = 0;
    int nprinted_max = 25;
    boolean[][] bad_pixels = new boolean[n_Sensors][1024];
    IHistogram1D _Empty_Sensor_Hist;
    IHistogram1D _isBad_Calibration_Hist;
    ICloud1D _TriggerTime_Hist;
    IHistogram1D _Coincidence_Hist;
    IHistogram1D _N_Triggers_Hist;
    IHistogram1D _BunchTriggerDiff_Hist;
    IHistogram1D[] _temperatureHist;
    IHistogram1D[] _Sensor_Amplitude_Hist;
    IHistogram1D[] _Cut_CalibGainHist;
    IHistogram1D[] _CalibGainHist;
    IHistogram1D[] _CalibGainErrHist;
    ICloud1D[] _CalibInterceptHist;
    IHistogram1D[] _CalibInterceptBaseDifferenceHist;
    ICloud1D _Total_Deposited_Energy_Hist;
    ICloud1D[] _BaseFitMeanHist;
    IHistogram1D[] _HitsBySensorHist;
    IHistogram1D[] _inTime_HitsBySensor_Hist;
    IHistogram2D _Total_Energy_By_Sensor;
    IHistogram2D[] _Pixel_Dist_Hist;
    ICloud1D _calAmplitudeHist;
    ICloud1D _nhitshist;
    IHistogram2D _NaN_Sensor_Channel;
    PrintStream out;
    IAnalysisFactory af = IAnalysisFactory.create();
    ITree tree = af.createTreeFactory().create();
    IHistogramFactory hf = af.createHistogramFactory(tree);

    public CalAnalyze() {


        _Empty_Sensor_Hist = hf.createHistogram1D("N empty sensors per record", 32, 0, 31);
        _isBad_Calibration_Hist = hf.createHistogram1D("Count of isBad Pixels", 32, 0, 31);
        _TriggerTime_Hist = hf.createCloud1D("Trigger Time");
        _N_Triggers_Hist = hf.createHistogram1D("N Triggers", 10, 0, 9);
        _Coincidence_Hist = hf.createHistogram1D("Sensor Coincidences", 10, 1, 10);
        _BunchTriggerDiff_Hist = hf.createHistogram1D("Bunch - Trigger Time", 201, -100, 100);
        _Cut_CalibGainHist = new IHistogram1D[n_Sensors];
        _CalibGainHist = new IHistogram1D[n_Sensors];
        _CalibInterceptHist = new ICloud1D[n_Sensors];
        _BaseFitMeanHist = new ICloud1D[n_Sensors];
        _CalibGainErrHist = new IHistogram1D[n_Sensors];
        _HitsBySensorHist = new IHistogram1D[n_Sensors];
        _inTime_HitsBySensor_Hist = new IHistogram1D[n_Sensors];
        _temperatureHist = new IHistogram1D[n_Sensors];
        _Sensor_Amplitude_Hist = new IHistogram1D[n_Sensors];
        _CalibInterceptBaseDifferenceHist = new IHistogram1D[n_Sensors];
        _Total_Energy_By_Sensor = hf.createHistogram2D("Energy by Sensor", 32, 0, 31, 200, -400, 400);
        _Total_Deposited_Energy_Hist = hf.createCloud1D("Total Deposited Energy");
        _calAmplitudeHist = hf.createCloud1D("Calibrated Amplitude");
        _nhitshist = hf.createCloud1D("Uncuts nhits per event");
        _NaN_Sensor_Channel = hf.createHistogram2D("NaN Sensor, Channel", n_Sensors, 0, n_Sensors, 1024, 0, 1024);
        _Pixel_Dist_Hist = new IHistogram2D[n_Sensors];

        tree.mkdir("/Calibrations");
        tree.cd("/Calibrations");
        for (int i = 0; i < n_Sensors; i++) {
            _CalibGainHist[i] = hf.createHistogram1D("Calib Gain Sensor " + i, 200, 1e15, 10e15);
            _CalibInterceptHist[i] = hf.createCloud1D("Calibration Intercept Sensor" + i);
            _CalibGainErrHist[i] = hf.createHistogram1D("Calbirated Gain Error Sensor" + i, 100, 1e13, 50e13);
            _CalibInterceptBaseDifferenceHist[i] = hf.createHistogram1D("Calibration Intercept - Base Difference Sensor" + i, 100, -10, 90);
            _BaseFitMeanHist[i] = hf.createCloud1D("Base Fit Mean Sensor" + i);
            _Cut_CalibGainHist[i] = hf.createHistogram1D("Cut Calibration Gain Sensor " + i, 200, 1e15, 10e15);

        }
        tree.mkdir("/Sensor Data");
        tree.cd("/Sensor Data");
        for (int k = 0; k < n_Sensors; k++) {
            _HitsBySensorHist[k] = hf.createHistogram1D("Uncut Hits of Sensor " + k, 200, 0, 199);
            _inTime_HitsBySensor_Hist[k] = hf.createHistogram1D("inTime Hits of Sensor " + k, 100, 0, 99);
            _temperatureHist[k] = hf.createHistogram1D("Temperature History" + k, 100, 0, 100);
            _Sensor_Amplitude_Hist[k] = hf.createHistogram1D("Final Amplitude Dist Sensor " + k, 100, -10, 100);
            _Pixel_Dist_Hist[k] = hf.createHistogram2D("Pixel map Sensor " + k, 32, 0, 32, 32, 0, 32);
        }
    }

    /**
     * This method is called for every record read from the data source.
     */
    public void recordSupplied(RecordEvent re) {

        // Ignore records unless they are KPIX events

        Object record = re.getRecord();
        if (!(record instanceof KpixRecord)) {
            return;
        }
        KpixRecord event = (KpixRecord) record;

        // For now, also ignore all KPIX events except data records

        if (!(record instanceof KpixDataRecord)) {
            return;
        }
        KpixDataRecord data = (KpixDataRecord) event;
        //
        // on first time in, look at calibration
        //
        if (n_data_records == 0) {
            CalibrationAnalysis(data);
        }
        n_data_records++;
        hits_ok = false;
        trigger_ok = false;
        sensor_first_last = false;
        EventNumber = data.getEventNumber();
        //Count hits in this Sample, require less than cut
        //
        int nhits = 0;
        int[] nhitsBySensor;
        nhitsBySensor = new int[n_Sensors];
        for (int i = 0; i < n_Sensors; i++) {
            nhitsBySensor[i] = 0;
        }
        for (KpixSample sample0 : data.getSamples()) {
            if (sample0.getType() == KpixSample.KpixSampleType.KPIX && !sample0.isBadEvent() && !sample0.isEmpty()) {
                Sensor_Address = sample0.getAddress();
                Cal_Amplitude = sample0.getAmplitude();
                if (!Double.isNaN(Cal_Amplitude)) {
                    nhitsBySensor[Sensor_Address]++;
                    nhits++;
                }
            }
        }
        int n_sensors_not_hit = 0;
        _nhitshist.fill(nhits);
        for (int i = 0; i < n_Sensors; i++) {
            _HitsBySensorHist[i].fill(nhitsBySensor[i]);
            if (nhitsBySensor[i] == 0) {
                n_sensors_not_hit++;
            }

        }
        _Empty_Sensor_Hist.fill(n_sensors_not_hit);
        if (nhits < nhits_cut) {
            hits_ok = true;
// Fill array of Trigger Times:
//  Go through th entire record looking for TRIGGER

            int js = -1;
            N_Triggers = 0;
            int[] Trigger_Times;
            Trigger_Times = new int[TS_Max];
            ;
            for (KpixSample sample2 : data.getSamples()) {

                if (sample2.getType() == KpixSample.KpixSampleType.TRIGGER) {
                    js++;
                    if (js < TS_Max) {
                        Trigger_Times[js] = sample2.getTime();
                        _TriggerTime_Hist.fill(Trigger_Times[js]);
                        N_Triggers = js + 1;
                    }
                }
            }
            if (js > -1) {
                _N_Triggers_Hist.fill(N_Triggers);
            }
            double[] Sensor_Energy;
            Sensor_Energy = new double[32];
            double[] Sensor_Hits_inTime;
            Sensor_Hits_inTime = new double[32];
            for (int j = 0; j < 32; j++) {
                Sensor_Energy[j] = 0;
                Sensor_Hits_inTime[j] = 0;
            }
// Come here once per record
            for (KpixSample sample1 : data.getSamples()) {
                if (sample1.getType() == KpixSample.KpixSampleType.TEMPERATURE) {
                    Sensor_Address = sample1.getAddress();
                    int Time = sample1.getTime();
                    int amplitude = sample1.getAdc();
                    double temperature = 0.598 * (255 - amplitude) - 62.;
                    _temperatureHist[Sensor_Address].fill(temperature);
                    continue;
                }
                if (sample1.getType() != KpixSample.KpixSampleType.KPIX) {
                    continue;
                }
                if (sample1.isBadEvent() || sample1.isEmpty()) {
                    continue;
                }
// Come here once per pixel and bucket for all sensors
                Sensor_Address = sample1.getAddress();
                KPiX_Bucket = sample1.getBucket();
                KPiX_Channel = sample1.getChannel();
                Bunch_Time = sample1.getTime();
                KpixCalibration calibration = sample1.getCalibration();
               
                if (calibration == null || calibration.isBad()) {
                    Cal_Amplitude = Double.NaN;
                } else {
                    Cal_Amplitude = (sample1.getAdc() - calibration.getBase())
                            / calibration.getGain();
                }


                //See if there is a match to Trigger_Times
                for (int i = 0; i < N_Triggers; i++) {
                    int Bunch_Trigger_Time = Bunch_Time - Trigger_Times[i];
                    _BunchTriggerDiff_Hist.fill(Bunch_Trigger_Time);
                    if (Bunch_Trigger_Time > Bunch_Trigger_Time_min && Bunch_Trigger_Time < Bunch_Trigger_Time_max) {
                        trigger_ok = true;
                    }
                }
                if (trigger_ok && hits_ok && !sample1.isBadChannel()) {
                    if (Double.isNaN(Cal_Amplitude)) {
                        _NaN_Sensor_Channel.fill(Sensor_Address, KPiX_Channel);
                    } else {
                        Cal_Amplitude = Cal_Amplitude * 1e15;
                        Cal_Amplitude = Cal_Amplitude + Cal_Amplitude_Droop_Offset;
                        if (!bad_pixels[Sensor_Address][KPiX_Channel] && Cal_Amplitude > Cal_Amplitude_min && Cal_Amplitude < Cal_Amplitude_max) {
                            if (nprinted < nprinted_max) {
                                System.out.printf("Event # %d Sensor %d Channel %d  Cal Amp =%5g\n", EventNumber, Sensor_Address, KPiX_Channel, Cal_Amplitude);
                                nprinted++;
                            }
                            _calAmplitudeHist.fill(Cal_Amplitude);
                            _Sensor_Amplitude_Hist[Sensor_Address].fill(Cal_Amplitude);
                            Sensor_Energy[Sensor_Address] = Sensor_Energy[Sensor_Address] + Cal_Amplitude;
                            Sensor_Hits_inTime[Sensor_Address]++;
                            int row = KPiX_Channel / 32;
                            int col = KPiX_Channel % 32;

                            _Pixel_Dist_Hist[Sensor_Address].fill(row, col);
                            continue;
                        }
                    }
                }
                trigger_ok = false;
            }


            // Nominally come here at the end of a KPiX record = event

            if (trigger_ok && hits_ok) {
                double Cal_Sum = 0;
                for (int j = 0; j < n_Sensors; j++) {
                    _Total_Energy_By_Sensor.fill(j, Sensor_Energy[j]);
                    _inTime_HitsBySensor_Hist[j].fill(Sensor_Hits_inTime[j]);
                    Cal_Sum = Cal_Sum + Sensor_Energy[j];

                }
                _Total_Deposited_Energy_Hist.fill(Cal_Sum);
                if (Sensor_Hits_inTime[0] > 0 && Sensor_Hits_inTime[n_Sensors - 1] > 0) {
                    sensor_first_last = true;
                    if (sensor_first_last) {
                        _Coincidence_Hist.fill(1);
                        for (int j = 1; j < n_Sensors - 1; j++) {
                            if (sensor_first_last && Sensor_Hits_inTime[j] > 0) {
                                _Coincidence_Hist.fill(j + 1);
                            }
                        }
                    }

                }
            }
        }


    }
//

    /**
     * This method is called at the start of an analysis session.
     */
    protected void start(LoopEvent event) {





        String outName = "c:\\KPiX Test.txt";

        // Open the file - not now
/*      try {
         System.out.println("Opening File");
         out = new PrintStream(new FileOutputStream(outName));
         } catch (FileNotFoundException e) {
         System.out.println("Failed to open output file: " + outName);
        
         }

         // Start file
         out.println("Event Number   Trigger    Bunch Time");
  
   
         */    }

    /**
     * This method is called at the end of an analysis session.
     */
    protected void finish(LoopEvent event) {


        double[] coincidence_count = new double[n_Sensors];
        System.out.println("Finished analysis  n data_records =" + n_data_records);
        for (int j = 0; j < n_Sensors - 1; j++) {
            coincidence_count[j] = _Coincidence_Hist.binEntries(j);
            System.out.println("Coincidence Count " + j + " " + coincidence_count[j]);
        }
        double sensor_efficiency;
        double sensor_efficiency_error;
        for (int j = 1; j < n_Sensors - 1; j++) {
            double bad_pixel_count = _isBad_Calibration_Hist.binEntries(j);
            double bad_pixel_efficiency = 1. - bad_pixel_count / 1024;
            sensor_efficiency = coincidence_count[j] / coincidence_count[0];
            sensor_efficiency_error = Math.sqrt(coincidence_count[j]) / coincidence_count[0];
            double corrected_pixel_efficiency = sensor_efficiency / bad_pixel_efficiency;
            double corrected_pixel_efficiency_error = sensor_efficiency_error / bad_pixel_efficiency;
            System.out.printf("sensor %d efficiency = %3g bad pixel effieciency = %3g pixel efficiency = %3g  %3g\n", j, sensor_efficiency, bad_pixel_efficiency, corrected_pixel_efficiency, corrected_pixel_efficiency_error);
        }

        //Fit Plots

        IPlotter plotter = af.createPlotterFactory().create("MyPlot");
        IFitFactory fitFactory = af.createFitFactory();
        IFunctionFactory funcFactory = af.createFunctionFactory(tree);

        IFunction func = funcFactory.createFunctionFromScript("Landau", 1, "A/sqrt(2*3.14159)*"
                + "sqrt(exp(-1*(R*(x[0]-M)+exp(-1*(R*(x[0]-M))))))", "A,R,M", "");
        double[] initialPars = {1000., 0.4, 2.5};
        func.setParameters(initialPars);
        // Do Fit
        IFitter fitter = fitFactory.createFitter("chi2");
        plotter.createRegions(3, 3, 0);
        for (int j = 0; j < n_Sensors; j++) {
            IFitResult result = fitter.fit(_Sensor_Amplitude_Hist[j], func);


            // Show results

            plotter.region(j).plot(_Sensor_Amplitude_Hist[j]);
            plotter.region(j).plot(result.fittedFunction());

            IPlotterStyle regionStyle = plotter.region(j).style();
            regionStyle.statisticsBoxStyle().setVisible(true);



            double[] fPars = result.fittedParameters();
            double[] fParErrs = result.errors();
            String[] fParNames = result.fittedParameterNames();


            System.out.printf("Sensor %d Chi2 = %3g  A = %3g +- %3g R = %3g +- %3g M =%3g +- %3g\n", j, result.quality(), fPars[0], fParErrs[0], fPars[1], fParErrs[1], fPars[2], fParErrs[2]);

        }
        plotter.show();
    }

    private void CalibrationAnalysis(KpixDataRecord data) {


        double[] gain_low_cut = new double[n_Sensors];


        for (int j = 0; j < n_Sensors; j++) {
            gain_low_cut[j] = 2.5e15;
        }

        double[] gain_err_cut = new double[n_Sensors];

        gain_err_cut[0] = 0.2e14;
        gain_err_cut[1] = 0.15e14;
        gain_err_cut[2] = 0.16e14;
        gain_err_cut[3] = 0.25e14;
        gain_err_cut[4] = 0.25e14;
        gain_err_cut[5] = 0.2e14;
        gain_err_cut[6] = 0.3e14;
        gain_err_cut[7] = 0.2e14;
        gain_err_cut[8] = 0.25e14;





        // convention is that bad_pixels will be true if pixel should not be used
        for (int j = 0; j < n_Sensors; j++) {

            for (int k = 0; k < 1023; k++) {
                bad_pixels[j][k] = false;

            }
        }


        KpixCalibrationSet calSet = data.getCalibration();
        for (sensor_index = 0; sensor_index < n_Sensors; sensor_index++) {
            for (calIndex = 0; calIndex < 1024; calIndex++) {
                try {
                    KpixCalibration cal = calSet.getCalibration(sensor_index, calIndex, KpixSample.ADCRange.NORMAL, 0);
                    double mean = cal.getBase();
                    double gain = cal.getGain();
                    double gainErr = cal.getDoubleParameter("CalibGainErr");
                    double calibIntercept = cal.getDoubleParameter("CalibIntercept");

                    if (!cal.isBad()) {
                        if (gainErr > gain_err_cut[sensor_index] || gain < gain_low_cut[sensor_index]) {
                            bad_pixels[sensor_index][calIndex] = true;
                            _isBad_Calibration_Hist.fill(sensor_index);
                        }
                        _BaseFitMeanHist[sensor_index].fill(mean);
                        _CalibGainHist[sensor_index].fill(gain);
                        if (!bad_pixels[sensor_index][calIndex]) {
                            _Cut_CalibGainHist[sensor_index].fill(gain);
                        }
                        _CalibGainErrHist[sensor_index].fill(gainErr);
                        _CalibInterceptHist[sensor_index].fill(calibIntercept);
                        _CalibInterceptBaseDifferenceHist[sensor_index].fill(mean - calibIntercept);
                    } else {
                        _isBad_Calibration_Hist.fill(sensor_index);

                    }
                } catch (KpixCalibrationException e) {
                    System.out.printf("Calibration Exception Sensor %d channel %d\n", sensor_index, calIndex);
                }
            }
        }
    }
}
