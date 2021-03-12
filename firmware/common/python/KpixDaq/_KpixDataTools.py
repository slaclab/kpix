import rogue
import pyrogue
import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
from collections import defaultdict
from collections import Counter
import ctypes
#import line_profiler

import pprint

pp = pprint.PrettyPrinter(indent=2)

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


def parseSample(ba, timestamp):
    #baSwapped = np.array([ba[4], ba[5], ba[6], ba[7], ba[0], ba[1], ba[2], ba[3]])
    value = int.from_bytes(ba, 'little', signed=False)

    d = {}

    d['type'] = getField(value, 31, 28)
    d['kpixId'] = getField(value, 27, 16)

    if d['type'] == 3:
        d['firstRuntime'] = getField(value, 63, 32)
    elif d['type'] == 1:
        d['temperature'] = getField(value, 39, 32)
        d['count'] = getField(value, 63, 56)
    elif d['type'] == 2:
        d['runtime'] = getField(value, 63, 32)
        d['bunchCount'] = getField(value, 15, 3)
        d['subCount'] = getField(value, 2, 0)
        d['jitter'] = ((d['runtime']-timestamp)*5) - ((3000+d['bunchCount']*8+d['subCount'])*320)
    else:
        d['row'] = getField(value, 4, 0)
        d['col'] = getField(value, 9, 5)
        d['bucket'] = getField(value, 11, 10)
        d['triggerFlag'] = getField(value, 12, 12)
        d['rangeFlag'] = getField(value, 13, 13)
        d['badCountFlag'] = getField(value, 14, 14)
        d['emptyFlag'] = getField(value, 15, 15)
        d['adc'] = getField(value, 44, 32)
        d['timestamp'] = getField(value, 60, 48)
    return d


#@profile
def parseFrame(ba):
    frameSizeBytes = len(ba)
    numSamples = int((frameSizeBytes-32-4)/8)

    timestamp = int.from_bytes(ba[4:12], 'little')
    eventNumber = int.from_bytes(ba[0:4], 'little')

    d = {}
    d['runtime'] = timestamp
    d['eventNumber'] = eventNumber
    d['samples'] = nesteddict()

    kpixCounter = Counter()

    print(f'Parsing frame {eventNumber}, timestamp: {timestamp}, {numSamples} samples')
    rawSamples = ba[32:-4]

    data = (rawSamples[i:i+8] for i in range(0, len(rawSamples), 8))
    runtimes = []
    timestampCount = 0

    for raw in data:
        sample = parseSample(raw, timestamp)

        if sample['type'] == 2:
            print(sample)
            timestampCount += 1

        if sample['type'] == 3:
            print(f"Found runtime sample: {sample['kpixId']} {sample['firstRuntime']:#08x} diff: {sample['firstRuntime']-(timestamp&0xFFFFFFFF)}")

        if sample['type'] == 0:
            kpixCounter[sample['kpixId']] += 1

    print(f'Got {timestampCount} timestamps')
    print(kpixCounter)
    return d

#        if sample['kpixId'] == 24:
#            print(f'Found local kpix sample: {sample}')

#        elif sample['type'] == 3:
            #print(f"Found runtime sample: {sample['kpixId']} {sample['firstRuntime']:#08x} diff: {sample['firstRuntime']-(timestamp&0xFFFFFFFF)}")
#            if sample['kpixId'] != 24:
#                runtimes.append(sample)
#        else:
#            pass
            #d['samples'][sample['kpixId']][sample['bucket']][sample['row']][sample['col']] = sample['adc']
            #print(f'Normal sample: {sample}')

    #print(f'All Runtimes: {runtimes}')
    s = set((x['firstRuntime']-d['runtime'] for x in runtimes))
    #print(f'Runtimes: {s}')
    if len(s) != 1:
        print('-----')
        print("Runtimes do not match!")
        for r in runtimes:
            print(r)
        print('-----')

    return d

class KpixStreamInfo(rogue.interfaces.stream.Slave):
    def __init__(self, ):
        rogue.interfaces.stream.Slave.__init__(self)

    def _acceptFrame(self, frame):
        if frame.getError():
            print('Frame Error!')
            return

        ba = bytearray(frame.getPayload())
        frame.read(ba, 0)
        print(f'Got Frame on channel {frame.getChannel()}: {len(ba)} bytes')
        if frame.getChannel() == 0:
            d = parseFrame(ba)
            print(d)


