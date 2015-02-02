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

classSet = (classes...) -> classes.filter(Boolean).join(' ')

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

distance = (point1, point2) ->
  xs = 0
  ys = 0
  xs = point2.x - point1.x
  xs = xs * xs
  ys = point2.y - point1.y
  ys = ys * ys
  Math.sqrt xs + ys

CommitsGraphMixin =
  getDefaultProps: ->
    y_step: 20
    x_step: 20
    dotRadius: 3
    lineWidth: 2
    selected: null
    mirror: false
    unstyled: false

  componentWillReceiveProps: ->
    @graphData = null
    @branchCount = null

  cursorPoint: (e) ->
    svg = @getDOMNode()
    svgPoint = svg.createSVGPoint()
    svgPoint.x = e.clientX
    svgPoint.y = e.clientY
    svgPoint.matrixTransform svg.getScreenCTM().inverse()

  handleClick: (e) ->
    cursorLoc = @cursorPoint(e)

    smallestDistance = Infinity
    closestCommit = null
    for commit in @renderedCommitsPositions
      commitDistance = distance(cursorLoc, commit)
      if commitDistance < smallestDistance
        smallestDistance = commitDistance
        closestCommit = commit

    @props.onClick?(closestCommit.sha)

  getGraphData: ->
    @graphData ||= generateGraphData(@props.commits)

  getBranchCount: ->
    @branchCount ||= branchCount(@getGraphData())

  getWidth: ->
    return @props.width if @props.width?
    @getContentWidth()

  getContentWidth: ->
    (@getBranchCount() + 0.5) * @props.x_step

  getHeight: ->
    return @props.height if @props.height?
    @getContentHeight()

  getContentHeight: ->
    (@getGraphData().length + 2) * @props.y_step

  getInvert: ->
    if @props.mirror
      0 - @props.width
    else
      0

  getOffset: ->
    @getWidth() / 2 - @getContentWidth() / 2

  renderRouteNode: (svgPathDataAttribute, branch) ->    
    unless @props.unstyled
      colour = getColour(branch)
      style =
        'stroke': colour
        'stroke-width': @props.lineWidth
        'fill': 'none'

    classes = "commits-graph-branch-#{branch}"

    React.DOM.path
      d: svgPathDataAttribute
      style: style
      className: classes

  renderRoute: (commit_idx, [from, to, branch]) ->
    {x_step, y_step} = @props
    offset = @getOffset()
    invert = @getInvert()

    svgPath = new SVGPathData

    from_x = offset + invert + (from + 1) * x_step
    from_y = (commit_idx + 0.5) * y_step
    to_x = offset + invert + (to + 1) * x_step
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

    @renderRouteNode(svgPath.toString(), branch)

  renderCommitNode: (x, y, sha, dot_branch) ->
    radius = @props.dotRadius

    unless @props.unstyled
      colour = getColour(dot_branch)
      if sha is @props.selected
        strokeColour = '#000'
        strokeWidth = 2
      else
        strokeColour = colour
        strokeWidth = 1
      style =
        'stroke': strokeColour
        'stroke-width': strokeWidth
        'fill': colour

    selectedClass = 'selected' if @props.selected
    classes = classSet("commits-graph-branch-#{dot_branch}", selectedClass)

    React.DOM.circle 
      cx: x
      cy: y
      r: radius
      style: style
      onClick: @handleClick
      'data-sha': sha
      className: classes

  renderCommit: (idx, [sha, dot, routes_data]) ->
    [dot_offset, dot_branch] = dot

    # draw dot
    {x_step, y_step} = @props
    offset = @getOffset()
    invert = @getInvert()

    x = offset + invert + (dot_offset + 1) * x_step
    y = (idx + 0.5) * y_step

    commitNode = @renderCommitNode(x, y, sha, dot_branch)

    routeNodes = for route, index in routes_data
      @renderRoute(idx, route)

    @renderedCommitsPositions.push {x, y, sha}

    [commitNode, routeNodes]

  renderGraph: ->
    # reset lookup table of commit node locations
    @renderedCommitsPositions = []

    allCommitNodes = []
    allRouteNodes = []

    for commit, index in @getGraphData()
      [commitNode, routeNodes] = @renderCommit(index, commit)
      allCommitNodes.push commitNode
      allRouteNodes = allRouteNodes.concat routeNodes

    children = [].concat allRouteNodes, allCommitNodes

    height = @getHeight()
    width = @getWidth()
    unless @props.unstyled
      style = {height, width, cursor: 'pointer'}

    svgProps = {height, width, style, children}

    React.DOM.svg
      onClick: @handleClick
      height: height
      width: width
      style: style
      children: children

module.exports = CommitsGraphMixin