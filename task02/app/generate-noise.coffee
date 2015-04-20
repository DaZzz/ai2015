kmeans = require('kmeans')

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
  canvas = $('<canvas/>').attr(width: width, height: height).appendTo('body').get(0)
  context = canvas.getContext('2d')
  context.fillStyle = 'white'
  context.rect(0,0,width,height)
  context.fill()
  context


###
# Image -> [Context]
###
generateImages = (image) ->
  [addWhiteNoise, addBlackNoise] = ['white', 'black'].map (color) -> _.curryRight(addNoise)(2)(color)

  # _.chain combinations([-2..2], [-3..3])
  _.chain combinations([0,0,0,0,0], [0,0,0,0,0])
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
# Main function
###
window.onload = ->

  pairs = _.chain 'a b'.split(' ')
    .map (name) -> createImage("#{name}.png")
    .map generateImages
    .flatten()
    .map (context) -> [context, vectorize(context)]
    .value()

  vectors  = _.unzip(pairs)[1]
  clusters = kmeans(vectors, 2)

  a = clusters.map (cluster) ->
    _.filter pairs, (pair) -> includes(cluster, pair[1])

  a.map (cluster) ->
    $('<hr/>').attr(class: 'divider').appendTo('body')

    cluster.map (pair) ->
      console.log pair[0]
      context = pair[0]
      {width, height} = context.canvas
      createContext(context).drawImage(context.canvas, 0, 0, width, height)

