import pyrogue as pr

class KpixDataRx(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(pr.RemoteVariable(
            name = 'MarkerErrors',
            mode = 'RO',
            offset= 0x00,
            bitOffset=0,
            bitSize=8,
            disp = '{:d}'))

        self.add(pr.RemoteVariable(
            name = 'OverflowErrors',
            mode = 'RO',
            offset= 0x04,
            bitOffset=0,
            bitSize=8,
            disp = '{:d}'))

        self.add(pr.RemoteVariable(
            name = 'HeaderParityErrors',
            mode = 'RO',
            offset= 0x08,
            bitOffset=0,
            bitSize=8,
            disp = '{:d}'))

        self.add(pr.RemoteVariable(
            name = 'DataParityErrors',
            mode = 'RO',
            offset= 0x0C,
            bitOffset=0,
            bitSize=8,
            disp = '{:d}'))

        self.add(pr.RemoteVariable(
            name = 'FrameCount',
            mode = 'RO',
            offset= 0x14,
            bitOffset=0,
            bitSize=32,
            disp = '{:d}'))
        

        self.add(pr.RemoteCommand(
            name = "ResetCounters",
            offset = 0x10,
            bitOffset = 1,
            bitSize = 1,
            function = pr.RemoteCommand.touchOne))

    def countReset(self):
        self.ResetCounters()
        
        
