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
  _.chain [1..64].map -> [0, 0]
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
#   data = [context, index, indexCluster, cluster, clusterN]
###
redrawImages = (data, k) ->


  cols = 16
  padding = 10
  clusterMargin = 100
  width = IMAGE_SIZE
  height = IMAGE_SIZE

  paneWidth = width * cols + padding * (cols - 1) + clusterMargin * (k - 1)

  pane = d3.select('body').selectAll('div.pane').data([1])

  pane.enter().append('div')
    .attr('class', 'pane')
    .style('position', 'relative')

  pane.style('width', paneWidth+'px')

  cs = pane.selectAll('canvas').data(data, (d) -> d[1])

  cs.enter()
    .append (d) -> d[0].canvas
    .style('position', 'absolute')
    .style('opacity', '0')
    .transition(300)
    .style('opacity', 1)

  cs.transition()
    .style('left', (d) ->
      [ctx, i, ic, c, cn] = d
      colsInCluster = Math.round(cols / cn)
      clusterWidth = colsInCluster * width + padding * (colsInCluster - 1)
      offset = (ic % colsInCluster) * width + (ic % colsInCluster) * padding
      clusterWidth * c + clusterMargin * c + offset + 'px'
    )

    .style('top', (d, i) ->
      [ctx, i, ic, c, cn] = d
      colsInCluster = Math.round(cols / cn)
      clusterWidth = colsInCluster * width + padding * (colsInCluster - 1)
      Math.floor(ic / colsInCluster) * height + Math.floor(ic / colsInCluster) * padding + 'px'
    )



###
# Main function
###
window.onload = ->


  contextVectorPairs = _.chain 'a b z'.split(' ')
    .map (name) -> createImage("#{name}.png")
    .map generateImages
    .flatten()
    .map (context) -> [context, vectorize(context)]
    .value()

  data = contextVectorPairs.map (pair, i) ->
    [context, vector] = pair
    [context, i, i, 0, 1, vector]

  redrawImages(data, 1)


  isShuffled = true
  $('body').click ->

    if isShuffled
      vectors  = _.unzip(data)[5]
      clusters = kmeans(vectors, 3)
      clusters = clusters.map (cluster) -> _.zip(cluster, (cluster.map -> true))

      ###
      # Prepare data for drawing
      ###
      clusterizedData = data.map (d) ->

        c = _.findIndex(clusters, (c) ->

          _.findIndex(c, (vectorBoolPair) -> _.isEqual(vectorBoolPair[0], d[5])) != -1
        )

        cluster = clusters[c]

        ci = _.findIndex cluster, (vectorBoolPair) ->
            if _.isEqual(d[5], vectorBoolPair[0]) and vectorBoolPair[1]
              vectorBoolPair[1] = false
              true
            else
              false

        d = [d[0], d[1], ci, c, 3, d[5]]

      redrawImages(clusterizedData)
      isShuffled = false
    else
      inds = _.shuffle(_.map(data, (d) -> d[1]))
      dataShuffle = _.map(data, (d, i) -> d[2] = inds[i]; d[3] = 0; d[4] = 1; d)
      redrawImages(dataShuffle)
      isShuffled = true
