EPSILON = 0.0001

###
# Int -> Int
###
randomInt = (n) ->
  Math.round(Math.random() * n)


###
# String -> Image
###
createImage = (url) ->
  img = new Image()
  img.src = url
  img


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
# Context -> [[Int]]
###
getMatrixFromContext = (context) ->
  {width, height} = context.canvas

  vector = _.chain context.getImageData(0, 0, width, height).data
    .chunk(4)
    .map (channels) -> Math.round(Math.abs((channels[0] / 255.0) - 1))
    .value()

  _.chunk(vector, width)


###
# Hough transform
###
houghTransform = (context) ->
  {width, height} = context.canvas
  original        = getMatrixFromContext(context)
  maxDistance     = Math.round(Math.sqrt(height*height + width*width))

  theta = [-90..89]
  rho   = [-maxDistance..maxDistance]

  accumulator = _.map [0..rho.length], ->
    _.map [0..theta.length], -> 0

  for y in [0..height-1]
    for x in [0..width-1]

      # if point of interest
      if original[y][x] > 0

        for indexTheta in theta
          t = theta[indexTheta] * Math.PI / 180.0
          r = Math.round(x * Math.cos(t) + y * Math.sin(t))
          ri = _.findIndex(rho, (rho0) -> Math.abs(rho0 - r) < EPSILON)

          if ri > 0
            accumulator[ri][indexTheta] += 1

  accumulator


###
# Get distance
###
euclidianDistance = (m1, m2) ->

  height = m1.length
  width = m1[0].length
  acc = 0

  for h in [0..height-1]
    for w in [0..width-1]
      acc += Math.pow(m1[h][w] - m2[h][w], 2)

  Math.sqrt(acc)


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
# Main function
###
window.onload = ->

  # Array of Hough transformed images
  models = []

  _.each [0..9], (i) ->
    img = createImage("#{i}.png")
    context = createContext(img)
    context.drawImage(img, 0, 0, img.width, img.height)
    models.push(houghTransform(context))
    $('body .original-images').append(context.canvas)

  $('body').on 'click', ->
    ri = randomInt(9)
    img = createImage("#{ri}.png")
    context = createContext(img)
    context.drawImage(img, 0, 0, img.width, img.height)
    addNoise(context, 'black', 10)
    addNoise(context, 'white', 10)
    $('body .history').append(context.canvas)

    distances = [0..models.length-1].map((i) -> euclidianDistance(houghTransform(context), models[i]))
    minIndex  = _.findIndex(distances, (d) -> d == _.min(distances))


    console.log minIndex








