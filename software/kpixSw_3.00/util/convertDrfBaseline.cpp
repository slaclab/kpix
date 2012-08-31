#include <sstream>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <string>
using namespace std;

// Process the data
int main ( int argc, char **argv ) {
   string      serial;
   string      inFileName;
   string      outFileName;
   ifstream    inFile;
   ofstream    outFile;
   string      line;
   char        tstr[200];
   time_t      tme;
   struct tm   *timeinfo;
   uint        channel;
   uint        bucket;
   uint        spare;
   double      baseLine;

   // Two args: serial number and input file
   if ( argc != 3 ) {
      cout << "Usage: convertDrfBaseline serial input\n";
      return(1);
   }

   // Get args
   serial     = argv[1];
   inFileName = argv[2];

   // Generate output file name
   outFileName = inFileName;
   outFileName.append(".xml");

   // Open input and output file
   inFile.open(inFileName.c_str(),ios::in);
   outFile.open(outFileName.c_str(),ios::out | ios::trunc);

   // Check state
   if ( ! inFile.good() ) {
      cout << "Error opening input file " << inFileName << endl;
      return(1);
   }
   if ( ! outFile.good() ) {
      cout << "Error opening output file " << outFileName << endl;
      return(1);
   }

   // Start output file
   outFile << "<calibrationData>" << endl;

   // Add notes
   outFile << "   <sourceFile>" << inFileName << "</sourceFile>" << endl;
   outFile << "   <user>" <<  getlogin() << "</user>" << endl;

   time(&tme);
   timeinfo = localtime(&tme);
   strftime(tstr,200,"%Y_%m_%d_%H_%M_%S",timeinfo);
   outFile << "   <timestamp>" << tstr << "</timestamp>" << endl;

   // Start KPIX
   outFile << "   <kpixAsic id=\"" << serial << "\">" << endl;

   // Get the first line
   getline(inFile, line);

   // Add first line as comment
   outFile << "      <!-- First Line: " << line << " -->" << endl;

   // Process each input line
   while (getline(inFile, line)) {
      istringstream iss(line);

      // Get parameters
      iss >> channel;
      iss >> bucket;
      iss >> spare;
      iss >> baseLine;

      // Start channel
      outFile << "      <Channel id=\"" << channel << "\">" << endl;

      // Mark if bad
      if ( baseLine == 0 ) outFile << "         <BadChannel>1</BadChannel>" << endl;

      // Other parameters
      outFile << "         <Bucket id=\"" << bucket << "\">" << endl;
      outFile << "            <Range id=\"0\">" << endl;
      outFile << "               <BaseMean>" << baseLine << "</BaseMean>" << endl;
      outFile << "            </Range>" << endl;
      outFile << "         </Bucket>" << endl;
      outFile << "      </Channel>" << endl;
   }

   // End KPIX
   outFile << "   </kpixAsic>" << endl;

   // End file
   outFile << "</calibrationData>" << endl;

   cout << "Wrote xml data to " << outFileName << endl;

   // Close files
   outFile.close();
   inFile.close();
}

