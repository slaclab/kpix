import pyrogue as pr

class SysConfig(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(pr.RemoteVariable(
            name = 'RawDataMode',
            mode = 'RW',
            offset= 0x04,
            bitOffset=2,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'AutoReadDisable',
            mode = 'RW',
            offset= 0x04,
            bitOffset=3,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'KpixEnable',
            mode = 'RW',
            offset= 0x08,
            bitOffset=0,
            bitSize=32,
            base=pr.UInt))

        self.add(pr.RemoteCommand(
            name = 'KpixReset',
            offset = 0x00,
            bitOffset = 0,
            bitSize = 1,
            function = RemoteCommand.touchOne))
        
        
        
