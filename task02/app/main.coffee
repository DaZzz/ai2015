kmeans = require('kmeans')

data = [
  [0.1, 0.2], [0.2, 0.25], [0.2, 0.4], [0.35, 0.2], [0.23, 0.32]
  [0.7, 0.7], [0.7, 0.75], [0.7, 0.8], [0.85, 0.7], [0.73, 0.82]
  ]

###
# Draw original plot
###
margin =
  top: 30
  right: 30
  bottom: 30
  left: 30

width = 400 - margin.left - margin.right
height = 400 - margin.top - margin.bottom


# Get scales and axes
x = d3.scale.linear()
  .range([0, width])
  .domain([0, 1])

y = d3.scale.linear()
  .range([height, 0])
  .domain([0, 1])

# Add axes
xAxis = d3.svg.axis()
  .scale(x)
  .orient('bottom')

yAxis = d3.svg.axis()
  .scale(y)
  .orient('left')

# Drawing surface
svg = d3.select('body').append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
    .attr('class', 'chart')
  .append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")

# Append axes
svg.append('g')
  .attr('class', 'x axis')
  .attr('transform', "translate(0, #{height})")
  .call(xAxis)

svg.append('g')
  .attr('class', 'y axis')
  .call(yAxis)

# Append dots
# svg.selectAll('circle')
#   .data(data).enter()
#     .append('circle')
#     .attr('r', 2)
#     .attr('cx', (d) -> x(d[0]) - 1)
#     .attr('cy', (d) -> y(d[1]) - 1)

###
# Apply k-means algorithm
###
clusterized = kmeans(data, 2)


###
#  Draw new plot after clusterization
###
# Append dots
svg.selectAll('circle.red')
  .data(clusterized[0]).enter()
    .append('circle')
    .attr('class', 'red')
    .attr('r', 2)
    .attr('cx', (d) -> x(d[0]) - 1)
    .attr('cy', (d) -> y(d[1]) - 1)
    .attr('fill', 'red')

svg.selectAll('circle.blue')
  .data(clusterized[1]).enter()
    .append('circle')
    .attr('class', 'blue')
    .attr('r', 2)
    .attr('cx', (d) -> x(d[0]) - 1)
    .attr('cy', (d) -> y(d[1]) - 1)
    .attr('fill', 'blue')




