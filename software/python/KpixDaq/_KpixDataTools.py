import sys
import rogue
import pyrogue
import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
from collections import defaultdict
import ctypes



nesteddict = lambda:defaultdict(nesteddict)

c_uint = ctypes.c_uint

class KpixSampleRaw(ctypes.LittleEndianStructure):
    _fields_ = [                          
        ('row', c_uint, 5), #4:0
        ('col', c_uint, 5), #9:5  
        ('bucket', c_uint, 2), #11:10
        ('triggerFlag', c_uint, 1), #12
        ('rangeFlag', c_uint, 1), #13
        ('badCountFlag', c_uint, 1), #14
        ('emptyFlag', c_uint, 1), #15
        ('kpixId', c_uint, 12), #27:16
        ('type', c_uint, 4), #31:28
        ('adc', c_uint, 13), #44:32
        ('dmy2', c_uint, 3), #47:45
        ('timestamp', c_uint, 13), #60:48
    ]
         
    _pack_ = 1

class KpixSample(ctypes.Union):
    _anonymous_ = ('fields',)
    _fields_ = [
        ('fields', KpixSampleRaw),
        ('asWord', ctypes.c_uint64),]

    def __init__(self, word):
        self.asWord = word
    

def toInt(ba):
    return int.from_bytes(ba, 'little')

def getField(value, highBit, lowBit):
    mask = 2**(highBit-lowBit+1)-1
    return (value >> lowBit) & mask


def parseSample(ba):
    #baSwapped = np.array([ba[4], ba[5], ba[6], ba[7], ba[0], ba[1], ba[2], ba[3]])
    value = int.from_bytes(ba, 'little', signed=False)

    d = {}
    if getField(value, 63, 60) != 0:
        return None
        
    d['adc'] = getField(value, 44, 32)
    d['timestamp'] = getField(value, 60, 48)
    d['row'] = getField(value, 4, 0)
    d['col'] = getField(value, 9, 5)
    d['bucket'] = getField(value, 11, 10)
    #d['triggerFlag'] = getField(value, 12, 12)
    #d['rangeFlag'] = getField(value, 13, 13)
    #d['badCountFlag'] = getField(value, 14, 14)
    #d['emptyFlag'] = getField(value, 15, 15)
    d['kpixId'] = getField(value, 27, 16)
    return d



def parseFrame(ba):
    frameSizeBytes = len(ba)
    numSamples = int((frameSizeBytes-32-4)/8)

    timestamp = int.from_bytes(ba[4:12], 'little')
    eventNumber = int.from_bytes(ba[0:4], 'little')

    d = {}
    d['runtime'] = timestamp
    d['eventNumber'] = eventNumber

    #print(f'Parsing frame {eventNumber}, timestamp: {timestamp}, {numSamples} samples')
    rawSamples = ba[32:-4]

#(rawSamples[i:i+8] for i in range(0, len(rawSamples), 8))
    d['data'] = rawSamples#(KpixSample(rawSamples[i:i+8].ctypes.data_as(ctypes.POINTER(ctypes.c_uint64)).contents.value)
                # for i in range(0, len(rawSamples), 8))



#     for i in range(numSamples):
#         a = parseSample(ba[32+(i*8):32+(i*8)+8])
#         if a is not None:
#             d['data'].append(a)

    return d
    
class KpixStreamInfo(rogue.interfaces.stream.Slave):
    def __init__(self):
        rogue.interfaces.stream.Slave.__init__(self)

    def _acceptFrame(self, frame):
       if frame.getError():
            print('Frame Error!')
            return

       ba = bytearray(frame.getPayload())
       frame.read(ba, 0)        
       parseFrame(ba)
        
