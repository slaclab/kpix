
unsigned int adcToGray(unsigned int value) {
   int a[13], b[13];
   int i;
   unsigned int ret;

   // Convert number to binary
   for (i=0; i < 13; i++) a[i] = (value / (int)pow(2,i)) % 2;

   // Convert the normal base2 number into the graycode equivalent.
   int shift = 0;
   for(i = 12; i >= 0; --i) {
      b[i] = (a[i] + 2 - shift) % 2;
      shift += b[i];
   }

   // Convert back to decimal
   ret = 0;
   for (i=0; i<13; i++) if ( b[i] != 0 ) ret += (int)pow(2,i);
   return(ret);
}

void samplesToGray () {

   TH1F *h1 = new TH1F("h1","Channel 0, Bucket 0, ADC Value",8192,0,8192);
   TH1F *h2 = new TH1F("h2","Channel 0, Bucket 0, ADC Gray",8192,0,8192);
   unsigned int orig;
   unsigned int gray;
   unsigned int x;
   unsigned int y;
   unsigned int bit;
   unsigned int count;
   bool o_ones[13];
   bool o_zeros[13];
   bool g_ones[13];
   bool g_zeros[13];

   for (x=0; x<13; x++) {
      o_ones[x]  = false;
      o_zeros[x] = false;
      g_ones[x]  = false;
      g_zeros[x] = false;
   }


   //KpixRunRead *r = new KpixRunRead ("/u1/w_si/gem/apr_09/2009_05_08_20_02_27_calib_dist/calib_dist.root",false);
   KpixRunRead *r = new KpixRunRead ("/u1/w_si/gem/apr_09/2009_05_08_20_02_27_calib_dist/calib_dist.root",false);
   KpixSample  *s;

   cout << "Reading Samples: 0%     " << flush;
   count = r->getSampleCount();
   for (x=0; x<count; x++) {
      s = r->getSample(x);

      //if ( s->getKpixChannel() == 0 && s->getKpixBucket() == 0 && s->getVarValue(1) == 1 ) {
      if ( s->getKpixChannel() < 32 ) {
         orig = s->getSampleValue();
         gray = adcToGray(orig);

         // Check bits
         for (y=0; y<13; y++) {
            bit = (1 << y);
            if ( (orig & bit) == 0 ) o_zeros[y] = true;
            else o_ones[y] = true;
            if ( (gray & bit) == 0 ) g_zeros[y] = true;
            else g_ones[y] = true;
         }

         h1->Fill(orig);
         h2->Fill(gray);
      }
      if ( (x % 100) == 0 ) {
         cout << "\rReading Sample: ";
         cout << (int)(((double)x/(double)count) * 100) << "%    " << flush;
      }
   }
   cout << "Reading Samples: 100%    " << endl;

   cout << " Orig Ones: ";
   for (y=0; y<13; y++) cout << o_ones[y];
   cout << endl;
   cout << "Orig xeros: ";
   for (y=0; y<13; y++) cout << o_zeros[y];
   cout << endl;
   cout << " Gray Ones: ";
   for (y=0; y<13; y++) cout << g_ones[y];
   cout << endl;
   cout << "Gray xeros: ";
   for (y=0; y<13; y++) cout << g_zeros[y];
   cout << endl;

   TCanvas *c1 = new TCanvas("c1","c1");
   c1->Divide(1,2,0.01,0.01);
   c1->cd(1);
   h1->Draw();
   c1->cd(2);
   h2->Draw();
}

