
void narrowInTrain () {

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

   TH1F *h47Raw[4];
   h47Raw[0] = new TH1F("H47_RawB0","Channel 47, B0 Raw Histogram",adcCnt,adcMin,adcMax);
   h47Raw[1] = new TH1F("H47_RawB1","Channel 47, B1 Raw Histogram",adcCnt,adcMin,adcMax);
   h47Raw[2] = new TH1F("H47_RawB2","Channel 47, B2 Raw Histogram",adcCnt,adcMin,adcMax);
   h47Raw[3] = new TH1F("H47_RawB3","Channel 47, B3 Raw Histogram",adcCnt,adcMin,adcMax);
   TH1F *h49Raw[4];
   h49Raw[0] = new TH1F("H49_RawB0","Channel 49, B0 Raw Histogram",adcCnt,adcMin,adcMax);
   h49Raw[1] = new TH1F("H49_RawB1","Channel 49, B0 Raw Histogram",adcCnt,adcMin,adcMax);
   h49Raw[2] = new TH1F("H49_RawB2","Channel 49, B0 Raw Histogram",adcCnt,adcMin,adcMax);
   h49Raw[3] = new TH1F("H49_RawB3","Channel 49, B0 Raw Histogram",adcCnt,adcMin,adcMax);

   KpixRunRead *r = new KpixRunRead ("/u1/w_si/samples/2009_04_11_16_03_49_run/run.root",false);

   KpixSample *curr;
   KpixSample *s47[4];
   s47[0] = NULL;
   s47[1] = NULL;
   s47[2] = NULL;
   s47[3] = NULL;
   KpixSample *s49[4];
   s49[0] = NULL;
   s49[1] = NULL;
   s49[2] = NULL;
   s49[3] = NULL;
   KpixSample *store;
   unsigned int train = 0;
   unsigned int x, y, count, total;
   unsigned int pct, old;

   cout << "Reading From File: 0%" << flush;

   old = 0;
   total = r->getSampleCount();
   for (x=0; x < total; x++) {

      curr = r->getSample(x);
      if ( curr->getTrainNum() != train ) {

         if ( s47[0] != NULL && s47[1] == NULL && s47[0]->sampleTime > 200) h47Raw[0]->Fill(s47[0]->sampleValue);
         if ( s49[0] != NULL && s49[1] == NULL && s49[0]->sampleTime > 200) h49Raw[0]->Fill(s49[0]->sampleValue);

         train = curr->getTrainNum();
         for (y=0; y<4; y++) {
            s47[y] = NULL;
            s49[y] = NULL;
         }
      }

      if ( curr->getKpixChannel() == 47 ) s47[curr->kpixBucket] = new KpixSample(*curr);
      if ( curr->getKpixChannel() == 49 ) s49[curr->kpixBucket] = new KpixSample(*curr);

      pct = (int)(((double)count / (double)total) * 100.0);
      if ( pct != old ) cout << "\rReading From File: " << dec << pct << "%" << flush;
      old = pct;
      count++;
   }

   TCanvas *c1 = new TCanvas("C1","C1");
   c1->Divide(1,2,0.01,0.01);

   c1->cd(1); h47Raw[0]->Draw();
   c1->cd(2); h49Raw[0]->Draw();
}

