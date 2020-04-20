import argparse

import rogue
import pyrogue
import pyrogue.interfaces.simulation
import pyrogue.protocols
import pyrogue.utilities.fileio

import KpixDaq

class DesyTrackerRoot(pyrogue.Root):
    def __init__(
            self,
            debug=False,
            hwEmu=False,
            sim=False,
            rssiEn=True,
            ip='192.168.2.10',
            **kwargs):

        super().__init__(**kwargs)

        self.sim = sim

        if hwEmu:
            self.srp = pyrogue.interfaces.simulation.MemEmulate()
            self.dataStream = rogue.interfaces.stream.Master()
            self.cmd = rogue.interfaces.stream.Master()

        else:
            if sim:
                self.dest0 = rogue.interfaces.stream.TcpClient('localhost', 9000)
                self.dest1 = rogue.interfaces.stream.TcpClient('localhost', 9002)
                rssiEn = False

            else:
                self.udp = pyrogue.protocols.UdpRssiPack( host=ip, port=8192, packVer=2 )
                self.dest0 = self.udp.application(dest=0)
                self.dest1 = self.udp.application(dest=1)

            self.srp = rogue.protocols.srp.SrpV3()
            self.cmd = rogue.interfaces.stream.Master()

            dataWriter = pyrogue.utilities.fileio.LegacyStreamWriter(name='DataWriter')

            self.srp == self.dest0
            self.dest1 >> dataWriter.getDataChannel()
            self.dest1 << self.cmd

            # Connect update stream
            self >> dataWriter.getYamlChannel()

            if debug:
                fp = KpixDaq.KpixStreamInfo()
                self.dest1 >> fp

            self.add(dataWriter)
            self.add(KpixDaq.DesyTrackerRunControl())

        self.add(KpixDaq.DesyTracker(memBase=self.srp, cmd=self.cmd, offset=0, rssi=rssiEn, sim=sim, enabled=True, expand=True))



    def stop(self):
        if hasattr(self, 'udp'):
            self.udp._rssi.stop()
        else:
            # sim mode
            self.dest0.close()
            self.dest1.close()
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
            "--serverPort",
            type = int,
            default = 0,
            help = "ZMQ Server Port")

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
