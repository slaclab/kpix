#!/usr/bin/env python

import daq_mysql
import daq_client
import time

dm = daq_mysql.DaqMysql("ppa-pc87444","daq_test","daq_test","daq_test")
dc = daq_client.DaqClient("localhost",8090)

def mysqlConfig(row):
    dc.sendConfig (row['id'],row['value'])

def mysqlCommand(row):
    dc.sendCommand (row['id'],row['arg'])

def configCb(path,value):
    dm.updateConfiguration (path,value)

def statusCb(path,value):
    dm.updateStatus (path,value)

def errorCb(value):
    dm.addError (value)

def structCb(typ,data):
    if typ == "config":
        dm.addConfigurationEntry(data)
    elif typ == "status":
        dm.addStatusEntry(data)
    elif typ == "command":
        dm.addCommandEntry(data)

dm.addCommandCallback(mysqlCommand)
dm.addConfigurationCallback(mysqlConfig)

dc.addConfigurationCallback(configCb)
dc.addStatusCallback(statusCb)
dc.addStuctureCallback(structCb)
dc.addErrorCallback(errorCb)

dm.clearEntries()

dm.pollEnable(.1)
dc.enable()

while True:
    try:
        time.sleep(1)

    except KeyboardInterrupt:
        break;
                                                                        
dm.pollDisable()
dc.disable()
