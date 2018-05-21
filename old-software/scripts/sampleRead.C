void sampleRead () {

   unsigned int x,count;
   KpixSample   *s;

   KpixRunRead *r = new KpixRunRead ("/u1/w_si/gem/may_09/2009_05_15_16_46_54_run/run.root",false);

   cout << "Reading Samples: 0%     " << flush;
   count = r->getSampleCount();
   for (x=0; x<count; x++) {
      s = r->getSample(x);

      // Sample data
      // s->getTrainNum();    // Train Number
      // s->getKpixAddress(); // Kpix Address
      // s->getKpixChannel(); // Channel
      // s->getKpixBucket();  // Bucket
      // s->getSampleRange(); // Range Bit
      // s->getSampleTime();  // Timestamp
      // s->getSampleValue(); // ADC Value

      if ( (x % 100) == 0 ) {
         cout << "\rReading Sample: ";
         cout << (int)(((double)x/(double)count) * 100) << "%    " << flush;
      }
   }
   cout << "Reading Samples: 100%    " << endl;



}

