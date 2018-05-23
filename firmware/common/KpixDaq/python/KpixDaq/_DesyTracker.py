import pyrogue
import pyrogue.interfaces.simulation
import pyrogue.protocols
import pyrogue.utilities.fileio
import rogue
import surf.axi as axi
import surf.protocols.rssi as rssi
import KpixDaq

class DesyTrackerRoot(pyrogue.Root):
    def __init__(self, mode="HW", pollEn=False, **kwargs):
        super().__init__(**kwargs)

        print(f"DesyTrackerRoot(mode={mode})")

        if mode == "MEM_EMU":
            srp = pyrogue.interfaces.simulation.MemEmulate()
            data = rogue.interfaces.stream.Master()
            cmd = rogue.interfaces.stream.Master()
        
        else:
            if mode == "SIM":
                dest0 = pyrogue.interfaces.simulation.StreamSim(host='localhost', dest=0, uid=1, ssi=True)
                dest1 = pyrogue.interfaces.simulation.StreamSim(host='localhost', dest=1, uid=1, ssi=True)
            
            elif mode == "HW":
                udp = pyrogue.protocols.UdpRssiPack( host='192.168.1.10', port=8192, packVer=2 )                
                dest0 = udp.application(dest=0)
                dest1 = udp.application(dest=1)

            srp = rogue.protocols.srp.SrpV3()
            cmd = rogue.interfaces.stream.Master()            
            dataWriter = pyrogue.utilities.fileio.StreamWriter()
            
            pyrogue.streamConnectBiDir(srp, dest0)
            pyrogue.streamConnect(dest1, dataWriter.getChannel(0))
            pyrogue.streamConnect(cmd, dest1)

            self.add(dataWriter)

            
        self.add(DesyTracker(memBase=srp, cmd=cmd, offset=0, rssi=(mode=='HW'), enabled=True))

        print('Calling start')
        self.start(pollEn=pollEn)
        self.setTimeout(100000)        
        print('Start Done')        
        

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


        
    
