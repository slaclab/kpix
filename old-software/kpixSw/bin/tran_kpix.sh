#!/bin/bash    

if [ $# != "1" ] 
then
   echo "Usage: tran_kpix.sh run_dir"
   exit
fi

lftp -c "set ftp:list-options -a;
open ftp://anonymous:rherbst@slac.stanford.edu@ftp.slac.stanford.edu; 
mkdir incoming/kpix;
cd incoming/kpix;
mirror --reverse \
       --delete \
       --verbose $1"
