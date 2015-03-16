#!/usr/bin/env python

from PyQt5.QtCore import Qt
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
import numpy as np
import math
from ImageType import ImageType
from Classifier import Classifier

IMAGE_LABEL_SIZE = 200

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
    imageLabel.setMaximumSize(IMAGE_LABEL_SIZE, IMAGE_LABEL_SIZE)
    imageLabel.setMinimumSize(IMAGE_LABEL_SIZE, IMAGE_LABEL_SIZE)
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
  def openImage(self, imageType):
    filePath, _ = QFileDialog.getOpenFileName(self, 'Open Image', '', 'Image Files (*.png *.jpeg *.jpg)')

    image, imageLabel = {
      ImageType.A: (self.imageA, self.imageLabelA),
      ImageType.B: (self.imageB, self.imageLabelB),
      ImageType.C: (self.imageC, self.imageLabelC)
      }[imageType]

    image = QImage(filePath)

    pixmap = QPixmap.fromImage(image).scaled(IMAGE_LABEL_SIZE, IMAGE_LABEL_SIZE, \
             Qt.IgnoreAspectRatio, Qt.FastTransformation)
    imageLabel.setPixmap(pixmap)

  def createActions(self):
    self.openImageAAct = QAction('&Open image A', self, triggered=lambda: self.openImage(ImageType.A))
    self.openImageBAct = QAction('&Open image B', self, triggered=lambda: self.openImage(ImageType.B))
    self.openImageCAct = QAction('&Open for classification', self, shortcut=QKeySequence.Open, \
                                triggered=lambda: self.openImage(ImageType.C))

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

