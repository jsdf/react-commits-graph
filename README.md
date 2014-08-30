# react-commits-graph

react component to render an svg graph of git commits


## example

```js
React = require('react');
CommitsGraph = require('react-commits-graph');
commits = require('./commits.json');

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
