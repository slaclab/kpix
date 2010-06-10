
void testRoutine() {

   cout << "This worked" << endl;

}


void calDataRead () {

   double slope[64][4];
   double offset[64][4];
   double mean[64][4];
   double sigma[64][4];
   double rms[64][4];

   unsigned int serial = 770;
   unsigned int gain   = 0;
   unsigned int channel;
   unsigned int bucket;

   KpixCalibRead *r = new KpixCalibRead ("/u1/w_si/samples/2009_05_05_14_12_37_calib_dist/calib_dist_fit.root",false);

   cout << "Reading From File: Channel 0" << flush;

   for (channel=0; channel < 64; channel++) {

      cout << "\rReading From File: Channel " << dec << channel << flush;

      for (bucket=0; bucket < 4; bucket++) {

         r->getCalibData(&(slope[channel][bucket]),&(offset[channel][bucket]),"Force_Trig",gain,serial,channel,bucket);
         r->getHistData(&(mean[channel][bucket]),&(sigma[channel][bucket]),&(rms[channel][bucket]),"Force_Trig",gain,serial,channel,bucket);
      }
   }
   cout << "\rReading From File: Done" << endl;

   cout << "Channel 1, Bucket 0: Gain=" << slope[1][0] << ", Offset=" << offset[1][0] << ", Mean=" << mean[1][0] << endl;
   cout << "Channel 4, Bucket 2: Gain=" << slope[4][2] << ", Offset=" << offset[4][2] << ", Mean=" << mean[4][2] << endl;

   delete r;


   testRoutine();






}

