
void histShow ( char * file, char * serial, int channel, int bucket, int range ) {
   char  buffer[200];

   sprintf(buffer,"hist_%s_c%0.4i_b%i_r%i",serial,channel,bucket,range);

   TFile *f = new TFile(file);

   TH1F *h;

   f->GetObject(buffer,h);
   h->Fit("gaus","");
   h->Draw("e");

}

