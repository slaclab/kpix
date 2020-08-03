import pyrogue as pr

class KpixLocal(pr.Device):
    def __init__(self, sysConfig=None, version=12, **kwargs):
        super().__init__(**kwargs)

        self.forceCheckEach = True

        self.STATUS = 0x0000*4
        self.CONFIG = 0x0001*4
        self.TIMER_A = 0x0008*4
        self.TIMER_B = 0x0009*4
        self.TIMER_C = 0x000A*4
        self.TIMER_D = 0x000B*4
        self.TIMER_E = 0x000C*4
        self.TIMER_F = 0x000D*4
        self.CAL_DELAY_0 = 0x0010*4
        self.CAL_DELAY_1 = 0x0011*4
        self.DAC_0 = 0x0020*4
        self.DAC_1 = 0x0021*4
        self.DAC_2 = 0x0022*4
        self.DAC_3 = 0x0023*4
        self.DAC_4 = 0x0024*4
        self.DAC_5 = 0x0025*4
        self.DAC_6 = 0x0026*4
        self.DAC_7 = 0x0027*4
        self.DAC_8 = 0x0028*4
        self.DAC_9 = 0x0029*4
        self.CONTROL = 0x0030*4
        self.CHAN_MODE_A = list(range(0x0040*4, 0x0060*4, 4))
        self.CHAN_MODE_B = list(range(0x0060*4, 0x0080*4, 4))

        # Status regs
        self.add(pr.RemoteVariable(
            name = 'StatCmdPerr',
            offset=self.STATUS,
            mode='RO',
            bitOffset=0,
            bitSize=1))

        self.add(pr.RemoteVariable(
            name = 'StatDataPerr',
            offset=self.STATUS,
            mode='RO',
            bitOffset=1,
            bitSize=1))

        self.add(pr.RemoteVariable(
            name = 'StatTempEn',
            offset=self.STATUS,
            mode='RO',
            bitOffset=2,
            bitSize=1))

        self.add(pr.RemoteVariable(
            name = 'StatTempIdValue',
            offset=self.STATUS,
            mode='RO',
            bitOffset=24,
            bitSize=8))

        # Config Regs
        self.add(pr.RemoteVariable(
            name = 'CfgAutoReadDisable',
            offset=self.CONFIG,
            bitOffset=2,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'CfgForceTemp',
            offset=self.CONFIG,
            bitOffset=3,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'CfgDisableTemp',
            offset=self.CONFIG,
            bitOffset=4,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'CfgAutoStatusReadEn',
            offset=self.CONFIG,
            bitOffset=5,
            bitSize=1,
            base=pr.Bool))

        # Timer stuff

        self.add(pr.RemoteVariable(
            name = 'TimeResetOn',
            offset=self.TIMER_A,
            bitOffset=0,
            bitSize=16))

        self.add(pr.RemoteVariable(
            name = 'TimeResetOff',
            offset=self.TIMER_A,
            bitOffset=16,
            bitSize=16))

        self.add(pr.RemoteVariable(
            name = 'TimeOffsetNullOff',
            offset=self.TIMER_B,
            bitOffset=0,
            bitSize=16))

        self.add(pr.RemoteVariable(
            name = 'TimeLeakageNullOff',
            offset=self.TIMER_B,
            bitOffset=16,
            bitSize=16))

        self.add(pr.RemoteVariable(
            name = 'TimeDeselDelay',
            offset=self.TIMER_F,
            bitOffset=0,
            bitSize=8))

        self.add(pr.RemoteVariable(
            name = 'TimeBunchClkDelay',
            offset=self.TIMER_F,
            bitOffset=8,
            bitSize=16))

        self.add(pr.RemoteVariable(
            name = 'TimeDigitizeDelay',
            offset=self.TIMER_F,
            bitOffset=24,
            bitSize=8))

        self.add(pr.RemoteVariable(
            name = 'TimePowerUpDigOn',
            offset=self.TIMER_C,
            bitOffset=0,
            bitSize=16))

        self.add(pr.RemoteVariable(
            name = 'TimeThreshOff',
            offset=self.TIMER_C,
            bitOffset=16,
            bitSize=16))

        self.add(pr.RemoteVariable(
            name = 'TimerD',
            offset=self.TIMER_D,
            bitOffset=0,
            bitSize=32,
            hidden=True))

        self.add(pr.LinkVariable(
            name = 'TrigInhibitOff',
            dependencies = [self.TimerD, self.TimeBunchClkDelay],
            linkedGet = lambda: round(((self.TimerD.value()-self.TimeBunchClkDelay.value())-1)/8),
            linkedSet = lambda value, write: self.TimerD.set((round(value)*8)+self.TimeBunchClkDelay.value()+1, write=write)))

        # setComp(0,1,1,'')
        self.add(pr.RemoteVariable(
            name = 'BunchClockCountRaw',
            offset=self.TIMER_E,
            bitOffset=0,
            bitSize=16,
            hidden=True))

        self.add(pr.LinkVariable(
            name = 'BunchClockCount',
            dependencies = [self.BunchClockCountRaw],
            linkedGet = lambda: self.BunchClockCountRaw.value() + 1,
            linkedSet = lambda value, write: self.BunchClockCountRaw.set(value - 1, write)))


        self.add(pr.RemoteVariable(
            name = 'TimePowerUpOn',
            offset=self.TIMER_E,
            bitOffset=16,
            bitSize=16))


        # Calibration Stuff
        self.add(pr.RemoteVariable(
            name = 'Cal0Delay',
            offset=self.CAL_DELAY_0,
            bitOffset=0,
            bitSize=13))

        self.add(pr.RemoteVariable(
            name = 'Cal1Delay',
            offset=self.CAL_DELAY_0,
            bitOffset=16,
            bitSize=13))

        self.add(pr.RemoteVariable(
            name = 'Cal2Delay',
            offset=self.CAL_DELAY_1,
            bitOffset=0,
            bitSize=13))

        self.add(pr.RemoteVariable(
            name = 'Cal3Delay',
            offset=self.CAL_DELAY_1,
            bitOffset=16,
            bitSize=13))

        self.add(pr.RemoteVariable(
            name = 'CalCount',
            offset=[self.CAL_DELAY_0, self.CAL_DELAY_0, self.CAL_DELAY_1, self.CAL_DELAY_1],
            bitOffset=[15, 31, 15, 31],
            bitSize=[1, 1, 1, 1],
            enum = {
                0x0: '0',
                0x1: '1',
                0x3: '2',
                0x7: '3',
                0xf: '4'}))

    def _setDict(self, d, writeEach, modes, incGroups, excGroups):
        # Awful hack to ignore dict set of variables that don't exist
        # This allows KpixAsic variables to appear in config file for
        # the local kpix.
        variables = self.variables
        filtD = {k: v for k, v in d.items() if k in variables}
        super()._setDict(filtD, writeEach, modes, incGroups, excGroups)


