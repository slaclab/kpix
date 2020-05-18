import pyrogue as pr

class AcquisitionControl(pr.Device):
    def __init__(self, extTrigEnum=None, **kwargs):
        super().__init__(**kwargs)



        if extTrigEnum is None:
            extTrigEnum = {x:str(x) for x in range(8)}

        origExtTrigEnum = extTrigEnum.copy()

        for k in list(extTrigEnum.keys()):
            v = extTrigEnum.pop(k)
            k1 = k | 0b1000
            extTrigEnum[k1] = v

        extTrigEnum[0] = 'Disabled'

        self.add(pr.RemoteVariable(
            name = 'Running',
            mode = 'RW',
            offset = 0x10,
            bitSize = 1,
            bitOffset = 0,
            pollInterval = 1,
            base = pr.Bool))

        self.add(pr.RemoteVariable(
            name = "RunTime",
            mode = 'RO',
            offset = 0x14,
            bitSize = 64,
            pollInterval = 1,
            base = pr.UInt))

        self.add(pr.RemoteVariable(
            name = 'AcqRateRaw',
            mode = 'RO',
            offset = 0x50,
            bitSize = 32,
            bitOffset = 0,
            pollInterval = 1,
            hidden = True))

        self.add(pr.LinkVariable(
            name = 'AcqRate',
            dependencies = [self.AcqRateRaw],
            units = 'Hz',
            disp = '{:0.3f}',
            linkedGet = lambda: 1.0/((self.AcqRateRaw.value()+1) * 5.0e-9))            

        self.add(pr.RemoteVariable(
            name = 'ExtTrigSrc',
            mode = 'RW',
            offset= 0x00,
            bitOffset=0,
            bitSize=4,
            enum = extTrigEnum))

        self.add(pr.RemoteVariable(
            name = 'ExtTimestampSrc',
            mode = 'RW',
            offset= 0x04,
            bitOffset=0,
            bitSize=4,
            enum = extTrigEnum))

        self.add(pr.RemoteVariable(
            name = 'ExtAcquisitionSrc',
            mode = 'RW',
            offset= 0x08,
            bitOffset=0,
            bitSize=4,
            enum = extTrigEnum))

        self.add(pr.RemoteVariable(
            name = 'ExtStartSrc',
            mode = 'RW',
            offset= 0x0C,
            bitOffset=0,
            bitSize=4,
            enum = extTrigEnum))


        self.add(pr.RemoteVariable(
            name = 'Calibrate',
            mode = 'RW',
            offset= 0x20,
            bitOffset=0,
            bitSize=1,
            base=pr.Bool))

        for k,v in origExtTrigEnum.items():
            self.add(pr.RemoteVariable(
                name = f'{v}RisingEdgeCount',
                mode = 'RO',
                offset = 0x30 + k*4,
                bitOffset = 0,
                bitSize = 32,
                base = pr.UInt,
                pollInterval = 1,
                disp = '{:d}'))

        self.add(pr.RemoteCommand(
            name = 'CountReset',
            offset = 0x24,
            bitOffset = 0,
            bitSize = 1,
            function = pr.RemoteCommand.touchOne))

    def countReset(self):
        self.CountReset()
