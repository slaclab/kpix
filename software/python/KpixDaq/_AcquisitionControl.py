import pyrogue as pr

class AcquisitionControl(pr.Device):
    def __init__(self, extTrigEnum=None, **kwargs):
        super().__init__(**kwargs)

        if extTrigEnum is None:
            extTrigEnum = {x:str(x) for x in range(8)}

#         for k,v in extTrigEnum.items():
#             extTrigEnum.pop(k)
#             n = k | 0b1000
#             extTrigEnum[n] = k

#         extTrigEnum

        self.add(pr.RemoteVariable(
            name = "RunTime",
            mode = 'RO',
            offset = 0x14,
            bitSize = 64,
            base = pr.UInt))

        extTrigList = ['Disabled'] + list(extTrigEnum.values())
        
        def extSet(dev, var, value, write):
            if value == 'Disabled':
                var.dependencies[0].set(0, write=write)
                var.dependencies[1].set(False, write=write)
                
            else:
                print(f'Setting {var.dependencies[0].path}.setDisp({value})')
                var.dependencies[0].setDisp(value)
                var.dependencies[1].set(True)

        def extGet(var):
            if var.dependencies[1] is False:
                return 'Disabled'
            else:
                return var.dependencies[0].valueDisp()


        self.add(pr.RemoteVariable(
            name = 'ExtTrigSrcRaw',
            mode = 'RW',
            hidden = True,
            offset= 0x00,
            bitOffset=0,
            bitSize=3,
            enum = extTrigEnum))

        self.add(pr.RemoteVariable(
            name = 'ExtTrigEn',
            mode = 'RW',
            hidden = True,
            offset= 0x10,
            bitOffset=0,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.LinkVariable(
            name = 'ExtTrigSrc',
            mode = 'RW',
            dependencies = [self.ExtTrigSrcRaw, self.ExtTrigEn],
            disp = extTrigList,
            linkedGet = extGet,
            linkedSet = extSet))

        self.add(pr.RemoteVariable(
            name = 'ExtTimestampSrcRaw',
            mode = 'RW',
            hidden = True,
            offset= 0x04,
            bitOffset=0,
            bitSize=3,
            enum = extTrigEnum))
        
        self.add(pr.RemoteVariable(
            name = 'ExtTimestampEn',
            mode = 'RW',
            hidden = True,
            offset= 0x10,
            bitOffset=1,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.LinkVariable(
            name = 'ExtTimestampSrc',
            mode = 'RW',
            dependencies = [self.ExtTimestampSrcRaw, self.ExtTimestampEn],
            disp = extTrigList,
            linkedGet = extGet,
            linkedSet = extSet))
        

        self.add(pr.RemoteVariable(
            name = 'ExtAcquisitionSrcRaw',
            mode = 'RW',
            hidden = True,
            offset= 0x08,
            bitOffset=0,
            bitSize=3,
            enum = extTrigEnum))

        self.add(pr.RemoteVariable(
            name = 'ExtAcquisitionEn',
            mode = 'RW',
            hidden = True,
            offset= 0x10,
            bitOffset=2,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.LinkVariable(
            name = 'ExtAcquisitionSrc',
            mode = 'RW',
            dependencies = [self.ExtAcquisitionSrcRaw, self.ExtAcquisitionEn],
            disp = extTrigList,
            linkedGet = extGet,
            linkedSet = extSet))
        

        self.add(pr.RemoteVariable(
            name = 'ExtStartSrcRaw',
            mode = 'RW',
            hidden = True,
            offset= 0x0C,
            bitOffset=0,
            bitSize=3,
            enum = extTrigEnum))

        self.add(pr.RemoteVariable(
            name = 'ExtStartEn',
            mode = 'RW',
            hidden = True,
            offset= 0x10,
            bitOffset=3,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.LinkVariable(
            name = 'ExtStartSrc',
            mode = 'RW',
            dependencies = [self.ExtStartSrcRaw, self.ExtStartEn],
            disp = extTrigList,
            linkedGet = extGet,
            linkedSet = extSet))
        

        self.add(pr.RemoteVariable(
            name = 'Calibrate',
            mode = 'RW',
            offset= 0x20,
            bitOffset=0,
            bitSize=1,
            base=pr.Bool))

        for k,v in extTrigEnum.items():
            self.add(pr.RemoteVariable(
                name = f'{v}RisingEdgeCount',
                mode = 'RO',
                offset = 0x30 + k*4,
                bitOffset = 0,
                bitSize = 32,
                base = pr.UInt,
                disp = '{:d}'))

        self.add(pr.RemoteCommand(
            name = 'CountReset',
            offset = 0x24,
            bitOffset = 0,
            bitSize = 1,
            function = pr.RemoteCommand.touchOne))

    def countReset(self):
        self.CountReset()
