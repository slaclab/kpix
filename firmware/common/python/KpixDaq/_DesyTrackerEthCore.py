import pyrogue as pr

import surf.protocols.rssi
import surf.ethernet.udp

class DesyTrackerEthCore(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(surf.protocols.rssi.RssiCore(
            offset = 0x011000,
            expand = False))

        self.add(surf.ethernet.gige.GigEthGtx7(
            gtxe2_read_only = True,
            offset = 0x000000))

        self.add(surf.ethernet.udp.UdpEngine(
            offset = 0x010000,
            numSrv = 1))

        self.add(surf.protocols.ssi.SsiPrbsRx(
            offset = 0x012000))

        self.add(surf.protocols.ssi.SsiPrbsTx(
            offset = 0x012100))