class KpixAsic(KpixLocal):

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.enable.hidden = False
        self.calChannel = 0

        # These registers dont exist in the local kpix
        def makeDacVar(name, offset):
            # Raw KPIX regs
            for i in range(4):
                self.add(pr.RemoteVariable(
                    name = f'{name}Raw{i}',
                    offset = offset,
                    bitOffset = i*8,
                    bitSize = 8,
                    hidden = True))
            raws = [self.node(f'{name}Raw{i}') for i in range(4)]

            # Link Variable that gets set
            # Set all Raw RemoteVariables to the same value
            def ls(value, write):
                for v in raws:
                    v.set(value, write=write)

            self.add(pr.LinkVariable(
                name = name,
                mode = 'RW',
                dependencies = raws,
                linkedGet = lambda: self.node(f'{name}Raw0').value(),
                linkedSet = ls))
            link = self.node(name)

            def dacToVolt():
                dac = link.value()
                if dac >= 0xf6:
                    return 2.5 - ((0xff-dac) * 50.0 * 0.0001)
                else:
                    return dac * 100.0 * 0.0001

            # View of variable as voltage
            self.add(pr.LinkVariable(
                name = f'{name}Volt',
                mode = 'RO',
                disp = '{:0.3f}',
                dependencies = [self.node(name)],
                linkedGet = dacToVolt))

        makeDacVar(name = 'DacPreThresholdA', offset=self.DAC_0)
        makeDacVar(name = 'DacPreThresholdB', offset=self.DAC_1)
        makeDacVar(name = 'DacRampThresh', offset=self.DAC_2)
        makeDacVar(name = 'DacRangeThreshold', offset=self.DAC_3)
        makeDacVar(name = 'DacCalibration', offset=self.DAC_4)
        makeDacVar(name = 'DacEventThreshold', offset=self.DAC_5)
        makeDacVar(name = 'DacShaperBias', offset=self.DAC_6)
        makeDacVar(name = 'DacDefaultAnalog', offset=self.DAC_7)
        makeDacVar(name = 'DacThresholdA', offset=self.DAC_8)
        makeDacVar(name = 'DacThresholdB', offset=self.DAC_9)

        self.add(pr.RemoteVariable(
            name = 'CntrlDisPerReset',
            offset=self.CONTROL,
            bitOffset=0,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'CntrlEnDcReset',
            offset=self.CONTROL,
            bitOffset=1,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'CntrlHighGain',
            offset=self.CONTROL,
            bitOffset=2,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'CntrlNearNeighbor',
            offset=self.CONTROL,
            bitOffset=3,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'CntrlCalSource',
            offset=self.CONTROL,
            bitOffset=[6, 4], # I'm pretty sure this wont work
            bitSize=[1, 1],
            enum = {
                0: 'Disable',
                1: 'Internal',
                2: 'External',
                3: '-'}))

        self.add(pr.RemoteVariable(
            name = 'CntrlForceTrigSource',
            offset=self.CONTROL,
            bitOffset=[7, 5], # I'm pretty sure this wont work
            bitSize=[1, 1],
            enum = {
                0: 'Disable',
                1: 'Internal',
                2: 'External',
                3: '-'}))

        self.add(pr.RemoteVariable(
            name = 'CntrlHoldTime',
            offset=self.CONTROL,
            bitOffset=8,
            bitSize=3,
            base=pr.UIntReversed,
            enum = {
                0: '8x',
                1: '16x',
                2: '24x',
                3: '32x',
                4: '40x',
                5: '48x',
                6: '56x',
                7: '64x'}))

        self.add(pr.RemoteVariable(
            name = 'CntrlCalibHigh',
            offset=self.CONTROL,
            bitOffset=11,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'CntrlShortIntEn',
            offset=self.CONTROL,
            bitOffset=12,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'CntrlForceLowGain',
            offset=self.CONTROL,
            bitOffset=13,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'CntrlLeakNullDisable',
            offset=self.CONTROL,
            bitOffset=14,
            bitSize=1,
            base=pr.Bool))


        self.add(pr.RemoteVariable(
            name = 'CntrlPolarity',
            offset=self.CONTROL,
            bitOffset=15,
            bitSize=1,
            enum = {
                0: 'Negative',
                1: 'Positive'}))

        self.add(pr.RemoteVariable(
            name = 'CntrlTrigDisable',
            offset=self.CONTROL,
            bitOffset=16,
            bitSize=1,
            base=pr.Bool))


        self.add(pr.RemoteVariable(
            name = 'CntrlDisPwrCycle',
            offset=self.CONTROL,
            bitOffset=24,
            bitSize=1,
            base=pr.Bool))

        self.add(pr.RemoteVariable(
            name = 'CntrlFeCurr',
            offset=self.CONTROL,
            bitOffset=25,
            bitSize=3,
            base = pr.UIntReversed,
            enum = {
                0: '1uA',
                1: '31uA',
                2: '61uA',
                3: '91uA',
                4: '121uA',
                5: '151uA',
                6: '181uA',
                7: '221uA'}))


        self.add(pr.RemoteVariable(
            name = 'CntrlDiffTime',
            offset=self.CONTROL,
            bitOffset=28,
            bitSize=2,
            enum = {
                0: 'Normal',
                1: 'Half',
                2: 'Third',
                3: 'Quarter'}))

        self.add(pr.RemoteVariable(
            name = 'CntrlMonSource',
            offset=self.CONTROL,
            bitOffset=30,
            bitSize=2,
            base = pr.UIntReversed,
            enum = {
                0: 'None',
                1: 'Amp',
                2: 'Shaper',
                3: '-'}))

        for i, addr in enumerate(self.CHAN_MODE_A):
            self.add(pr.RemoteVariable(
                name = f'ChanModeA_{i}',
                offset = addr,
                mode = 'RW',
                bitOffset = 0,
                bitSize = 32,
                hidden = True))

        for i, addr in enumerate(self.CHAN_MODE_B):
            self.add(pr.RemoteVariable(
                name = f'ChanModeB_{i}',
                offset = addr,
                mode = 'RW',
                bitOffset = 0,
                bitSize = 32,
                hidden = True))

        d = {(0,0): 'B',
             (0,1): 'D',
             (1,0): 'A',
             (1,1): 'C'}
        drev = {v:k for k,v in d.items()}

        def getChanMode(dev, var):
            li = []
            a = var.dependencies[0].value()
            b = var.dependencies[1].value()
            for row in range(32):
                val = ((((b >> (row)) & 1) ), ((a >> (row)) & 1))
                li.append(d[val])
            s =  ' '.join([''.join(x for x in li[i:i+8]) for i in range(0, 32, 8)])
            #print(f'getChanMode = {s}')
            return s

        def setChanMode(dev, var, value, write):
            value = ''.join(value.split()) # remove whitespace
            regA = 0
            regB = 0
            for row in range(32):
                b,a = drev[value[row]]
                regA |= a << (row)
                regB |= b << (row)

            #print(f'setChanMode(value={value}) - regA={regA:x}, regB = {regB:x}')

            var.dependencies[0].set(value = regA, write=write)
            var.dependencies[1].set(value = regB, write=write)

        colModes = []
        for col in range(32):
            colModes.append(pr.LinkVariable(
                name = f'Chan_{col*32:d}_{col*32+31:d}',
                mode = 'RW',
                dependencies = [self.node(f'ChanModeA_{col}'), self.node(f'ChanModeB_{col}')],
                linkedGet = getChanMode,
                linkedSet = setChanMode))
        self.add(colModes)


    def setCalibrationMode(self):
        self.CntrlCalSource.setDisp("Internal", write=True)
        self.CntrlForceTrigSource.setDisp("Internal", write=True)
        self.CntrlTrigDisable.set(True, write=True)

    def setCalibration(self, channel, dac):
        row = channel%32
        col = channel//32

        self.DacCalibration.set(dac, write=False)

        # Turn off last cal channel
        oldCol = self.calChannel//32
        modestring = ['D' for x in range(32)]
        self.node(f'Chan_{oldCol*32:d}_{oldCol*32+31:d}').setDisp(''.join(modestring), write=False)

        # Turn on new cal channel
        modestring[row] = 'C'
        self.node(f'Chan_{col*32:d}_{col*32+31:d}').setDisp(''.join(modestring), write=False)
        self.calChannel = channel
        self.writeBlocks()
        self.verifyBlocks()
        self.checkBlocks()




# Manipulate entire array together
# class KpixArray(pr.Device):
#     def __init__(self, array, **kwargs):
#         super().__init__(**kwargs)

#         for v in array[0].variables if v.name != 'enable':
#             allVars = [d.node(v.name) for d in array if d.node(v.name) is not None]

#             def ls(value, write):
#                 for x in allVars:
#                     v.set(value=value, write=write)

#             self.add(pr.LinkVariable(
#                 name = v.name,
#                 dependencies = allVars,
#                 linkedGet = v.value,
#                 linkedSet = ls))
