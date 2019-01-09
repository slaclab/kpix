import pyrogue as pr

class AcquisitionControl(pr.Device):
    def __init__(self, extTrigEnum=None, **kwargs):
        super().__init__(**kwargs)

        if extTrigEnum is None:
            extTrigEnum = {x:str(x) for x in range(8)}

        self.add(pr.RemoteVariable(
            name = "RunTime",
            mode = 'RO',
            offset = 0x14,
            bitSize = 64,
            base = pr.UInt))

        self.add(pr.RemoteVariable(
            name = 'ExtTrigSrc',
            mode = 'RW',
            offset= 0x00,
            bitOffset=0,
            bitSize=3,
            enum = extTrigEnum))

        self.add(pr.RemoteVariable(
            name = 'ExtTrigEn',
            mode = 'RW',
            offset= 0x10,
            bitOffset=0,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'ExtTimestampSrc',
            mode = 'RW',
            offset= 0x04,
            bitOffset=0,
            bitSize=3,
            enum = extTrigEnum))
        
        self.add(pr.RemoteVariable(
            name = 'ExtTimestampEn',
            mode = 'RW',
            offset= 0x10,
            bitOffset=1,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'ExtAcquisitionSrc',
            mode = 'RW',
            offset= 0x08,
            bitOffset=0,
            bitSize=3,
            enum = extTrigEnum))

        self.add(pr.RemoteVariable(
            name = 'ExtAcquisitionEn',
            mode = 'RW',
            offset= 0x10,
            bitOffset=2,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'ExtStartSrc',
            mode = 'RW',
            offset= 0x0C,
            bitOffset=0,
            bitSize=3,
            enum = extTrigEnum))

        self.add(pr.RemoteVariable(
            name = 'ExtStartEn',
            mode = 'RW',
            offset= 0x10,
            bitOffset=3,
            bitSize=1,
            base=pr.Bool))
        

        self.add(pr.RemoteVariable(
            name = 'Calibrate',
            mode = 'RW',
            offset= 0x20,
            bitOffset=0,
            bitSize=1,
            base=pr.Bool))

#         self.add(pr.RemoteCommand(
#             name = "RegAcquisition",
#             offset = 0x14,
#             bitOffset = 0,
#             bitSize = 1,
#             function = pr.RemoteCommand.touchOne))
        
