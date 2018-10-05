import time
import click
import pyrogue
import pyrogue.interfaces.simulation
import pyrogue.protocols
import pyrogue.utilities.fileio
import rogue
import surf.axi as axi
import surf.protocols.rssi as rssi
import KpixDaq



def toInt(ba):
    return int.from_bytes(ba, 'little')

def getField(value, highBit, lowBit):
    mask = 2**(highBit-lowBit+1)-1
    return (value >> lowBit) & mask

class FrameParser(rogue.interfaces.stream.Slave):
    def __init__(self):
        rogue.interfaces.stream.Slave.__init__(self)
        nesteddict = lambda:defaultdict(nesteddict)
        self.d = []#nesteddict()


    def parseSample(self, ba):
        baSwapped = bytearray([ba[4], ba[5], ba[6], ba[7], ba[0], ba[1], ba[2], ba[3]])
        value = int.from_bytes(baSwapped, 'little', signed=False)
        adc = getField(value, 12, 0)
        timestamp = getField(value, 28, 16)
        row = getField(value, 36, 32)
        col = getField(value, 41, 37)
        bucket = getField(value, 43, 42)
        triggerFlag = getField(value, 44, 44)
        rangeFlag = getField(value, 45, 45)
        badCountFlag = getField(value, 46, 46)
        emptyFlag = getField(value, 47, 47)
        kpixId = getField(value, 59, 48)
        typeField = getField(value, 63, 60)

        print('-------')        
        if typeField == 0:
            print('Parsed Data Sample:')
            print(f'KPIX: {kpixId}')
            print(f'Timestamp: {timestamp}')
            print(f'Row: {row}')
            print(f'Col: {col}')
            print(f'ADC: {adc:04x}')
            print(f'Bucket: {bucket}')
            print(f'TriggerFlag: {triggerFlag}')
            print(f'RangeFlag: {rangeFlag}')
            print(f'BadCountFlag: {badCountFlag}')
            print(f'Emptyflag: {emptyFlag}')
        elif typeField == 1:
            print('Parsed Temperature Sample')
            print(f'KPIX: {kpixId}')            
            print(f'Temperature: {getField(value, 7, 0)}')
            print(f'TempCount: {getField(value, 31, 24)}')
        else:
            print(f'Unknown type field: {typeField}')
            
        print('-------')        
        
    def _acceptFrame(self, frame):

        if frame.getError():
            print('Frame Error!')
            return
        
        p = bytearray(frame.getPayload())
        frame.read(p, 0)

        frameSizeBytes = len(p)
        numSamples = int((frameSizeBytes-32-4)/8)

        print('')
        print('')        
        print('----------------------------------')
        print(f'Got Frame! ByteSize = {frameSizeBytes:08x}')
        print(f'Got {numSamples} samples')

        timestamp = int.from_bytes(p[4:8], 'little')
        eventNumber = int.from_bytes(p[0:4], 'little')
        zeros = int.from_bytes(p[8:8+12], 'little')

        print(f'EventNumber: {eventNumber:08x}')
        print(f'Timestamp: {timestamp:08x}')

        for i in range(numSamples):
            self.parseSample(p[32+(i*8):32+(i*8)+8])
        


class DesyTrackerRoot(pyrogue.Root):
    def __init__(self, hwEmu=False, sim=False, rssiEn=False, ip='192.168.1.10', pollEn=False, **kwargs):
        super().__init__(**kwargs)

        if hwEmu:
            self.srp = pyrogue.interfaces.simulation.MemEmulate()
            self.dataStream = rogue.interfaces.stream.Master()
            self.cmd = rogue.interfaces.stream.Master()
        
        else:
            if sim:
                dest0 = pyrogue.interfaces.simulation.StreamSim(host='localhost', dest=0, uid=1, ssi=True)
                dest1 = pyrogue.interfaces.simulation.StreamSim(host='localhost', dest=1, uid=1, ssi=True)
            
            else:
                udp = pyrogue.protocols.UdpRssiPack( host=ip, port=8192, packVer=2 )                
                dest0 = udp.application(dest=0)
                dest1 = udp.application(dest=1)

            self.srp = rogue.protocols.srp.SrpV3()
            self.cmd = rogue.interfaces.stream.Master()
            
            dataWriter = pyrogue.utilities.fileio.LegacyStreamWriter(name='DataWriter')
            
            pyrogue.streamConnectBiDir(self.srp, dest0)
            pyrogue.streamConnect(dest1, dataWriter.getDataChannel())
            pyrogue.streamConnect(self.cmd, dest1)
            pyrogue.streamConnect(self, dataWriter.getYamlChannel())

            fp = FrameParser()
            pyrogue.streamTap(dest1, fp)

            self.add(dataWriter)
            self.add(DesyTrackerRunControl())
            
        self.add(DesyTracker(memBase=self.srp, cmd=self.cmd, offset=0, rssi=rssiEn, enabled=True))

        self.start(pollEn=pollEn, timeout=100000)


