#!/usr/bin/env python

from PyQt5.QtCore import Qt
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
import numpy as np
import math
from ImageType import ImageType

class MainWindow(QMainWindow):
  ###
  # Init window:
  # Setup layout
  # Setup menu and actions
  # Setup outlets
  ###
  def __init__(self):
    super(MainWindow, self).__init__()

    # Init properties
    self.imageA = None
    self.imageB = None
    self.imageC = None

    self.imageLabelA = QLabel()
    self.imageLabelB = QLabel()
    self.imageLabelC = QLabel()

    # Basic window setup
    self.setWindowTitle('Classifier MX2020')
    self.setMinimumSize(800,300)
    self.setMaximumSize(800,300)
    self.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)

    self.setupLayout()
    self.createActions()
    self.createMenus()

  ###
  # Set main layout
  ###
  def setupLayout(self):
    centralWidget = QWidget()
    hbox = QHBoxLayout()
    hbox.setContentsMargins(5, 5, 5, 5)
    hbox.addWidget(self.createImageGroup('Image A', self.imageLabelA, 'Image seed for class A'))
    hbox.addWidget(self.createImageGroup('Image B', self.imageLabelB, 'Image seed for class B'))
    hbox.addWidget(self.createImageGroup('Image C', self.imageLabelC, 'Image that requires class identification'))
    centralWidget.setLayout(hbox)
    self.setCentralWidget(centralWidget)

  ###
  # Components
  ###
  def createImageGroup(self, title, imageLabel, caption):
    aGroup = QGroupBox(title)


    imageLabel.setBackgroundRole(QPalette.Dark)
    imageLabel.setStyleSheet('QLabel { background-color: #afafaf; border-radius: 8px; }')
    imageLabel.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)
    imageLabel.setMaximumSize(200, 200)
    imageLabel.setMinimumSize(200, 200)
    centeringWidget = QWidget()
    centeringLayout = QGridLayout()
    centeringLayout.addWidget(imageLabel)
    centeringWidget.setLayout(centeringLayout)


    captionLabel = QLabel(caption)
    captionLabel.setAlignment(Qt.AlignCenter)
    captionLabel.setStyleSheet('QLabel { color: #888888; font-size: 10px; }')

    vbox = QVBoxLayout()
    vbox.addWidget(centeringWidget)
    vbox.addWidget(captionLabel)
    aGroup.setLayout(vbox)
    return aGroup

  ###
  # Actions
  ###
  def openImageA(self):
    filePath, _ = QFileDialog.getOpenFileName(self, 'Open Image', '', 'Image Files (*.png *.jpeg *.jpg)')
    self.imageA = QImage(filePath)
    self.imageLabelA.setPixmap(QPixmap.fromImage(self.imageA))

  def openImageB(self):
    pass

  def openImageC(self):
    pass


  def createActions(self):
    self.openImageAAct = QAction('&Open image A', self, triggered=self.openImageA)
    self.openImageBAct = QAction('&Open image B', self, triggered=self.openImageB)
    self.openImageCAct = QAction('&Open for classification', self, shortcut=QKeySequence.Open, triggered=self.openImageC)

  ###
  # Menus
  ###
  def createMenus(self):
    self.fileMenu = self.menuBar().addMenu('&File')
    self.fileMenu.addAction(self.openImageAAct)
    self.fileMenu.addAction(self.openImageBAct)
    self.fileMenu.addAction(self.openImageCAct)


# Run programm
if __name__ == '__main__':
  import sys

  app = QApplication(sys.argv)
  window = MainWindow()
  window.show()
  sys.exit(app.exec_())

