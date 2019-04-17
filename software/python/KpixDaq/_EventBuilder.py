import pyrogue as pr

class EventBuilder(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(pr.RemoteVariable(
            name = 'EventNumber',
            mode = 'RO',
            offset= 0x00,
            bitOffset=0,
            bitSize=32,
            disp = '{:d}'))

        self.add(pr.RemoteVariable(
            name = 'DataDone',
            mode = 'RO',
            offset= 0x08,
            bitOffset=0,
            bitSize=32))

        self.add(pr.RemoteVariable(
            name = 'State',
            mode = 'RO',
            offset = 0x04,
            bitOffset = 0,
            bitSize = 3,
            enum = {
                0b000: "WAIT_ACQUIRE_S",
                0b001: "WRITE_HEADER_S",
                0b010: "WAIT_DIGITIZE_S",
                0b011: "READ_TIMESTAMPS_S", 
                0b100: "WAIT_READOUT_S",
                0b101: "GATHER_DATA_S",
                0b111: "INVALID"}));
        
        
