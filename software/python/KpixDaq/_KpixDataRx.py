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

        self.add(pr.RemoteVariable(
            name = 'FirstRuntime',
            mode = 'RO',
            offset = 0x20,
            bitOffset = 0,
            bitSize = 32))

        self.add(pr.RemoteVariable(
            name = 'RxState',
            mode = 'RO',
            offset = 0x24,
            bitOffset = 0,
            bitSize = 3,
            enum = {
                0b000: "RX_IDLE_S",
                0b001: "RX_HEADER_S",
                0b010: "RX_ROW_ID_S",
                0b011: "RX_DATA_S", 
                0b100: "RX_FRAME_DONE_S",
                0b101: "RX_DUMP_S",
                0b110: "RX_RESP_S",
                0b111: "INVALID"}));

        self.add(pr.RemoteVariable(
            name = 'TxState',
            mode = 'RO',
            offset = 0x24,
            bitOffset = 8,
            bitSize = 4,
            enum = {
                0b0000: "TX_CLEAR_S",
                0b0001: "TX_IDLE_S",
                0b0010: "TX_ROW_ID_S",
                0b0011: "TX_NXT_COL_S", 
                0b0100: "TX_CNT_S",
                0b0101: "TX_TIMESTAMP_S",
                0b0110: "TX_ADC_DATA_S",
                0b0111: "TX_SEND_SAMPLE_S",
                0b1000: "TX_WAIT_S",
                0b1001: "TX_TEMP_S",
                0b1010: "TX_RUNTIME_S",
                0b1111: "INVALID" }));
        
        

        self.add(pr.RemoteCommand(
            name = "ResetCounters",
            offset = 0x10,
            bitOffset = 0,
            bitSize = 1,
            function = pr.RemoteCommand.touchOne))

    def countReset(self):
        self.ResetCounters()
        
        
