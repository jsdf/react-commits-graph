# react-commits-graph

a react component to render an svg graph of git commits

![react-commits-graph](docs/react-commits-graph.png)

## example

```js
var React = require('react');
var CommitsGraph = require('react-commits-graph');
var commits = require('./commits.json');

var selected = null;

function handleClick(sha) {
  selected = sha;
  render();
}

function render() {
  React.renderComponent(CommitsGraph({
    commits: commits,
    onClick: handleClick,
    selected: selected,
  }), document.querySelector('#graph'));
}

render();
```