#        for k, kpix in d['samples'].items():
#            print(k)
#            if k == 24: continue
#            print(f'Kpix: {k}')
#            for b, bucket in kpix.items():
#                print(f'Bucket: {b}')
#                for r, row in bucket.items():
#                    l = []
#                    for c in range(32):
#                        if c not in row:
#                            l.append('     ')
#                        else:
#                            l.append(f'{row[c]:04x} ')
#                    print(''.join(l))




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
            print('Got YAML Frame')


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

        self.state = {}

        self.dataDict = nesteddict()

        #self.runtimes = nesteddict()

        #self.injections = {}
        #self.baselines = {}
        #self.counts = {}
        self.frameCount = 0
        #self.sampleCount = 0

    #@profile
    def _acceptFrame(self, frame):
        if frame.getError():
            print('Frame Error!')
            #return

        #if self.state["DesyTrackerRoot"]["DesyTrackerRunControl"]['CalState'] == "Inject":
        #    return

        ba = np.zeros(frame.getPayload(), dtype=np.uint8)
        frame.read(ba, 0)

#        active = set([0,6])
#        done = []

        if frame.getChannel() == 0:

            runControlDict = self.state["DesyTrackerRoot"]["DesyTrackerRunControl"]
            calState = runControlDict['CalState']
            calChannel = runControlDict['CalChannel']
            calDac = runControlDict['CalDac']
            #calMeanCount = runControlDict['CalMeanCount']
            #calDacCount = runControlDict['CalDacCount']

            #numDacs = (runControlDict['CalDacMax']-runControlDict['CalDacMin'])/runControlDict['CalDacStep']
            #dacCount = runControlDict['CalDacCount']

            #parsedFrame = parseFrame(ba)


            self.frameCount += 1
            sample = KpixSample(0)
            #(rawSamples[i:i+8] for i in range(0, len(rawSamples), 8))
            data = ba[32:-4]
            #size = len(data)
            dv = data.view()
            dv.shape = (len(data)//8, 8)

            runtime = int.from_bytes(ba[4:12], 'little')
            print(f'Got Data Frame. Runtime: {runtime}')
            #print(f'CalState: {calState.__dict__}')

            for seg in dv:
                #word =
                #self.sampleCount += 1
                #sample.asWord = int.from_bytes(seg, 'little', signed=False)
                sample.asWord = seg.ctypes.data_as(ctypes.POINTER(ctypes.c_uint64)).contents.value
                #print(f'Kpix: {sample.fields.kpixId}, row: {sample.fields.row}, col: {sample.fields.col}, bucket: {sample.fields.bucket}')
                if sample.fields.type != 0:
                    continue # Temperature type


                fields = sample.fields
                channel = fields.col*32 + fields.row
                kpix = fields.kpixId
                bucket = fields.bucket
                adc = fields.adc

                #print(f'Got sample: kpix: {kpix}, channel {channel}, bucket: {bucket}, adc: {adc}')

                if calState == 'Baseline':
                    pass
                    #if kpix not in self.baselines:
                        #self.baselines[kpix] = np.zeros([1024, 4, calMeanCount], dtype=np.uint16)
                        #self.counts[kpix] = np.zeros([1024,4], dtype=np.uint8)

                    # dict cheat

                    # This works
                    #self.dataDict[kpix][channel][bucket]['baseline']['data'][runtime] = adc

                    #count = self.counts[kpix][channel, bucket]
                    #print(f'Kpix: {kpix}, channel: {channel}, bucket: {bucket}, type: {sample.fields.type}, adc: {adc}')
                    #self.baselines[kpix][channel, bucket, count] = adc
                    #self.counts[kpix][channel, bucket] = count + 1

                elif calState == 'Inject':
                    #if kpix not in self.injections:
                    #    self.injections[kpix] = np.zeros([1024, 4, 256, calDacCount], dtype=np.uint16)
                    #   self.counts[kpix] = np.zeros([1024, 4, 256], dtype=np.uint8)

                    if channel == calChannel:
                        #count = self.counts[kpix][channel, bucket, calDac]
                        #print(f'Kpix: {kpix}, channel: {channel}, bucket: {bucket}, dac: {calDac}, count: {count}, type: {sample.fields.type}')
                        #self.injections[kpix][channel, bucket, calDac, count] = adc
                        #self.counts[kpix][channel, bucket, calDac] = count + 1
                        if len(self.dataDict[kpix][channel][bucket]['injection'][calDac]) > 0:
                            print(f"Current: {self.dataDict[kpix][channel][bucket]['injection'][calDac]}")
                            print(f'New sample: kpix: {kpix}, channel {channel}, bucket: {bucket}, adc: {adc}')

                        self.dataDict[kpix][channel][bucket]['injection'][calDac][runtime] = adc

        elif frame.getChannel() == 6:
            print("Got YAML Frame")
            yamlString = bytearray(ba).rstrip(bytearray(1)).decode('utf-8')
            yamlDict = pyrogue.yamlToData(yamlString)
            #print(yamlDict)
            pyrogue.dictUpdate(self.state, yamlDict)
        else:
            print(f'Got frame from channel: {frame.getChannel()}')
#            print(

    def baselines(self):
        ret = nesteddict()
        for kpix, channels in self.dataDict.items():
            for channel, buckets in channels.items():
                for bucket, b in buckets.items():
                    a = np.array(list(b['baseline']['data'].values()))
                    mean = np.mean(a)
                    std = np.std(a)
                    b['baseline']['mean'] = mean
                    b['baseline']['std'] = std
                    ret[kpix][channel][bucket] = (mean, std)
                    print(f"Channel {channel}, bucket {bucket}: mean = {mean}, std = {std}")

        return ret

    def plot_baseline_heatmaps(self, kpix):

        fig = plt.figure(1)
        plt.xlabel('Channel')
        plt.ylabel('ADC')
        plt.title('Baseline historam all channels')

        for bucket in range(4):

            d = self.baselines[kpix][:, bucket]
            ymin = np.min(d)
            ymax = np.max(d)
            print(f'minAdc={ymin}, maxAdc={ymax}')

            bins = list(range(ymin, ymax+1))

            # Create a histogram for each channel
            h2d = np.array([np.histogram(x, bins=bins)[0] for x in d])

            zmax = np.max(h2d)
            zmin = np.min(h2d)

            print(f'minHits={zmin}, maxHits={zmax}')

            ax = fig.add_subplot(4, 1, bucket+1)
            #plt.title(f'Bucket {bucket}')

            img = ax.imshow(h2d.T, vmin=zmin, vmax=zmax, extent=[0, len(h2d), ymin, ymax], aspect='auto')
            fig.colorbar(img)

        plt.show()

    def plot_baseline_heatmaps_dict(self, kpix):

        fig = plt.figure()
        fig.suptitle('Baseline historam all channels')

        for bucket in range(4):

            keys = self.dataDict[kpix].keys()
            d = [list(self.dataDict[kpix][channel][bucket]['baseline']['data'].values()) for channel in keys]

            d = np.array(d)
            ymin = np.min(d)
            ymax = np.max(d)

            bins = list(range(ymin, ymax+1))

            # Create a histogram for each channel
            h2d = np.array([np.histogram(x, bins=bins)[0] for x in d])

            zmax = np.max(h2d)
            zmin = np.min(h2d)

            print(f'minHits={zmin}, maxHits={zmax}')

            ax = fig.add_subplot(4, 1, bucket+1)
            ax.set_title(f'Bucket {bucket}')
            ax.set_xlabel('Channel')
            ax.set_ylabel('ADC')

            img = ax.imshow(h2d.T, vmin=zmin, vmax=zmax, extent=[0, len(h2d), ymin, ymax], aspect='auto')
            plt.colorbar(img, ax=ax)


        plt.show()


    def plot_injection_fit(self, kpix, channel):
        plt.figure(1)
        plt.xlabel('DAC')
        plt.ylabel('ADC')
        plt.title(f'Calibration fits for channel {channel}')

        for bucket in range(4):
            plt.subplot(4, 1, bucket+1)
            plt.title(f'Bucket {bucket}')

            d = self.injections[kpix][channel, bucket, 200:]
            dacs = np.array(list(range(200,256)))
            adcs = d
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
