import pyrogue as pr
import KpixDaq as kd

class KpixDaqCore(pr.Device):
    def __init__(self, numKpix, extTrigEnum=None, **kwargs):
        super().__init__(**kwargs)

        self.add(kd.SysConfig(
            offset = 0x0000))

        self.add(kd.KpixClockGen(
            offset=0x100))

        self.add(kd.AcquisitionControl(
            offset = 0x200,
            extTrigEnum = extTrigEnum))

        for i in range(numKpix):
            self.add(kd.KpixAsic(
                name = f'KpixAsic[{i}]',
                offset = 0x100000 + (i*0x1000),
                expand = False))

        # Internal KPIX
        self.add(kd.LocalKpix(
            name = f'KpixAsic[{numKpix}]',
            offset = 0x100000 + (numKpix*0x1000),
            expand = False))

        for i in range(numKpix):
            self.add(kd.KpixDataRx(
                name = f'KpixDataRx[{i}]',
                offset = 0x200000 + (i*0x100)))
                
                
