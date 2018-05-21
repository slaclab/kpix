
void twoInTrain () {

   double c47Zero = 177.2;
   double c47Gain = 12.25;
   double c49Zero = 152.2;
   double c49Gain = 9.18;

   double adcMin = 0;
   double adcMax = 1500;
   double adcCnt = 1500;
   double chg47Min = 0;
   double chg47Max = 100;
   double chg47Cnt = 1500;
   double chg49Min = 0;
   double chg49Max = 100;
   double chg49Cnt = 1500;

   unsigned int bucket  = 0;
   unsigned int timeCut = 200;

   TH1F *h47Charge = new TH1F("H47_Charge","Channel 47 Charge Histogram",chg47Cnt,chg47Min,chg47Max);
   TH1F *h47Raw    = new TH1F("H47_Raw","Channel 47 Raw Histogram",adcCnt,adcMin,adcMax);
   TH1F *h49Charge = new TH1F("H49_Charge","Channel 49 Charge Histogram",chg49Cnt,chg49Min,chg49Max);
   TH1F *h49Raw    = new TH1F("H49_Raw","Channel 49 Raw Histogram",adcCnt,adcMin,adcMax);

   KpixRunRead *r = new KpixRunRead ("2009_04_11_16_03_49_run/run.root",false);

   KpixSample *curr;
   KpixSample *s47 = NULL;
   KpixSample *s49 = NULL;
   KpixSample *store;
   unsigned int train = 0;
   unsigned int x, count, total;
   unsigned int pct, old;

   cout << "Reading From File: 0%" << flush;

   old = 0;
   total = r->getSampleCount();
   for (x=0; x < total; x++) {

      curr = r->getSample(x);
      if ( curr->getTrainNum() != train ) {
/*
         if ( s47 != NULL && s49 != NULL ) {
            h47Raw->Fill(s47->sampleValue);
            h47Charge->Fill((s47->sampleValue-c47Zero)/c47Gain);
            h49Raw->Fill(s49->sampleValue);
            h49Charge->Fill((s49->sampleValue-c49Zero)/c49Gain);
         }
*/

         if ( s47 != NULL && s49 == NULL && s47->sampleTime >= timeCut ) {
            h47Raw->Fill(s47->sampleValue);
            h47Charge->Fill((s47->sampleValue-c47Zero)/c47Gain);
         }
         if ( s47 == NULL && s49 != NULL && s49->sampleTime >= timeCut ) {
            h49Raw->Fill(s49->sampleValue);
            h49Charge->Fill((s49->sampleValue-c49Zero)/c49Gain);
         }


         train = curr->getTrainNum();
         s47 = NULL;
         s49 = NULL;
      }

      if ( curr->getKpixChannel() == 47 && curr->kpixBucket == bucket ) s47 = new KpixSample(*curr);
      if ( curr->getKpixChannel() == 49 && curr->kpixBucket == bucket ) s49 = new KpixSample(*curr);

      pct = (int)(((double)count / (double)total) * 100.0);
      if ( pct != old ) cout << "\rReading From File: " << dec << pct << "%" << flush;
      old = pct;
      count++;
   }

   TCanvas *c1 = new TCanvas("C1","C1");
   c1->Divide(2,2,0.01,0.01);

   h47Charge->GetXaxis()->SetRangeUser(-10,100);
   h49Charge->GetXaxis()->SetRangeUser(-10,100);

   c1->cd(1); h47Raw->Draw();
   c1->cd(2); h47Charge->Draw();
   c1->cd(3); h49Raw->Draw();
   c1->cd(4); h49Charge->Draw();
}

