
void ana2 ()  {

   char  buffer[4][200];
   char  name[16];
   char  *file   = "/u1/w_si/samples/2013_05_14_21_44_48.bin.root";
   char  *serial = "1002";
   int   targets[16] = { 939, 211, 689, 337, 664, 548, 414, 1011, 881, 648, 548, 69, 481, 443, 312, 989 };
                            
   TFile *f = new TFile(file);
   TH1F *h[16][4];

   TCanvas *c1[16];

   gStyle->SetOptFit(11111111);
   gStyle->SetOptStat(11111111);

   for ( int x=0; x < 16; x++ ) {

      sprintf(name,"%i",x);
      c1[x] = new TCanvas(name,name);

      c1[x]->Clear();
      c1[x]->Divide(2,2,0.0125, 0.0125);

      for ( int y=0; y < 4; y++ ) {
         sprintf(buffer[y],"hist_%s_c%0.4i_b%i_r%i",serial,targets[x],y,0);

         f->GetObject(buffer[y],h[x][y]);
         c1[x]->cd(y+1)->SetLogy();
         if ( h[x][y] != NULL ) {
            h[x][y]->Fit("gaus");
            h[x][y]->Draw("e");
         }
      }

      sprintf(name,"%0.2i.ps",x);
      c1[x]->Print(name);
      //sprintf(name,"ps2pdf %i.ps",x);
      //system(name):
   }
}

