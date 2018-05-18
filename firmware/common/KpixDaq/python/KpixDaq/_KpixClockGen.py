import pyrogue as pr

class KpixClockGen(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        clockRate = 5.0e-9

        self.add(pr.RemoteVariable(
            name = 'ClkSelReadout',
            mode = 'RW',
            offset= 0x00,
            bitOffset=0,
            bitSize=8))

        self.add(pr.LinkVariable(
            name = 'ReadoutClkPeriod',
            mode = 'RO',
            variable = self.ClkSelReadout,
            linkedGet = lambda: self.ClkSelReadout.value() * clockRate))
        
        
        self.add(pr.RemoteVariable(
            name = 'ClkSelDigitize',
            mode = 'RW',
            offset= 0x04,
            bitOffset=0,
            bitSize=8))

        self.add(pr.LinkVariable(
            name = 'DigitizeClkPeriod',
            mode = 'RO',
            variable = self.ClkSelDigitize,
            linkedGet = lambda: self.ClkSelDigitize.value() * clockRate))
            
        
        self.add(pr.RemoteVariable(
            name = 'ClkSelAcquire',
            mode = 'RW',
            offset= 0x08,
            bitOffset=0,
            bitSize=8))

        self.add(pr.LinkVariable(
            name = 'AcquireClkPeriod',
            mode = 'RO',
            variable = self.ClkSelAcquire,
            linkedGet = lambda: self.ClkSelAcquire.value() * clockRate))

        self.add(pr.RemoteVariable(
            name = 'ClkSelIdle',
            mode = 'RW',
            offset= 0x0C,
            bitOffset=0,
            bitSize=8))

        self.add(pr.LinkVariable(
            name = 'IldeClkPeriod',
            mode = 'RO',
            variable = self.ClkSelIdle,
            linkedGet = lambda: self.ClkSelIdle.value() * clockRate))
        
        self.add(pr.RemoteVariable(
            name = 'ClkSelPrecharge',
            mode = 'RW',
            offset= 0x10,
            bitOffset=0,
            bitSize=12))

        self.add(pr.LinkVariable(
            name = 'PrechargeClkPeriod',
            mode = 'RO',
            variable = self.ClkSelPrecharge,
            linkedGet = lambda: self.ClkSelPrecharge.value() * clockRate))
        
        
