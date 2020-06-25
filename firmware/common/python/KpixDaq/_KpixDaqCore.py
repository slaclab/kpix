import pyrogue as pr
import KpixDaq

class KpixDaqCore(pr.Device):
    def __init__(self, numKpix, extTrigEnum=None, sim=False, **kwargs):
        super().__init__(**kwargs)

        self.numKpix = numKpix

        self.add(KpixDaq.SysConfig(
            numKpix = numKpix,
            offset = 0x0000))

        self.add(KpixDaq.KpixClockGen(
            offset=0x100))

        self.add(KpixDaq.AcquisitionControl(
            offset = 0x200,
            extTrigEnum = extTrigEnum))

        self.add(KpixDaq.EventBuilder(
            offset = 0x300))

        self.add(KpixAsicArray(
            sysConfig = self.SysConfig,
            offset = 0x100000,
            numKpix = numKpix,
            sim = sim))


        self.add(KpixDataRxArray(
            offset = 0x200000,
            numKpix = numKpix))


class KpixAsicArray(pr.Device):
    def __init__(self, numKpix, sysConfig, sim, **kwargs):
        super().__init__(**kwargs)
        KpixClass = KpixDaq.KpixAsic if sim is False else KpixDaq.KpixLocal
        for i in range(numKpix):
            self.add(KpixClass(
                name = f'KpixAsic[{i}]',
                offset = 0x100000 + (i*0x1000),
                enabled = False,
                expand = False))

            # Link SysConfig.KpixEnable[x] to KpixAsic[x].enable
            self.KpixAsic[i].enable.addListener(sysConfig.KpixEnableUpdate)


        # Internal KPIX
        self.add(KpixDaq.KpixLocal(
            name = f'KpixAsic[{numKpix}]',
            offset = 0x100000 + (numKpix*0x1000),
            enabled = True,
            expand = False))

        self.KpixAsic[numKpix].enable.addListener(sysConfig.KpixEnableUpdate)

class KpixDataRxArray(pr.Device):
    def __init__(self, numKpix, **kwargs):
        super().__init__(**kwargs)
        for i in range(numKpix+1):
            self.add(KpixDaq.KpixDataRx(
                name = f'KpixDataRx[{i}]',
                offset = (i*0x100),
                expand=False))
