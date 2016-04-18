#!/usr/bin/env python

#import pythonDaq
import time
import sys
from PyQt4 import QtGui

from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar
import matplotlib.pyplot as plt

import random

class Window(QtGui.QDialog):
    def __init__(self, parent=None):
        super(Window, self).__init__(parent)

        # a figure instance to plot on
        self.figure = plt.figure()

        # this is the Canvas Widget that displays the `figure`
        # it takes the `figure` instance as a parameter to __init__
        self.canvas = FigureCanvas(self.figure)

        # this is the Navigation widget
        # it takes the Canvas widget and a parent
        self.toolbar = NavigationToolbar(self.canvas, self)

        # Just some button connected to `plot` method
        #self.button = QtGui.QPushButton('Plot')
        #self.button.clicked.connect(self.plot)

        # set the layout
        layout = QtGui.QVBoxLayout()
        layout.addWidget(self.toolbar)
        layout.addWidget(self.canvas)
        #layout.addWidget(self.button)
        self.setLayout(layout)

    def plot(self):
        ''' plot some random stuff '''
        # random data
        data = [random.random() for i in range(10)]

        # create an axis
        ax = self.figure.add_subplot(111)

        # discards the old graph
        ax.hold(False)

        # plot data
        ax.plot(data, '*-')

        # refresh canvas
        self.canvas.draw()

if __name__ == '__main__':
    app = QtGui.QApplication(sys.argv)

    main = Window()
    main.show()

    sys.exit(app.exec_())

#def main():
#   app = QtGui.QApplication(sys.argv)
#
#   w = QtGui.QWidget()
#   w.resize(250,150)
#   w.move(300,300)
#   w.setWindowTitle('Simple')
#   w.show()
#
#   sys.exit(app.exec_())
#
#if __name__ == '__main__':
#   main()

#pythonDaq.daqSharedDataOpen("test",1);

#last = time.time()

#count = 0
#tcount = 0
#lret = None
#
#while True:
#
#   ret = pythonDaq.daqSharedDataRead();
#   if ret[0] == 0:
#       time.sleep(.001)
#   else:
#       count += 1
#       tcount += 1
#       lret = ret
#
#   if (time.time() - last) > 1.0:
#       print ""
#       print "Got: %i frames, %i hz: %s" % (tcount,count,str(lret))
#       count = 0
#       last = time.time()

