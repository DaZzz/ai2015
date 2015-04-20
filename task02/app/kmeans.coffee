# Euler distance
eulerDistance = (v1, v2) ->
  total = 0

  for __, i in v1
    total += Math.pow(v2[i] - v1[i], 2)

  Math.sqrt(total)

# Return closest centroid
closestCentroid = (point, centroids, distance)  ->
  min = Infinity
  index = 0

  for c, i in centroids
    dist = distance(point, c)

    if (dist < min)
      min = dist
      index = i

  index


# Random k points from points
randomPointCentroids = (points, k) ->
  _.take(_.shuffle(points), k)

# Random points centroids
randomCentroids = (points, k) ->
  zipped       = _.unzip(points)
  zippedRandom = _.map zipped , (xs) ->

    max = _.max(xs)
    min = _.min(xs)
    newXs = []
    for i in [0..k-1]
      newXs.push(Math.random() * max - min)
    newXs

  _.unzip(zippedRandom)

###
# Implementation of k-means algorithm
#   bounds: [[Double, Double]]
#   k: Double
#   vectors: [[Double]]
#
# Return clusters with indices of original points
###
kmeans = (points, k) ->

  centroidsArray = randomPointCentroids(points, k).slice(0)
  assignments    = new Array(points.length)
  clusters       = new Array(k)
  distance       = ((v1, v2) -> eulerDistance(v1, v2))

  console.log centroidsArray.toString()

  hasMovement = true
  while hasMovement

    # update point-to-centroid assignments
    for p, i in points
      assignments[i] = closestCentroid(p, centroidsArray, distance)

    hasMovement = false
    # For each cluster
    for j in [0..k-1]
      assigned = []

      # Find all assigned points to this cluster
      for __, i in assignments
        if assignments[i] == j
          assigned.push(points[i].slice(0))

      if assigned.length == 0
        continue

      # Get current centroid of this cluster
      centroid = centroidsArray[j].slice(0)
      newCentroid  = new Array(centroid.length)

      # Calcualate coordinates of a new centroid
      for __, i in centroid
        sum = 0


        # Sum i-th coordiante of all assigned
        sum += a[i] for a in assigned

        # Get mean of all coordiantes
        newCentroid[i] = sum / assigned.length

        if (newCentroid[i] != centroid[i])
          hasMovement = true

        centroidsArray[j]  = newCentroid
        clusters[j]   = assigned

  return clusters

###
# Export
###
module.exports = kmeans










