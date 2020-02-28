import threading
import time
import click

import pyrogue

class DesyTrackerRunControl(pyrogue.RunControl):
    def __init__(self, **kwargs):
        rates = {1:'1 Hz', 0:'Auto'}
        states = {0: 'Stopped', 1: 'Running', 2: 'Calibration'}
        pyrogue.RunControl.__init__(self, rates=rates, states=states, **kwargs)

        # These specify the parameters of a run
        self.add(pyrogue.LocalVariable(
            name = 'CalMeanCount',
            description = 'Set number of iterations for mean fitting',
            value = 100))

        self.add(pyrogue.LocalVariable(
            name = 'CalDacMin',
            description = 'Min DAC value for calibration',
            value = 0))

        self.add(pyrogue.LocalVariable(
            name = 'CalDacMax',
            description = 'Max DAC value for calibration',
            value = 255))

        self.add(pyrogue.LocalVariable(
            name = 'CalDacStep',
            description = "DAC increment value for calibration",
            value = 1))

        self.add(pyrogue.LocalVariable(
            name = 'CalDacCount',
            description = "Number of iterations to take at each dac value",
            value = 1))

        self.add(pyrogue.LocalVariable(
            name = 'CalChanMin',
            description = 'Starting calibration channel',
            value = 0))

        self.add(pyrogue.LocalVariable(
            name = 'CalChanMax',
            description = 'Last calibration channel',
            value = 1023))

        # These are updated during the run
        self.add(pyrogue.LocalVariable(
            name = 'CalState',
            disp = ['Idle', 'Baseline', 'Inject'],
            value = 'Idle'))

        self.add(pyrogue.LocalVariable(
            name = 'CalChannel',
            value = 0))

        self.add(pyrogue.LocalVariable(
            name = 'CalDac',
            value = 0))

        self.add(pyrogue.LocalVariable(
            name = 'TimeoutWait',
            value = .2,
            units = 'Seconds'))

        self.add(pyrogue.LocalVariable(
            name = 'MaxRunCount',
            value = 2**31-1))

    @pyrogue.expose
    def waitStopped(self):
        self._thread.join()

    def _setRunState(self,value,changed):
        """
        Set run state. Reimplement in sub-class.
        Enum of run states can also be overriden.
        Underlying run control must update runCount variable.
        """
        if changed:
            # First stop old threads to avoid overlapping runs
            # but not if we are calling from the running thread
            if self._thread is not None and self._thread != threading.current_thread():
                print('Join')
                self._thread.join()
                self.thread = None;
                #self.root.ReadAll()
                print('Stopped')

            if self.runState.valueDisp() == 'Running':
                print("Starting run thread")
                self._thread = threading.Thread(target=self._run)
                self._thread.start()
            elif self.runState.valueDisp() == 'Calibration':
                self._thread = threading.Thread(target=self._calibrate)
                self._thread.start()

    def __triggerAndWait(self):
        self.root.waitOnUpdate()
        self.root.DesyTracker.EthAcquire()

        if self.runRate.valueDisp() == 'Auto':
            runCount = self.runCount.value() +1
            frameCount = self.root.DataWriter.getDataChannel().getFrameCount()
            #print(f'Current count is: {current}. Waiting for: {waitfor}')
            if not self.root.DataWriter.getDataChannel().waitFrameCount(self.runCount.value()+1, int(self.TimeoutWait.value()*1000000)):
                frameCount = self.root.DataWriter.getDataChannel().getFrameCount()
                print('Timed out waiting for data')
                print(f'Current frame count is: {frameCount}. Waiting for: {runCount}')
                print('Waiting again')
                start = time.time()
                if not self.root.DataWriter.getDataChannel().waitFrameCount(self.runCount.value()+1, int(self.TimeoutWait.value()*1000000)):
                    print('Timed out again')
                    return False
                else:
                    print(f'Got it this time in {time.time()-start} seconds')
        else:
            delay = 1.0 / self.runRate.value()
            time.sleep(delay)

        self.runCount += 1
        return True

    def __prestart(self):
        print('Prestart: Resetting run count')
        self.runCount.set(0)
        self.root.DataWriter.getDataChannel().setFrameCount(0)

        print('Prestart: Resetting Counters')
        self.root.CountReset()
        time.sleep(.2)
        print('Prestart: Reading system state')
        self.root.ReadAll()
        time.sleep(.2)

        print('Prestart: Starting Run')
        self.root.DesyTracker.KpixDaqCore.AcquisitionControl.Running.set(True)
        time.sleep(.2)

    def __endRun(self):
        print('')
        print('Stopping Run')
        self.root.DesyTracker.KpixDaqCore.AcquisitionControl.Running.set(False)

    def _run(self):
        self.__prestart()

        # This will be ignored if configured for external start signal
        self.root.DesyTracker.EthStart()
        time.sleep(.2)

        mode = self.root.DesyTracker.KpixDaqCore.AcquisitionControl.ExtAcquisitionSrc.valueDisp()

        with click.progressbar(
                iterable = range(self.MaxRunCount.value()),
                show_pos = True,
                label = click.style('Running ', fg='green')) as bar:

            lastFrameCount = 0

            while self.runState.valueDisp() == 'Running' and bar.finished is False:
                if mode == 'EthAcquire':
                    self.__triggerAndWait()
                    bar.update(1)
                else:
                    newFrameCount =  self.root.DataWriter.getDataChannel().getFrameCount()
                    newFrames = newFrameCount-lastFrameCount
                    lastFrameCount = newFrameCount
                    bar.update(newFrames)
                    self.runCount += newFrames
                    time.sleep(.1)

        print('_run Exiting')
        self.__endRun()
        if self.runState.valueDisp() != 'Stopped':
            self.runState.setDisp('Stopped')


    def _calibrate(self):
        # Latch all of the run settings so they can't be changed mid-run
        meanCount = self.CalMeanCount.value()
        dacMin = self.CalDacMin.value()
        dacMax = self.CalDacMax.value()
        dacStep = self.CalDacStep.value()
        dacCount = self.CalDacCount.value()
        firstChan = self.CalChanMin.value()
        lastChan = self.CalChanMax.value()

        # Configure firmware for calibration
        acqCtrl = self.root.DesyTracker.KpixDaqCore.AcquisitionControl
        acqCtrl.ExtTrigSrc.setDisp('Disabled', write=True)
        acqCtrl.ExtTimestampSrc.setDisp('Disabled', write=True)
        acqCtrl.ExtAcquisitionSrc.setDisp('EthAcquire', write=True)
        acqCtrl.ExtStartSrc.setDisp('EthStart', write=True)
        acqCtrl.Calibrate.set(True, write=True)

        self.runRate.setDisp('Auto')

        self.root.ReadAll()

        # Put asics in calibration mode
        kpixAsics = [self.root.DesyTracker.KpixDaqCore.KpixAsicArray.KpixAsic[i] for i in range(24)]
        kpixAsics = [kpix for kpix in kpixAsics if kpix.enable.get()==True] #small speed hack maybe
        for kpix in kpixAsics:
            kpix.setCalibrationMode()

        # Restart the run count
        self.__prestart()

        self.root.DesyTracker.EthStart()

        time.sleep(1)

        # First do baselines
        self.CalState.set('Baseline')
        with click.progressbar(
                iterable= range(meanCount),
                show_pos = True,
                label = click.style('Running baseline: ', fg='green')) as bar:

            for i in bar:
                if self.runState.valueDisp() == 'Calibration':
                    self.__triggerAndWait()
                else:
                    self.__endRun()
                    return

        dac = 0
        channel = 0
        chanSweep = range(firstChan, lastChan+1)
        chanLoops = len(list(chanSweep))
        dacSweep = range(dacMin, dacMax+1, dacStep)
        dacLoops = len(list(dacSweep))
        totalLoops = chanLoops * dacLoops


        def getDacChan(item):
            return f'Channel: {channel}, DAC: {dac}'

        # Calibration
        self.CalState.set('Inject')

        with click.progressbar(
                length = totalLoops,
                show_pos = True,
                item_show_func=getDacChan,
                label = click.style('Running Injection: ', fg='green'))  as bar:

            for channel in chanSweep:
                for dac in dacSweep:
                    bar.update(1)

                    with self.root.updateGroup():

                        # Set these to log in event stream
                        self.CalChannel.set(channel)
                        self.CalDac.set(dac)

                        # Configure each kpix for channel and dac
                        for kpix in kpixAsics:
                            # This occasionally fails so retry 10 times
                            for retry in range(10):
                                try:
                                    start = time.time()
                                    kpix.setCalibration(channel, dac)
                                    #print(f'Set new kpix settings in {time.time()-start} seconds')
                                    break
                                except pyrogue.MemoryError as e:
                                    if retry == 9:
                                        raise e
                                    else:
                                        print(f'{kpix.path}.setCalibration({channel}, {dac}) failed. Retrying')

                    # Send acquire command and wait for response
                    for count in range(dacCount):
                        if self.runState.valueDisp() == 'Calibration':
                            self.__triggerAndWait()
                        else:
                            self.__endRun()
                            return

        self.__endRun()
        if self.runState.getDisp() != 'Stopped':
            self.runState.setDisp('Stopped')