class KpixRunAnalyzer(rogue.interfaces.stream.Slave):
    def __init__(self):
        rogue.interfaces.stream.Slave.__init__(self)

        self.parsedData = []
        
    def _acceptFrame(self, frame):

        if frame.getError():
            print('Frame Error!')
            return

        ba = bytearray(frame.getPayload())
        frame.read(ba, 0)        
        if frame.getChannel() == 0:
            self.parsedData.append(parseFrame(ba))
        else:
            print(f'Got YAML Frame')


    def process(self):
        
        #data = [[[[] for bucket in range(4)] for chanel in range(1024)] for kpix in range(24)]
        self.dictData = nesteddict()

        for frame in self.parsedData:
            runtime = frame['runtime']
            for sample in frame['data']:
                print(sample)
                kpix = sample['kpixId']
                channel = sample['col']*32+sample['row']
                bucket = sample['bucket']
                adc = sample['adc']
                
                self.dictData[kpix][channel][bucket][runtime] = adc

    def noise(self):
        for kpix, channels in self.dictData.items():
            for channel, buckets in channels.items():
                for bucket, adcs in buckets.items():
                    a = np.array(list(adcs.values()))
                    buckets[bucket]['mean'] = np.mean(a)
                    buckets[bucket]['noise'] = np.std(a)


