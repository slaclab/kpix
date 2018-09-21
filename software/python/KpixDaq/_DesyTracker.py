import pyrogue
import pyrogue.interfaces.simulation
import pyrogue.protocols
import pyrogue.utilities.fileio
import rogue
import surf.axi as axi
import surf.protocols.rssi as rssi
import KpixDaq

class DesyTrackerRoot(pyrogue.Root):
    def __init__(self, hwEmu=False, sim=False, rssiEn=False, ip='192.168.1.10', pollEn=False, **kwargs):
        super().__init__(**kwargs)

        if hwEmu:
            self.srp = pyrogue.interfaces.simulation.MemEmulate()
            self.dataStream = rogue.interfaces.stream.Master()
            self.cmdStream = rogue.interfaces.stream.Master()
        
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

            self.add(dataWriter)
            self.add(DesyTrackerRunControl())
            
        self.add(DesyTracker(memBase=self.srp, cmd=self.cmd, offset=0, rssi=rssiEn, enabled=True))

        self.start(pollEn=pollEn, timeout=100000)
        

class DesyTracker(pyrogue.Device):
    def __init__(self, cmd, rssi, **kwargs):
        super().__init__(**kwargs)

        @self.command()
        def EthAcquire():
            f = cmd._reqFrame(1, False)
            f.write(bytearray([0xAA]), 0)
            cmd._sendFrame(f)
                
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
        pyrogue.RunControl.__init__(self, rates=rates, **kwargs)

    def _run(self):
        self.runCount.set(0)

        while (self.runState.valueDisp() == 'Running'):
          
            self.root.Trigger()
          
            if self.runRate.valueDisp() == 'Auto':
                self.root.dataWriter.getDataChannel().waitFrameCount(self.runCount.value()+1)
            else:
                delay = 1.0 / self.runRate.value()
                time.sleep(delay)
                # Add command here

            self.runCount += 1

    
