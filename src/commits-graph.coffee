# @cjsx React.DOM
React = require 'react'

generateGraphData = require './generate-graph-data'

SVGPathData = require './svg-path-data'

COLOURS = [
  "#e11d21",
  "#fbca04",
  "#009800",
  "#006b75",
  "#207de5",
  "#0052cc",
  "#5319e7",
  "#f7c6c7",
  "#fad8c7",
  "#fef2c0",
  "#bfe5bf",
  "#c7def8",
  "#bfdadc",
  "#bfd4f2",
  "#d4c5f9",
  "#cccccc",
  "#84b6eb",
  "#e6e6e6",
  "#ffffff",
  "#cc317c",
]

getColour = (branch) ->
  n = COLOURS.length
  COLOURS[branch % n]
  
branchCount = (data) ->
  maxBranch = -1
  i = 0

  while i < data.length
    j = 0

    while j < data[i][2].length
      if maxBranch < data[i][2][j][0] or maxBranch < data[i][2][j][1]
        maxBranch = Math.max.apply(Math, [
          data[i][2][j][0]
          data[i][2][j][1]
        ])
      j++
    i++
  maxBranch + 1

CommitsGraph = React.createClass
  displayName: 'CommitsGraph'
  getDefaultProps: ->
    height: 800
    width: 200
    y_step: 20
    x_step: 20
    orientation: "vertical"
    dotRadius: 3
    lineWidth: 2

  componentWillReceiveProps: ->
    @graphData = null

  getGraphData: ->
    @graphData ||= generateGraphData(@props.commits)

  getWidth: ->
    return @props.width if @props.width?

    if @props.orientation is "horizontal"
      (@getGraphData().length + 2) * @props.x_step
    else
      (branchCount(@getGraphData()) + 0.5) * @props.x_step

  getHeight: ->
    return @props.height if @props.height?

    if @props.orientation is "horizontal"
      (branchCount(@getGraphData()) + 0.5) * @props.y_step
    else
      (@getGraphData().length + 2) * @props.y_step

  renderGraph: ->
    buffers =
      dots: []
      lines: []

    for commit, index in @getGraphData()
      @renderCommit(index, commit, buffers)

    height = @getHeight()
    width = @getWidth()
    style = {height, width}

    children = [].concat buffers.lines, buffers.dots

    React.DOM.svg({height, width, style, children})

  renderCommit: (idx, [sha, dot, routes_data], buffers) ->
    [dot_offset, dot_branch] = dot

    # draw dot
    {x_step, y_step, width} = @props
    radius = @props.dotRadius
    colour = getColour(dot_branch)
    if @props.orientation is "horizontal"
      x = width - (idx + 0.5) * x_step
      y = (dot_offset + 1) * y_step
    else
      x = width - (dot_offset + 1) * x_step
      y = (idx + 0.5) * y_step

    style =
      stroke: colour
      fill: colour

    {onClick} = @props
    handleClick = -> onClick?(sha)

    buffers.dots.push <circle cx={x} cy={y} r={radius} style={style} onClick={handleClick} />

    # draw routes
    svgRoutes = for route, index in routes_data
      @renderRoute(idx, route)

    buffers.lines.push svgRoutes...

  renderRoute: (commit_idx, [from, to, branch]) ->
    {x_step, y_step, width} = @props

    colour = getColour(branch)
    style =
      stroke: colour
      fill: 'none'
    
    svgPath = new SVGPathData

    if @props.orientation is "horizontal"
      from_x_hori = width - (commit_idx + 0.5) * x_step
      from_y_hori = (from + 1) * y_step
      to_x_hori = width - (commit_idx + 0.5 + 1) * x_step
      to_y_hori = (to + 1) * y_step

      svgPath.moveTo(from_x_hori, from_y_hori)
      if from_y_hori is to_y_hori
        svgPath.lineTo(to_x_hori, to_y_hori)
      else if from_y_hori > to_y_hori
        svgPath.bezierCurveTo(
          from_x_hori - x_step / 3 * 2, from_y_hori + y_step / 4,
          to_x_hori + x_step / 3 * 2, to_y_hori - y_step / 4,
          to_x_hori, to_y_hori
        )
      else 
        if from_y_hori < to_y_hori
          svgPath.bezierCurveTo(
            from_x_hori - x_step / 3 * 2, from_y_hori - y_step / 4,
            to_x_hori + x_step / 3 * 2, to_y_hori + y_step / 4,
            to_x_hori, to_y_hori
          )
    else
      from_x = width - (from + 1) * x_step
      from_y = (commit_idx + 0.5) * y_step
      to_x = width - (to + 1) * x_step
      to_y = (commit_idx + 0.5 + 1) * y_step

      svgPath.moveTo(from_x, from_y)
      if from_x is to_x
        svgPath.lineTo(to_x, to_y)
      else
        svgPath.bezierCurveTo(
          from_x - x_step / 4, from_y + y_step / 3 * 2,
          to_x + x_step / 4, to_y - y_step / 3 * 2,
          to_x, to_y
        )

    <path d={svgPath.toString()} style={style} />

  render: ->
    @renderGraph()

module.exports = CommitsGraph