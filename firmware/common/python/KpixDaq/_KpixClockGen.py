import pyrogue as pr

class KpixClockGen(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        clockRate = 5.0

        def getPeriod(dev, var):
            return (var.dependencies[0].value() + 1) * clockRate * 2

        self.add(pr.RemoteVariable(
            name = 'ClkSelReadout',
            mode = 'RW',
            disp = '{:d}',
            offset= 0x00,
            bitOffset=0,
            bitSize=8))

        self.add(pr.LinkVariable(
            name = 'ReadoutClkPeriod',
            mode = 'RO',
            units = 'ns',
            dependencies = [self.ClkSelReadout],
            disp = '{:2.3f}',
            linkedGet = getPeriod))


        self.add(pr.RemoteVariable(
            name = 'ClkSelDigitize',
            mode = 'RW',
            disp = '{:d}',
            offset= 0x04,
            bitOffset=0,
            bitSize=8))

        self.add(pr.LinkVariable(
            name = 'DigitizeClkPeriod',
            mode = 'RO',
            units = 'ns',
            dependencies = [self.ClkSelDigitize],
            disp = '{:2.3f}',
            linkedGet = getPeriod))


        self.add(pr.RemoteVariable(
            name = 'ClkSelAcquire',
            mode = 'RW',
            disp = '{:d}',
            units = 'ns',
            offset= 0x08,
            bitOffset=0,
            bitSize=8))

        self.add(pr.LinkVariable(
            name = 'AcquireClkPeriod',
            mode = 'RO',
            units = 'ns',
            dependencies = [self.ClkSelAcquire],
            disp = '{:2.3f}',
            linkedGet = getPeriod))

        self.add(pr.RemoteVariable(
            name = 'ClkSelIdle',
            mode = 'RW',
            disp = '{:d}',
            offset= 0x0C,
            bitOffset=0,
            bitSize=8))

        self.add(pr.LinkVariable(
            name = 'IldeClkPeriod',
            mode = 'RO',
            units = 'ns',
            dependencies = [self.ClkSelIdle],
            disp = '{:2.3f}',
            linkedGet = getPeriod))

        self.add(pr.RemoteVariable(
            name = 'ClkSelPrecharge',
            mode = 'RW',
            disp = '{:d}',
            offset= 0x10,
            bitOffset=0,
            bitSize=12))

        self.add(pr.LinkVariable(
            name = 'PrechargeClkPeriod',
            mode = 'RO',
            units = 'ns',
            dependencies = [self.ClkSelPrecharge],
            disp = '{:2.3f}',
            linkedGet = getPeriod))

        self.add(pr.RemoteVariable(
            name = 'SampleDelay',
            mode = 'RW',
            offset = 0x14,
            bitOffset = 0,
            bitSize = 8,
            disp = '{:d}'))

        self.add(pr.RemoteVariable(
            name = 'SampleEdge',
            mode = 'RW',
            offset = 0x14,
            bitOffset = 31,
            bitSize = 1,
            enum = {
                1: 'Rise',
                0: 'Fall'}))

        self.add(pr.RemoteVariable(
            name = 'OutputDelay',
            mode = 'RW',
            offset = 0x18,
            bitOffset = 0,
            bitSize = 8,
            disp = '{:d}'))

        self.add(pr.RemoteVariable(
            name = 'OutputEdge',
            mode = 'RW',
            offset = 0x18,
            bitOffset = 31,
            bitSize = 1,
            enum = {
                1: 'Rise',
                0: 'Fall'}))
