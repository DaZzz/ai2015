window.onload = ->

  myImg = new Image()
  myImg.src = 'a.png'
  context = document.getElementById('c1').getContext('2d')
  context.imageSmoothingEnabled = false
  context.drawImage(myImg, 0, 0, 200, 200)

  myImg = new Image()
  myImg.src = 'b.png'
  context = document.getElementById('c2').getContext('2d')
  context.imageSmoothingEnabled = false
  context.drawImage(myImg, 0, 0, 200, 200)

# data = context.getImageData(x, y, 1, 1).data