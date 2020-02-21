import pyrogue
import rogue

import KpixDaq

class DesyTrackerRoot(pyrogue.Root):
    def __init__(
            self,
            debug=False,
            hwEmu=False,
            sim=False,
            rssiEn=True,
            ip='192.168.2.10',
            pollEn=False,
            serverPort=9099,
            **kwargs):
        
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
                self.udp = pyrogue.protocols.UdpRssiPack( host=ip, port=8192, packVer=2 )                
                dest0 = self.udp.application(dest=0)
                dest1 = self.udp.application(dest=1)

            self.srp = rogue.protocols.srp.SrpV3()
            self.cmd = rogue.interfaces.stream.Master()
            
            dataWriter = pyrogue.utilities.fileio.LegacyStreamWriter(name='DataWriter')
            
            pyrogue.streamConnectBiDir(self.srp, dest0)
            pyrogue.streamConnect(dest1, dataWriter.getDataChannel())
            pyrogue.streamConnect(self.cmd, dest1)
            pyrogue.streamConnect(self, dataWriter.getYamlChannel())

            if debug:
                fp = FrameInfo()
                pyrogue.streamTap(dest1, fp) 

            self.add(dataWriter)
            self.add(DesyTrackerRunControl())
            
        self.add(DesyTracker(memBase=self.srp, cmd=self.cmd, offset=0, rssi=rssiEn, sim=sim, enabled=True, expand=True))

        self.start(pollEn=pollEn, timeout=100000, serverPort=serverPort)

    def stop(self):
        self.udp._rssi.stop()
        super().stop()

class DesyTrackerRootArgparser(argparse.ArgumentParser):
    def __init__(self):
        super().__init__(add_help=False)
        
        self.add_argument(
            "--ip", 
            type     = str,
            required = False,
            default = '192.168.2.10',
            help     = "IP address")  

        self.add_argument(
            "--hwEmu", 
            required = False,
            action = 'store_true',
            help     = "hardware emulation (false=normal operation, true=emulation)")

        self.add_argument(
            "--sim", 
            required = False,
            action   = 'store_true',
            help     = "hardware emulation (false=normal operation, true=emulation)")

        self.add_argument(
            "--pollEn", 
            required = False,
            action   = 'store_true',
            help     = "enable auto-polling")

        self.add_argument(
            "--debug", 
            required = False,
            action = 'store_true',
            help     = "enable data debug")
