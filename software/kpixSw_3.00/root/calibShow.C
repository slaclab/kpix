
void calibShow ( char * file, char * serial, int channel, int bucket, int range ) {
   char  buffer[200];

   sprintf(buffer,"calib_%s_c%0.4i_b%i_r%i",serial,channel,bucket,range);

   TFile *f = new TFile(file);

   TGraphErrors *g;

   f->GetObject(buffer,g);
   //TF1 *func = g->GetFunction("pol1");
   //g->Fit("pol1","","",0.1e-12,0.2e-12);

   g->Draw("Ap");
   //func->Draw("LSAME");

}

