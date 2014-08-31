
React = require('react')
CommitsGraph = require('../')
commits = require('./commits.json')

var graphEl = document.querySelector('#graph')

var selected = null

function handleClick(sha) {
  selected = sha
  render()
}

function render() {
  React.renderComponent(CommitsGraph({
    commits: commits,
    onClick: handleClick,
    selected: selected,
    height: window.innerHeight,
    width: window.innerWidth,
  }), graphEl)
}

window.addEventListener('resize', render)

render()
