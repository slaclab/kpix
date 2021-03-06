import rogue
import pyrogue

import surf.axi
import surf.protocols.rssi
import surf.devices.micron
import surf.ethernet.gige
import surf.ethernet.udp
import surf.xilinx

import KpixDaq

class FrameInfo(rogue.interfaces.stream.Slave):
    def __init__(self):
        rogue.interfaces.stream.Slave.__init__(self)

    def _acceptFrame(self, frame):
        print(f' Got frame with {frame.getPayload()} bytes')


class DesyTracker(pyrogue.Device):
    def __init__(self, cmd, ethDebug, sim, **kwargs):
        super().__init__(**kwargs)

        self.__acquireCmd = bytearray([0xAA])
        self.__startCmd = bytearray([0x55])

        @self.command()
        def EthAcquire():
            f = cmd._reqFrame(1, False)
            f.write(self.__acquireCmd, 0)
            cmd._sendFrame(f)

        @self.command()
        def EthStart():
            f = cmd._reqFrame(1, False)
            f.write(self.__startCmd, 0)
            cmd._sendFrame(f)


        self.add(surf.axi.AxiVersion(
            offset = 0x0000,
            expand = True))

        if not sim:
            self.add(KpixDaq.DesyTrackerEnvironmentMonitor(
                name='EnvironmentMonitor',
                expand=True))

        extTrigEnum = {
            0: 'BncTrig',
            1: 'Lemo0',
            2: 'Lemo1',
            3: 'TluSpill',
            4: 'TluStart',
            5: 'TluTrigger',
            6: 'EthAcquire',
            7: 'EthStart'}

        self.add(KpixDaq.TluMonitor(
            offset = 0x06000000,
            expand = True))

        self.add(KpixDaq.KpixDaqCore(
            offset = 0x01000000,
            numKpix = 24,
            extTrigEnum = extTrigEnum,
            sim = sim,
            expand = True))

        if ethDebug and not sim:
            self.add(KpixDaq.DesyTrackerEthCore(
                offset = 0x2000000))

        if not sim:
            self.add(surf.devices.micron.AxiMicronN25Q(
                offset = 0x05000000,
                addrMode = False,
                hidden = True))
