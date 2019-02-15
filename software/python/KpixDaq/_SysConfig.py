import pyrogue as pr
import re

class SysConfig(pr.Device):

    def KpixEnableUpdate(self, path, value, disp):
        index = int(re.search('.*?KpixAsic\\[(.*?)\\]', path).groups()[0])
        self.KpixEnable[index].set(value, write=True)
    
    def __init__(self, numKpix, **kwargs):
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

        for i in range(numKpix):
            self.add(pr.RemoteVariable(
                name = f'KpixEnable[{i}]',
                mode = 'RW',
                offset= 0x08,
                bitOffset=i,
                bitSize=1,
                base=pr.Bool,
                hidden=True))


        debugEnum = {
            0b00000: 'reg_clk',
            0b00001: 'reg_sel1',
            0b00010: 'reg_sel0',
            0b00011: 'pwr_up_acq',
            0b00100: 'reset_load',
            0b00101: 'leakage_null',
            0b00110: 'offset_null',
            0b00111: 'thresh_off',
            0b01000: 'v8_trig_inh',
            0b01001: 'cal_strobe',
            0b01010: 'pwr_up_acq_dig',
            0b01011: 'sel_cell',
            0b01100: 'desel_all_cells',
            0b01101: 'ramp_period',
            0b01110: 'precharge_bus',
            0b01111: 'reg_data',
            0b10000: 'reg_wr_ena',
            0b10001: 'kpixClk'}


        self.add(pr.RemoteVariable(
            name = 'DebugA',
            mode = 'RW',
            offset = 0x0C,
            bitOffset = 0,
            bitSize = 5,
            base = pr.UInt,
            enum = debugEnum))

        self.add(pr.RemoteVariable(
            name = 'DebugB',
            mode = 'RW',
            offset = 0x0C,
            bitOffset = 5,
            bitSize = 5,
            base = pr.UInt,
            enum = debugEnum))
        
                

        self.add(pr.RemoteCommand(
            name = 'KpixReset',
            offset = 0x00,
            bitOffset = 0,
            bitSize = 1,
            function = pr.RemoteCommand.touchOne))
        
        
        
    def hardReset(self):
        print('Sending hard reset to KPIX ASIC array')
        self.KpixReset()
