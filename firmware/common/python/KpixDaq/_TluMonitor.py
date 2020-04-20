import pyrogue

class TluMonitor(pyrogue.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(pyrogue.RemoteVariable(
            name = 'TluClkFreqRaw',
            offset = 0x00,
            mode = 'RO',
            base = pyrogue.UInt,
        ))

        self.add(pyrogue.LinkVariable(
            name = 'TluClkFreq',
            dependencies = [self.TluClkFreqRaw],
            linkedGet = lambda: self.TluClkFreqRaw.value() * 1.0e-6,
            value = 0.0,
            pollInterval = 1,
            units = 'MHz',
            disp = '{:1.3f}',
        ))

        self.add(pyrogue.RemoteVariable(
            name = 'TriggerCount',
            offset = 0x04,
            mode = 'RO',
            pollInterval = 1,
            base = pyrogue.UInt,
        ))

        self.add(pyrogue.RemoteVariable(
            name = 'SpillCount',
            offset = 0x08,
            mode = 'RO',
            pollInterval = 1,
            base = pyrogue.UInt,
        ))

        self.add(pyrogue.RemoteVariable(
            name = 'StartCount',
            offset = 0x0C,
            mode = 'RO',
            pollInterval = 1,
            base = pyrogue.UInt,
        ))

        self.add(pyrogue.RemoteCommand(
            name = 'RstCounts',
            offset = 0x10,
            function = pyrogue.RemoteCommand.toggle
        ))

        self.add(pyrogue.RemoteVariable(
            name = 'ClkSel',
            offset = 0x20,
            mode = 'RW',
            base = pyrogue.UInt,
            enum = {
                0: 'EthClk',
                1: 'TluClk',
            }
        ))

    def countReset(self):
        self.RstCounts()