class DesyTracker(pyrogue.Device):
    def __init__(self, cmd, rssi, **kwargs):
        super().__init__(**kwargs)

        @self.command()
        def EthAcquire():
            f = self.root.cmd._reqFrame(1, False)
            f.write(bytearray([0xAA]), 0)
            self.root.cmd._sendFrame(f)
                
        self.add(axi.AxiVersion(
            offset = 0x0000))

        extTrigEnum = {
            0: 'BncTrig',
            1: 'Lemo0',
            2: 'Lemo1',
            3: 'TluSpill',
            4: 'TluStart',
            5: 'TluTrigger',
            6: 'EthAcquire',
            7: 'Unused'}

        self.add(KpixDaq.KpixDaqCore(
            offset = 0x01000000,
            numKpix = 24,
            extTrigEnum = extTrigEnum))

        if rssi:
            self.add(rssi.RssiCore(
                offset = 0x02000000))


class DesyTrackerRunControl(pyrogue.RunControl):
    def __init__(self, **kwargs):
        rates = {1:'1 Hz', 10:'10 Hz', 30:'30 Hz', 50: '50 Hz', 100: '100 Hz', 0:'Auto'}
        states = {0: 'Stopped', 1: 'Running', 2: 'Calibration'}
        pyrogue.RunControl.__init__(self, rates=rates, states=states, **kwargs)

        # These specify the parameters of a run
        self.add(pr.LocalVariable(
            name = 'CalMeanCount',
            description = 'Set number of iterations for mean fitting',
            value = 4000))

        self.add(pr.LocalVariable(
            name = 'CalDacMin',
            description = 'Min DAC value for calibration',
            value = 0))

        self.add(pr.LocalVariable(
            name = 'CalDacMax',
            description = 'Max DAC value for calibration',
            value = 255))

        self.add(pr.LocalVariable(
            name = 'CalDacStep',
            description = "DAC increment value for calibration",
            value = 1))

        self.add(pr.LocalVariable(
            name = 'CalDacCount',
            description = "Number of iterations to take at each dac value",
            value = 1))

        self.add(pr.LocalVariable(
            name = 'CalChanMin',
            description = 'Starting calibration channel',
            value = 1023))

        self.add(pr.LocalVariable(
            name = 'CalChanMax',
            description = 'Last calibration channel',
            value = 1023))

        # These are updated during the run
        self.add(pr.LocalVariable(
            name = 'CalState',
            disp = ['Idle', 'Baseline', 'Inject']
            value = 'Idle'))

        self.add(pr.LocalVariable(
            name = 'CalChannel',
            value = 0))

        self.add(pr.LocalVariable(
            name = 'CalDac',
            value = 0))
        
        
    def _setRunState(self,value,changed):
        """
        Set run state. Reimplement in sub-class.
        Enum of run states can also be overriden.
        Underlying run control must update runCount variable.
        """
        if changed:
            if self.runState.valueDisp() == 'Running':
                #print("Starting run")
                self._thread = threading.Thread(target=self._run)
                self._thread.start()
            elif self.runState.valueDisp() = 'Calibration':
                self._thread = threading.Thread(target=self._calibrate)
                self._thread.start()
            elif self._thread is not None:
                #print("Stopping run")
                self._thread.join()
                self._thread = None

    def _run(self):
        self.runCount.set(0)

        while (self.runState.valueDisp() == 'Running'):
          
            self.root.DesyTracker.EthAcquire()
          
            if self.runRate.valueDisp() == 'Auto':
                self.root.DataWriter.getDataChannel().waitFrameCount(self.runCount.value()+1)
            else:
                delay = 1.0 / self.runRate.value()
                time.sleep(delay)
                # Add command here

            self.runCount += 1

    def _calibrate(self):
        # Latch all of the run settings so they can't be changed mid-run
        meanCount = self.CalMeanCount.value()
        dacMin = self.CalDacMin.value()
        dacMax = self.CalDacMax.value()
        dacStep = self.CalDacStep.value()
        dacCount = self.CalDacCount.value()
        firstChan = self.CalChanMin.value()
        lastChan = self.CalDacMax.value()
        
        # Configure firmware for calibration
        acqCtrl = self.root.DesyTracker.KpixDaqCore.AcquisitionControl
        acqCtrl.ExtTrigEn.set(False, write=True)
        acqCtrl.ExtTimestampEn.set(False, write=True)
        acqCtrl.ExtAcquisitionSrc.setDisp('EthAcquire', write=True)
        acqCtrl.Calibrate.set(True, write=True)

        self.runCount.set(0)        

        # First do baselines        
        self.CalState.set('Baseline')
        click.progressbar(
            iterable= range(meanCount),
            label = click.style('Running baseline: ', fg='green'))
        as bar:
            for i in bar:
                self.root.DesyTracker.EthAcquire()
                self.root.DataWriter.getDataChannel().waitFrameCount(self.runCount.value()+1)
                runCount += 1

        
        # Calibration
        self.CalState.set('Inject')
        click.progressbar(
            iterable= range(firstChan, lastChan+1),
            label = click.style('Running Injection: ', fg='green'))  as bar:

            for channel in bar:
                for dac in range(dacMin, dacMax+1, dacStep):
                    # Set these to log in event stream
                    self.CalChannel.set(channel)
                    self.CalDac.set(dac)
                
                    # Configure each kpix for channel and dac
                    for kpix in self.kpixAsics:
                        kpix.setCalib(channel, dac)
                    
                    # Send acquire command and wait for response
                    for count in range(dacCount):
                        self.root.DesyTracker.EthAcquire()
                        self.root.DataWriter.getDataChannel().waitFrameCount(self.runCount.value()+1)
                        runCount += 1

    
