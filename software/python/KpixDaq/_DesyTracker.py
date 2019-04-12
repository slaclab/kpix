import threading
import time
import click

import rogue
import pyrogue
import pyrogue.interfaces.simulation
import pyrogue.protocols
import pyrogue.utilities.fileio

import surf.axi
import surf.protocols.rssi
import surf.devices.linear
import surf.devices.nxp
import surf.xilinx
import surf.devices.micron

import KpixDaq

class DesyTrackerRoot(pyrogue.Root):
    def __init__(self, hwEmu=False, sim=False, rssiEn=True, ip='192.168.1.10', pollEn=False, **kwargs):
        super().__init__(**kwargs)

        if hwEmu:
            self.srp = pyrogue.interfaces.simulation.MemEmulate()
            self.dataStream = rogue.interfaces.stream.Master()
            self.cmd = rogue.interfaces.stream.Master()
        
        else:
            if sim:
                dest0 = rogue.interfaces.stream.TcpClient('localhost', 9000)
                dest1 = rogue.interfaces.stream.TcpClient('localhost', 9002)
                rssiEn = False
                pollEn = False
            
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

            fp = KpixDaq.KpixStreamInfo()
            pyrogue.streamTap(dest1, fp) 

            self.add(dataWriter)
            self.add(DesyTrackerRunControl())
            
        self.add(DesyTracker(memBase=self.srp, cmd=self.cmd, offset=0, rssi=rssiEn, enabled=True))

        self.start(pollEn=pollEn, timeout=100000)

