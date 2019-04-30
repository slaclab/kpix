import pyrogue as pr

class Si7006(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(pr.RemoteVariable(
            name = 'HumidityRaw',
            mode = 'RO',
            offset = (0xE5 << 2),
            bitOffset = 0,
            bitSize = 16,
            base = pr.UInt))

        self.add(pr.LinkVariable(
            name = 'Humidity',
            mode = 'RO',
            units = '%',
            dependencies = [self.HumidityRaw],
            linkedGet = lambda: ((125 * self.HumidityRaw.value())/65536)-6 ))

        self.add(pr.RemoteVariable(
            name = 'TemperatureRaw',
            mode = 'RO',
            offset = (0xE3 << 2),
            bitOffset = 0,
            bitSize = 16,
            base = pr.UInt))

        self.add(pr.LinkVariable(
            name = 'Temperature',
            mode = 'RO',
            units = 'degC',
            dependencies = [self.HumidityRaw],
            linkedGet = lambda: ((175.72 * self.HumidityRaw.value())/65536)-46.85 ))        
