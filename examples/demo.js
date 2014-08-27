
React = require('react')
CommitsGraph = require('../')
commits = require('./input.json')

var commitsGraph = CommitsGraph({commits: commits})
React.renderComponent(commitsGraph, document.querySelector('#graph'))