class TluMonitor(pyrogue.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(pyrogue.RemoteVariable(
            name = 'TluClkFreqRaw',
            offset = 0x00,
            mode = 'RO',
            base = pyrogue.UInt,
        ))

        self.add(pyrogue.LinkVariable(
            name = 'TluClkFreq',
            dependencies = [self.TluClkFreqRaw],
            linkedGet = lambda: self.TluClkFreqRaw.value() * 1.0e-6,
            value = 0.0,
            units = 'MHz',
            disp = '{:1.3f}',
        ))

        self.add(pyrogue.RemoteVariable(
            name = 'TriggerCount',
            offset = 0x04,
            mode = 'RO',
            base = pyrogue.UInt,
        ))

        self.add(pyrogue.RemoteVariable(
            name = 'SpillCount',
            offset = 0x08,
            mode = 'RO',
            base = pyrogue.UInt,
        ))

        self.add(pyrogue.RemoteVariable(
            name = 'StartCount',
            offset = 0x0C,
            mode = 'RO',
            base = pyrogue.UInt,
        ))

        self.add(pyrogue.RemoteCommand(
            name = 'RstCounts',
            offset = 0x10,
            function = pyrogue.RemoteCommand.toggle
        ))

        self.add(pyrogue.RemoteVariable(
            name = 'ClkSel',
            offset = 0x20,
            mode = 'RW',
            base = pyrogue.UInt,
            enum = {
                0: 'EthClk',
                1: 'TluClk',
            }
        ))
        
class EnvironmentMonitor(pyrogue.Device):
      def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(surf.xilinx.Xadc(
            offset=0x03000000,
            hidden=True))

        self.add(surf.devices.linear.Ltc4151(
            offset = 0x04000000,
            senseRes = 0.02,
            hidden=True))

        self.add(surf.devices.nxp.Sa56004x(
            description = "Board temperate monitor",
            offset = 0x04000400,
            hidden=True))


        self.add(pyrogue.LinkVariable(
            name = 'FpgaTemperature',
            variable = self.Xadc.Temperature))

        self.add(pyrogue.LinkVariable(
            name = 'BoardTemperature',
            variable = self.Sa56004x.LocalTemperature))

        self.add(pyrogue.LinkVariable(
            name = 'InputVoltage',
            variable = self.Ltc4151.Vin))

        self.add(pyrogue.LinkVariable(
            name = 'InputCurrent',
            variable = self.Ltc4151.Iin))

        self.add(pyrogue.LinkVariable(
            name = 'InputPower',
            variable = self.Ltc4151.Pin))
        
        

class DesyTracker(pyrogue.Device):
    def __init__(self, cmd, rssi, **kwargs):
        super().__init__(**kwargs)

        @self.command()
        def EthAcquire():
            f = self.root.cmd._reqFrame(1, False)
            f.write(bytearray([0xAA]), 0)
            self.root.cmd._sendFrame(f)

        @self.command()
        def EthStart():
            f = self.root.cmd._reqFrame(1, False)
            f.write(bytearray([0x55]), 0)
            self.root.cmd._sendFrame(f)
            
                
        self.add(surf.axi.AxiVersion(
            offset = 0x0000))

        self.add(EnvironmentMonitor())

        extTrigEnum = {
            0: 'BncTrig',
            1: 'Lemo0',
            2: 'Lemo1',
            3: 'TluSpill',
            4: 'TluStart',
            5: 'TluTrigger',
            6: 'EthAcquire',
            7: 'EthStart'}

        self.add(TluMonitor(
            offset = 0x06000000))

        self.add(KpixDaq.KpixDaqCore(
            offset = 0x01000000,
            numKpix = 24,
            extTrigEnum = extTrigEnum))

        if rssi:
            self.add(surf.protocols.rssi.RssiCore(
                offset = 0x02000000,
                expand = False))

        self.add(surf.devices.micron.AxiMicronN25Q(
            offset = 0x05000000,
            addrMode = False,
            hidden = True))

class DesyTrackerRunControl(pyrogue.RunControl):
    def __init__(self, **kwargs):
        rates = {1:'1 Hz', 10:'10 Hz', 30:'30 Hz', 50: '50 Hz', 100: '100 Hz', 0:'Auto'}
        states = {0: 'Stopped', 1: 'Running', 2: 'Calibration'}
        pyrogue.RunControl.__init__(self, rates=rates, states=states, **kwargs)

        # These specify the parameters of a run
        self.add(pyrogue.LocalVariable(
            name = 'CalMeanCount',
            description = 'Set number of iterations for mean fitting',
            value = 100))

        self.add(pyrogue.LocalVariable(
            name = 'CalDacMin',
            description = 'Min DAC value for calibration',
            value = 0))

        self.add(pyrogue.LocalVariable(
            name = 'CalDacMax',
            description = 'Max DAC value for calibration',
            value = 255))

        self.add(pyrogue.LocalVariable(
            name = 'CalDacStep',
            description = "DAC increment value for calibration",
            value = 1))

        self.add(pyrogue.LocalVariable(
            name = 'CalDacCount',
            description = "Number of iterations to take at each dac value",
            value = 1))

        self.add(pyrogue.LocalVariable(
            name = 'CalChanMin',
            description = 'Starting calibration channel',
            value = 0))

        self.add(pyrogue.LocalVariable(
            name = 'CalChanMax',
            description = 'Last calibration channel',
            value = 1023))

        # These are updated during the run
        self.add(pyrogue.LocalVariable(
            name = 'CalState',
            disp = ['Idle', 'Baseline', 'Inject'],
            value = 'Idle'))

        self.add(pyrogue.LocalVariable(
            name = 'CalChannel',
            value = 0))

        self.add(pyrogue.LocalVariable(
            name = 'CalDac',
            value = 0))

    def _setRunState(self,value,changed):
        """
        Set run state. Reimplement in sub-class.
        Enum of run states can also be overriden.
        Underlying run control must update runCount variable.
        """
        if changed:
            # First stop old threads to avoid overlapping runs
            # but not if we are calling from the running thread
            if self._thread is not None and self._thread != threading.current_thread():
                self._thread.join()
                self.thread = None;
                self.root.ReadAll()                
            
            if self.runState.valueDisp() == 'Running':
                #print("Starting run")
                self._thread = threading.Thread(target=self._run)
                self._thread.start()
            elif self.runState.valueDisp() == 'Calibration':
                self._thread = threading.Thread(target=self._calibrate)
                self._thread.start()


    def _run(self):
        for i in range(24):
            self.root.DesyTracker.KpixDaqCore.KpixDataRxArray.KpixDataRx[i].ResetCounters()

        self.root.ReadAll()
            
        self.runCount.set(self.root.DataWriter.getDataChannel().getFrameCount())
        self.root.DesyTracker.EthStart()        

        while (self.runState.valueDisp() == 'Running'):
          
            self.root.DesyTracker.EthAcquire()
            #self.root.DataWriter.getDataChannel().getFrameCount()
          
            if self.runRate.valueDisp() == 'Auto':
                if not self.root.DataWriter.getDataChannel().waitFrameCount(self.runCount.value()+1, 1.0e6):
                    print('Timed out waiting for data')
                    return

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
        lastChan = self.CalChanMax.value()
        
        # Configure firmware for calibration
        acqCtrl = self.root.DesyTracker.KpixDaqCore.AcquisitionControl
        acqCtrl.ExtTrigEn.set(False, write=True)
        acqCtrl.ExtTimestampEn.set(False, write=True)
        acqCtrl.ExtAcquisitionSrc.setDisp('EthAcquire', write=True)
        acqCtrl.ExtAcquisitionEn.set(True, write=True)        
        acqCtrl.ExtStartSrc.setDisp('EthStart', write=True)
        acqCtrl.ExtStartEn.set(True, write=True)                
        acqCtrl.Calibrate.set(True, write=True)

        self.root.ReadAll()

        # Put asics in calibration mode
        kpixAsics = [self.root.DesyTracker.KpixDaqCore.KpixAsicArray.KpixAsic[i] for i in range(24)]
        for kpix in kpixAsics:
            kpix.setCalibrationMode()

        # Restart the run count
        for i in range(24):
            self.root.DesyTracker.KpixDaqCore.KpixDataRxArray.KpixDataRx[i].ResetCounters()
        
        self.runCount.set(self.root.DataWriter.getDataChannel().getFrameCount())
        self.root.DesyTracker.EthStart()

        # First do baselines        
        self.CalState.set('Baseline')
        with click.progressbar(
                iterable= range(meanCount),
                label = click.style('Running baseline: ', fg='green')) as bar:
            
            for i in bar:
                if self.runState.valueDisp() == 'Calibration':
                    self.root.DesyTracker.EthAcquire()
                    timeout = self.root.DataWriter.getDataChannel().waitFrameCount(self.runCount.value()+1, 1.0e6)
                    if timeout:
                        print('Timed out waiting for data')
                        return
                    
                    self.runCount += 1
                else:
                    #self.runState.setDisp('Stopped')
                    return

        
        # Calibration
        self.CalState.set('Inject')
        print(f'firstChan: {firstChan}, lastChan: {lastChan}')
        with click.progressbar(
            iterable= range(firstChan, lastChan+1),
            label = click.style('Running Injection: ', fg='green'))  as bar:

            for channel in bar:
                click.echo(f'\nCalibrating channel {channel}\n')
                for dac in range(dacMin, dacMax+1, dacStep):
                    click.echo(f'\nDAC {dac:d}\n')
                    # Set these to log in event stream
                    self.CalChannel.set(channel)
                    self.CalDac.set(dac)
                
                    # Configure each kpix for channel and dac
                    for kpix in kpixAsics:
                        kpix.setCalibration(channel, dac)
                    
                    # Send acquire command and wait for response
                    for count in range(dacCount):
                        if self.runState.valueDisp() == 'Calibration':                        
                            self.root.DesyTracker.EthAcquire()
                            timeout = self.root.DataWriter.getDataChannel().waitFrameCount(self.runCount.value()+1, 1.0e6)
                            if timeout:
                                print('Timed out waiting for data')
                                return
                            self.runCount += 1
                        else:
                            #self.runState.setDisp('Stopped')
                            return
                            
        self.runCount.get()
        self.root.ReadAll()
        self.runState.setDisp('Stopped')        

    
