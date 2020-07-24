import argparse

import rogue
import pyrogue
import pyrogue.interfaces.simulation
import pyrogue.protocols
import pyrogue.utilities.fileio
import pyrogue.utilities.prbs

import KpixDaq

class DesyTrackerRoot(pyrogue.Root):
    def __init__(
            self,
            dataDebug=False,
            hwEmu=False,
            sim=False,
            ethDebug=False,
            ip='192.168.2.10',
            **kwargs):

        super().__init__(**kwargs)

        self.sim = sim

        if hwEmu:
            srp = pyrogue.interfaces.simulation.MemEmulate()
            dataStream = rogue.interfaces.stream.Master()
            cmd = rogue.interfaces.stream.Master()

            self.manage(srp, dataStream, cmd)

        else:
            if sim:
                dest0 = rogue.interfaces.stream.TcpClient('localhost', 9000)
                dest1 = rogue.interfaces.stream.TcpClient('localhost', 9002)

                self.manage(dest0, dest1)

            else:
                udp = pyrogue.protocols.UdpRssiPack( host=ip, port=8192, packVer=2 )
                dest0 = udp.application(dest=0)
                dest1 = udp.application(dest=1)
                if ethDebug:
                    dest2 = udp.application(dest=2)
                    dest3 = udp.application(dest=3)

                self.manage(udp, dest0, dest1, dest2, dest3)

            srp = rogue.protocols.srp.SrpV3()
            cmd = rogue.interfaces.stream.Master()

            self.manage(srp, cmd)

            dataWriter = pyrogue.utilities.fileio.LegacyStreamWriter(name='DataWriter')

            srp == dest0
            dest1 >> dataWriter.getDataChannel()
            dest1 << cmd

            # Connect update stream
            self >> dataWriter.getYamlChannel()

            if dataDebug:
                fp = KpixDaq.KpixStreamInfo()
                dest1 >> fp

            self.add(dataWriter)
            self.add(KpixDaq.DesyTrackerRunControl())

        self.add(KpixDaq.DesyTracker(memBase=srp, cmd=cmd, offset=0, ethDebug=ethDebug, sim=sim, enabled=True, expand=True))

        if ethDebug:
            self.add(udp)
            self.add(pyrogue.utilities.prbs.PrbsTx(stream=dest2))
            self.add(pyrogue.utilities.prbs.PrbsRx(stream=dest2))

            self.add(pyrogue.utilities.prbs.PrbsTx(name='PrbsTxLoopback', stream=dest3))
            self.add(pyrogue.utilities.prbs.PrbsRx(name='PrbsRxLoopback', stream=dest3))


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
            "--dataDebug",
            required = False,
            action = 'store_true',
            help     = "enable data debug")

        self.add_argument(
            "--ethDebug",
            required = False,
            action = 'store_true',
            help = 'Enable PRBS')
