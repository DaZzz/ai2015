from PyQt5.QtCore import Qt
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from ImageType import ImageType
from copy import deepcopy

class Classifier(object):

  def __init__(self):
    super(Classifier, self).__init__()
    self.setA = None
    self.setB = None

  def isReadyToClassify(self):
    pass

  ###
  # Set image A or B
  ###
  def setImage(self, imageType, image):
    if not (imageType in [ImageType.A, ImageType.B]): return None

    if imageType == ImageType.A:
      self.setA = self._imageToVectorSet(image)
    elif imageType == ImageType.B:
      self.setB = self._imageToVectorSet(image)

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

  ###
  # Check if linearly separable
  ###
  def linearSeparation(self):
    if (not self.setA) or (not self.setB): return None

    setC = []

    # Merge [a_1..a_n, -1]
    for a in self.setA:
      c = deepcopy(a)
      c.append(-1.0)
      setC.append(c)

    # Merge [-b_1..-b_n, 1]
    for b in self.setB:
      c = [-p for p in b]
      c.append(1.0)
      setC.append(c)

    # Calculate l vector
    vectorLength = len(setC[0])
    h = 0.01
    l = [0]*vectorLength

    for i in range(vectorLength):
      for c in setC:
        l[i] += c[i]
    l = [li / len(setC) for li in l]

    # Main algorithm
    for k in range(1000):
      minC = setC[0]
      minVal = sum(x*y for x, y in zip(l, minC))

      for c in setC[1:]:
        newVal = sum(x*y for x, y in zip(l, c))
        if newVal < minVal:
          minC = c
          minVal = newVal

      for i, ci in enumerate(minC):
        l[i] += h * ci

      if minVal > 0: return l

    return None

  ###
  # Get image class
  ###
  def getImageClass(self, image):
    l = self.linearSeparation()
    if not l: return None

    w, h = image.width(), image.height()
    vector = [1.0]*(w*h)

    for y in range(h):
      for x in range(w):
        vector[x+y*w] = 1.0 if qRed(image.pixel(x, y)) < 125 else 0.0

    s = sum(x*y for x, y in zip(l[:-1], vector))
    return ImageType.A if s > l[-1] else ImageType.B

