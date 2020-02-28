import pyrogue

import surf.xilinx
import surf.devices.linear
import surf.devices.nxp

import KpixDaq

class DesyTrackerEnvironmentMonitor(pyrogue.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(surf.xilinx.Xadc(
            offset=0x03000000,
            hidden=True))

        self.add(surf.devices.linear.Ltc4151(
            offset = 0x04000000,
            senseRes = 0.02,
            hidden=True))

        self.add(surf.devices.nxp.Sa56004x(
            description = "Board temperate monitor",
            offset = 0x04000400,
            hidden=True))

        for i in range(4):
            self.add(KpixDaq.Si7006(
                name = f'Si7006[{i}]',
                enabled = False,
                offset = 0x07000000 + (i*0x1000)))

        self.add(pyrogue.LinkVariable(
            name = 'FpgaTemperature',
            pollInterval = 1,
            variable = self.Xadc.Temperature))

        self.add(pyrogue.LinkVariable(
            name = 'BoardTemperature',
            pollInterval = 1,
            variable = self.Sa56004x.LocalTemperature))

        self.add(pyrogue.LinkVariable(
            name = 'InputVoltage',
            pollInterval = 1,
            variable = self.Ltc4151.Vin))

        self.add(pyrogue.LinkVariable(
            name = 'InputCurrent',
            pollInterval = 1,
            variable = self.Ltc4151.Iin))

        self.add(pyrogue.LinkVariable(
            name = 'InputPower',
            pollInterval = 1,
            variable = self.Ltc4151.Pin))
