
void calibShow ( char * file, char * serial, int channel, int bucket, int range ) {
   char  buffer[200];

   sprintf(buffer,"calib_%s_c%0.4i_b%i_r%i",serial,channel,bucket,range);

   TFile *f = new TFile(file);

   TGraphErrors *g;

   f->GetObject(buffer,g);
   g->Draw("Ap");

}

