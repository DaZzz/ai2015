from PyQt5.QtCore import Qt
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from ImageType import ImageType

class Classifier(object):

  def __init__(self):
    super(Classifier, self).__init__()
    self.setA = None
    self.setB = None

  ###
  # Set image A or B
  ###
  def setImage(self, imageType, image):
    if not (imageType in [ImageType.A, ImageType.B]): return

    imageSet = {
      ImageType.A: self.setA,
      ImageType.B: self.setB
    }[imageType]

    imageSet = self._imageToVectorSet(image)

  ###
  # Get vector of all image shifts
  ###
  def _imageToVectorSet(self, image):
    resultSet = []
    w, h = image.width(), image.height()
    originalVector = [1.0]*(w*h)

    for y in range(h):
      for x in range(w):
        originalVector[x+y*w] = 1.0 if qRed(image.pixel(x, y)) < 125 else 0.0

    resultSet.append(originalVector)

    # Fill x shifts
    for shift in [-3, -2, -1, 1, 2, 3]:
      v = [0.0]*(w*h)
      for j in range(len(originalVector)):
        shiftJ = shift + j
        if shiftJ >= 0 and shiftJ < len(originalVector):
          v[j] = originalVector[shiftJ]
      resultSet.append(v)

    # Fill y shifts
    for shift in [-2, -1, 1, 2]:
      v = [0.0]*(w*h)
      for j in range(len(originalVector)):
        shiftJ = shift * w + j
        if shiftJ >= 0 and shiftJ < len(originalVector):
          v[j] = originalVector[shiftJ]
      resultSet.append(v)

    return resultSet