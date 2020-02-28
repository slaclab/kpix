import pyrogue as pr

class Si7006(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.forceCheckEach = True

#        self.add(pr.RemoteVariable(
#            name = 'Temp',
#            mode = 'RO',
#            offset = 0xE0 << 2,
#            bitOffset = 0,
#            bitSize = 16,
#            base = pr.UInt))

        self.add(pr.RemoteVariable(
            name = 'HumidityRaw',
            mode = 'RO',
            hidden = True,
            offset = (0xE5 << 2),
            bitOffset = 0,
            bitSize = 16,
            base = pr.UInt))

        self.add(pr.LinkVariable(
            name = 'Humidity',
            mode = 'RO',
            units = '%',
            disp = '{:2.3f}',
            dependencies = [self.HumidityRaw],
            linkedGet = lambda: ((125 * self.HumidityRaw.value())/65536)-6 ))

        self.add(pr.RemoteVariable(
            name = 'TemperatureRaw',
            mode = 'RO',
            hidden = True,
            offset = (0xE3 << 2),
            bitOffset = 0,
            bitSize = 16,
            base = pr.UInt))

        self.add(pr.LinkVariable(
            name = 'Temperature',
            mode = 'RO',
            units = 'degC',
            disp = '{:2.3f}',
            dependencies = [self.TemperatureRaw],
            linkedGet = lambda: ((175.72 * self.TemperatureRaw.value())/65536)-46.85 ))
