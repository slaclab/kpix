#!/bin/csh

setenv interactive 1
source /afs/slac/g/exo/daq/script/group.cshrc
cmx set branch KDCX,KSVR --test=~russell/sid/kpix
KpixServerShared --dataHost=172.27.99.96 --dataPort=6110