class KpixCalibration(rogue.interfaces.stream.Slave):
    def __init__(self):
        rogue.interfaces.stream.Slave.__init__(self)

        #self.CalState = 'Idle'
        #self.CalChannel = 0
        #self.CalDac = 0

        self.state = nesteddict()

        self.dataDict = nesteddict()

        self.injections = {}
        self.baselines = {}
        self.counts = {}
        self.frameCount = 0
        self.sampleCount = 0

    def _acceptFrame(self, frame):
        if frame.getError():
            print('Frame Error!')
            return

        #if self.state["DesyTrackerRoot"]["DesyTrackerRunControl"]['CalState'] == "Inject":
        #    return

        ba = np.zeros(frame.getPayload(), dtype=np.uint8)
        frame.read(ba, 0)

        

        active = set([0,6])
        done = []
        
        if frame.getChannel() == 0:
            runControlDict = self.state["DesyTrackerRoot"]["DesyTrackerRunControl"]            
            calState = runControlDict['CalState']
            calChannel = runControlDict['CalChannel']
            calDac = runControlDict['CalDac']

            #numDacs = (runControlDict['CalDacMax']-runControlDict['CalDacMin'])/runControlDict['CalDacStep']
            #dacCount = runControlDict['CalDacCount']

            parsedFrame = parseFrame(ba)
            runtime = parsedFrame['runtime']

            self.frameCount += 1
            sample = KpixSample(0)
            #(rawSamples[i:i+8] for i in range(0, len(rawSamples), 8))
            data = parsedFrame['data']
            size = len(data)
            dv = data.view()
            dv.shape = (8, size//8)

            #print(data)
            #print(dv)
            #return
            
            for i in range(0, len(data), 8):
                ba = data[i:i+8]
                #word = ba.ctypes.data_as(ctypes.POINTER(ctypes.c_uint64)).contents.value
                self.sampleCount += 1
                sample.asWord = int.from_bytes(ba, 'little', signed=False)
                #print(f'Kpix: {sample.fields.kpixId}, row: {sample.fields.row}, col: {sample.fields.col}, bucket: {sample.fields.bucket}')
                if sample.fields.type != 0:
                    continue # Temperature type
                
            
                fields = sample.fields
                channel = fields.col*32 + fields.row
                kpix = fields.kpixId
                bucket = fields.bucket
                adc = fields.adc

                if calState == 'Baseline':
                    if kpix not in self.baselines:
                        self.baselines[kpix] = np.zeros([1024, 4, 100], dtype=np.uint16)
                        self.counts[kpix] = np.zeros([1024,4], dtype=np.uint8)
                        #self.dataDict[fields.kpixId][channel][fields.bucket]['baseline']['data'][runtime] = fields.adc
                    count = self.counts[kpix][channel][bucket]
                    #print(f'Kpix: {kpix}, channel: {channel}, bucket: {bucket}, count: {count}, type: {sample.fields.type}')
                    self.baselines[kpix][channel][bucket][count] = adc
                    self.counts[kpix][channel][bucket] = count + 1

                elif calState == 'Inject':
                    if kpix not in self.injections:
                        self.injections[kpix] = np.zeros([1024, 4, 256, 10], dtype=np.uint16)
                        self.counts[kpix] = np.zeros([1024, 4, 256], dtype=np.uint8)

                    if channel == calChannel:
                        count = self.counts[kpix][channel][bucket][calDac]
                        #print(f'Kpix: {kpix}, channel: {channel}, bucket: {bucket}, dac: {calDac}, count: {count}, type: {sample.fields.type}')                        
                        self.injections[kpix][channel][bucket][calDac][count] = adc
                        self.counts[kpix][channel][bucket][calDac] = count + 1

                        #self.dataDict[fields.kpixId][channel][fields.bucket]['injection'][calDac][runtime] = fields.adc
                    
        else:
            #print("Got YAML Frame")
            yamlString = bytearray(ba).rstrip(bytearray(1)).decode('utf-8')
            yamlDict = pyrogue.yamlToDict(yamlString)
            pyrogue.dictUpdate(self.state, yamlDict)

    def baselines(self):
        ret = []
        for kpix, channels in self.dataDict.items():
            for channel, buckets in channels.items():
                for bucket, b in buckets.items():
                    a = np.array(list(b['baseline']['data'].values()))
                    mean = np.mean(a)
                    std = np.std(a)
                    b['baseline']['mean'] = mean
                    b['baseline']['std'] = std
                    ret.append([kpix, channel, bucket, mean, std])
                    print(f"Channel {channel}, bucket {bucket}: mean = {mean}, std = {std}")
                    
        return ret

    def plot_baseline_heatmap(self, kpix, bucket, noise=[0.0, 1000000], maxhits=20):
        d = {}
        # Filter out bad channels
        for channel in range(1024):
            adcs = np.array(list(self.dataDict[kpix][channel][bucket]['baseline']['data'].values()))
            std = np.std(adcs)
            if noise[0] < std < noise[1]:
                d[channel] = adcs


        # Just make it a list for now
        d = [x for x in d.values()]



        ymin = np.min(d)
        ymax = np.max(d)
        print(f'minAdc={ymin}, maxAdc={ymax}')
        
        bins = list(range(ymin, ymax+1))

        # Create a histogram for each channel
        h2d = [np.histogram(x, bins=bins)[0] for x in d]
        h2d = [x for x in h2d if max(x) < maxhits]
        h2d = np.array(h2d)

        print(f'Total channels: {len(h2d)}')        

        zmax = np.max(h2d)
        zmin = np.min(h2d)

        print(f'minHits={zmin}, maxHits={zmax}')

        fig, ax = plt.subplots()

        img = ax.imshow(h2d.T, vmin=zmin, vmax=zmax, extent=[0, len(h2d), ymin, ymax], aspect='auto')

        fig.colorbar(img)
        plt.show()

    def plot_injection_fit(self, kpix, channel):
        plt.figure(1)
        plt.xlabel('DAC')
        plt.ylabel('ADC')
        plt.title(f'Calibration fits for channel {channel}')

        for bucket in range(4):
            plt.subplot(4, 1, bucket+1)
            plt.title(f'Bucket {bucket}')
            
            d = self.dataDict[kpix][channel][bucket]['injection']
            dacs = np.array(list(d.keys()))
            adcs = np.array([list(v.values()) for v in d.values()])
            x = np.repeat(dacs, len(adcs[0]))
            y = adcs.flatten()

            regression = stats.linregress(x,y)
            m, b, r, p, err = regression

            plt.plot(x, y, 'o', label='samples')
            plt.plot(x, m*x+b, '--r', label='fit')
            plt.text(np.min(x)+10, np.max(y)-100, f'm={m}, b={b}, r={r}, p={p}, err={err}')

            
        plt.legend()
        plt.show()
        
#        print('-------')        
#         if typeField == 0:
#             print('Parsed Data Sample:')
#             print(f'KPIX: {kpixId}')
#             print(f'Timestamp: {timestamp}')
#             print(f'Row: {row}')
#             print(f'Col: {col}')
#             print(f'ADC: {adc:04x}')
#             print(f'Bucket: {bucket}')
#             print(f'TriggerFlag: {triggerFlag}')
#             print(f'RangeFlag: {rangeFlag}')
#             print(f'BadCountFlag: {badCountFlag}')
#             print(f'Emptyflag: {emptyFlag}')
#         elif typeField == 1:
#             print('Parsed Temperature Sample')
#             print(f'KPIX: {kpixId}')            
#             print(f'Temperature: {getField(value, 7, 0)}')
#             print(f'TempCount: {getField(value, 31, 24)}')
#         else:
#             print(f'Unknown type field: {typeField}')
            
#         print('-------')                        
