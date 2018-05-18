import pyrogue as pr

class KpixDataRx(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(pr.RemoteVariable(
            name = 'MarkerErrors',
            mode = 'R0',
            offset= 0x00,
            bitOffset=0,
            bitSize=8,
            disp = '{:d}'))

        self.add(pr.RemoteVariable(
            name = 'OverflowErrors',
            mode = 'R0',
            offset= 0x04,
            bitOffset=0,
            bitSize=8,
            disp = '{:d}'))

        self.add(pr.RemoteVariable(
            name = 'HeaderParityErrors',
            mode = 'R0',
            offset= 0x08,
            bitOffset=0,
            bitSize=8,
            disp = '{:d}'))

        self.add(pr.RemoteVariable(
            name = 'DataParityErrors',
            mode = 'R0',
            offset= 0x0C,
            bitOffset=0,
            bitSize=8,
            disp = '{:d}'))

        self.add(pr.RemoteCommand(
            name = "ResetCounters",
            offset = 0x10,
            bitOffset = 1,
            bitSize = 1,
            function = RemoteCommand.touchOne))

    def countReset(self):
        self.ResetCounters()
        
        
