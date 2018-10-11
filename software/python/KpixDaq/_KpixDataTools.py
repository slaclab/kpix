import sys
import rogue
import pyrogue
import numpy as np
from collections import defaultdict

nesteddict = lambda:defaultdict(nesteddict)

def toInt(ba):
    return int.from_bytes(ba, 'little')

def getField(value, highBit, lowBit):
    mask = 2**(highBit-lowBit+1)-1
    return (value >> lowBit) & mask

def parseSample(ba):
    baSwapped = bytearray([ba[4], ba[5], ba[6], ba[7], ba[0], ba[1], ba[2], ba[3]])
    value = int.from_bytes(baSwapped, 'little', signed=False)

    d = {}
        
    d['adc'] = getField(value, 12, 0)
    d['timestamp'] = getField(value, 28, 16)
    d['row'] = getField(value, 36, 32)
    d['col'] = getField(value, 41, 37)
    d['bucket'] = getField(value, 43, 42)
    d['triggerFlag'] = getField(value, 44, 44)
    d['rangeFlag'] = getField(value, 45, 45)
    d['badCountFlag'] = getField(value, 46, 46)
    d['emptyFlag'] = getField(value, 47, 47)
    d['kpixId'] = getField(value, 59, 48)
    d['typeField'] = getField(value, 63, 60)
    #print(d)
    if d['typeField'] == 0:
        return d
    else:
        return None


def parseFrame(ba):
    frameSizeBytes = len(ba)
    numSamples = int((frameSizeBytes-32-4)/8)

    timestamp = int.from_bytes(ba[4:12], 'little')
    eventNumber = int.from_bytes(ba[0:4], 'little')

    d = {}
    d['runtime'] = timestamp
    d['eventNumber'] = eventNumber

    print(f'Parsing frame {eventNumber}, timestamp: {timestamp}, {numSamples} samples')

    d['data'] = []

    for i in range(numSamples):
        a = parseSample(ba[32+(i*8):32+(i*8)+8])
        if a is not None:
            d['data'].append(a)

    return d
    

        
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

    def _acceptFrame(self, frame):
        if frame.getError():
            print('Frame Error!')
            return

        ba = bytearray(frame.getPayload())
        frame.read(ba, 0)


        
        if frame.getChannel() == 0:
            runControlDict = self.state["DesyTrackerRoot"]["DesyTrackerRunControl"]            
            calState = runControlDict['CalState']
            calChannel = runControlDict['CalChannel']
            calDac = runControlDict['CalDac']
            
            parsedFrame = parseFrame(ba)
            runtime = parsedFrame['runtime']
            for sample in parsedFrame['data']:
                kpix = sample['kpixId']
                channel = sample['col']*32+sample['row']
                bucket = sample['bucket']
                adc = sample['adc']

            
                if calState == 'Baseline':
                    self.dataDict[kpix][channel][bucket]['baseline']['data'][runtime] = adc                

                elif calState == 'Injection':
                    if channel == calChannel:
                        self.dataDict[kpix][channel][bucket]['injection'][calDac][runtime] = adc
                    else:
                        raise Exception(f"Got data for channel {channel} while calibrating channel {self.CalChannel}")
                    
        else:
            print("Got YAML Frame")
            yamlString = ba.rstrip(bytearray(1)).decode('utf-8')
#            yamlString = yamlString.replace(':', ': ')
#            lines = yamlString.splitlines(3)
#            lines = [l for l in lines if l.count(':') == 1]
#            yamlString = ''.join(lines)
            #print(yamlString)
            yamlDict = pyrogue.yamlToDict(yamlString)
#            if yamlDict is None: return

            dictUpdate(self.d, yamlDict)

#            calVars = ['CalState', 'CalChannel', 'CalDac']
#            for key,value in yamlDict.items():
#                for var in calVars:
#                    if var in key and 'SystemLog' not in key:
#                        self.__setattr__(var, value)


def dictUpdate(old, new):
    if 'KeyValues' in new:
        # Process flattened key value pairs
        for k,v in new.items():
            d = old
            parts =  k.split('.')
            for part in parts[:-1]:
                d = d[part]
            d[parts[-1]] = v
    else:
        old.update(new)
            
            
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
