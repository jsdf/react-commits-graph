React = require 'react'

CommitsGraphMixin = require './commits-graph-mixin'

CommitsGraph = React.createClass
  displayName: 'CommitsGraph'

  mixins: [
    CommitsGraphMixin,
  ]

  render: ->
    @renderGraph()

module.exports = CommitsGraph
