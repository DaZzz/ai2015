kmeans = require('kmeans')

###
# Constants
###
IMAGE_SIZE = 50

###
# Int -> Int
###
randomInt = (n) ->
  Math.round(Math.random() * n)


###
# (Context, String, Int) -> Context
###
addNoise = (context, color, coefficient) ->
  context.fillStyle = color
  for i in [0..randomInt(coefficient)-1]
    [x, y] = [context.canvas.width, context.canvas.height].map randomInt
    context.fillRect(x, y, 1, 1)
  context


###
# ([Int], [Int]) -> [[Int, Int]]
###
combinations = (xs, ys) ->
  result = []
  for i in xs
    for j in ys
      result.push [i,j]
  result


###
# Image -> Context
###
createContext = (image) ->
  {width, height} = image.canvas || image
  canvas = $('<canvas/>').attr(width: width, height: height).get(0)
  context = canvas.getContext('2d')
  context.fillStyle = 'white'
  context.rect(0,0,width,height)
  context.fill()
  context


###
# Image -> [Context]
###
generateImages = (image) ->
  [addWhiteNoise, addBlackNoise] = ['white', 'black'].map (color) -> _.curryRight(addNoise)(3)(color)

  # _.chain combinations([-2..2], [-3..3])
  # _.chain combinations([0,0,0,0,0,0], [0,0,0,0,0])
  _.chain [1..60].map -> [0, 0]
    .map (shift) ->
      [i, j] = shift
      context = createContext(image)
      context.drawImage(image, j, i, image.width, image.height)
      context
    .map (context) -> addBlackNoise(context)
    .map (context) -> addWhiteNoise(context)
    .value()


###
# String -> Image
###
createImage = (url) ->
  img = new Image()
  img.src = url
  img


###
# Context -> [Double]
###
vectorize = (context) ->
  {width, height} = context.canvas
  # console.log context.getImageData(0, 0, width, height).data
  _.chain context.getImageData(0, 0, width, height).data
    .chunk(4)
    .map (channels) -> channels[0] / 255.0
    .value()

###
# ([[]], []) -> Boolean
###
window.includes = (xss, xs) -> _.any(xss, (ys) -> _.isEqual(ys, xs))

###
# Handle drawing
#   [context, index, index, cluster, clusterN]
#
#
#
###
redrawImages = (images) ->
  cols = 15
  padding = 10
  width = IMAGE_SIZE
  height = IMAGE_SIZE

  paneWidth = width * cols + padding * (cols - 1)

  pane = d3.select('body').selectAll('div.pane').data([1])

  pane.enter().append('div')
    .attr('class', 'pane')
    .style('position', 'relative')
    .style('width', paneWidth+'px')

  cs = pane.selectAll('canvas').data(images)

  cs.enter()
    .append (d) -> d
    .style('position', 'absolute')
    .style('opacity', '0')
    .style('transform', 'translateY(0, 200)')
    .transition(300)
    .delay((d, i) -> i*10)
    .style('opacity', 1)

  cs.transition()
    .style('left', (d, i) -> (i % cols) * width + (i % cols) * padding + 'px')
    .style('top', (d, i) -> Math.floor(i / cols) * height + Math.floor(i / cols) * padding + 'px')



###
# Main function
###
window.onload = ->


  pairs = _.chain 'a b'.split(' ')
    .map (name) -> createImage("#{name}.png")
    .map generateImages
    .flatten()
    .map (context) -> [context, vectorize(context)]
    .value()


  redrawImages(pairs.map (pair) -> pair[0].canvas)

