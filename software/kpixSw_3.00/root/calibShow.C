
void calibShow ( char * file, char * serial, int channel, int bucket, int range ) {
   char  buffer[200];

   TGraphErrors *g;
   TGraph       *r;
   TCanvas      *c;

   TFile *f = new TFile(file);
   c = new TCanvas;

   sprintf(buffer,"calib_%s_c%0.4i_b%i_r%i",serial,channel,bucket,range);
   f->GetObject(buffer,g);

   sprintf(buffer,"resid_%s_c%0.4i_b%i_r%i",serial,channel,bucket,range);
   f->GetObject(buffer,r);

   c->Divide(1,2,0.01,0.01);

   c->cd(1);
   g->Draw("A*");
   c->cd(2);
   r->Draw("A*");
}

