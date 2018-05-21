import pyrogue as pr
import surf.axi as axi
import surf.protocols.rssi as rssi
import KpixDaq

class DesyTrackerRoot(pr.Root):
    def __init__(self, hwEmu=False, pollEn=False, **kwargs):
        super().__init__(**kwargs)

        cmd = rogue.interfaces.stream.Master()

        
        if hwEmu:
            srp = pr.interfaces.simulation.MemEmulate()
        else:
            udp = pyrogue.protocols.UdpRssiPack( host='192.168.1.10', port=8192, packVer=2 )            
            srp = rogue.protocols.srp.SrpV3()
            dataWriter = pyrogue.utilities.fileio.StreamWriter()
            self.add(dataWriter)

            pyrogue.streamConnectBiDir(srp, udp.application(dest=0))
            pyrogue.streamConnect(cmd, udp.application(dest=1))
            pyrogue.streamConnect(udp.application(dest=1), dataWriter.getChannel(0))

        self.add(DesyTracker(memBase=srp, cmd=cmd, offset=0, enabled=True))

        self.start(pollEn=pollEn)
        

class DesyTracker(pr.Device):
    def __init__(self, cmd, **kwargs):
        super().__init__(**kwargs)

        @self.command()
        def EthAcquire():
            cmd._sendFrame(bytearray([b'\xaa']))
                
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

        self.add(rssi.RssiCore(
            offset = 0x02000000))

class DesyTrackerRoot(pr.Root):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        
    
