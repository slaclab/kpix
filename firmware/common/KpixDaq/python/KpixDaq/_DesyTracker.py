import pyrogue as pr
import surf.axi as axi
import surf.protocols.rssi as rssi
import KpixDaq

class DesyTracker(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        if hwEmu:
            srp = pr.interfaces.simulation.MemEmulate()
        else:
            srp = rogue.protocols.srp.SrpV3()
            udp = pyrogue.protocols.UdpRssiPack( host='192.168.1.10', port=8192, packVer=2 )
            pyrogue.streamConnectBiDir(srp, udp.application(dest=0))
            cmd = rogue.interfaces.stream.Master()
            pyrogue.streamConnect(cmd, udp.application(dest=1))

        @self.command()
        def EthAcquire():
            cmd.sendFrame(b'\xaa')
                
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

        
    
