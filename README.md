# react-commits-graph

a react component to render an svg graph of git commits

adapted from [tclh123/commits-graph](https://github.com/tclh123/commits-graph)

![react-commits-graph](docs/react-commits-graph.png)

## example

code to generate the graph above

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

expected structure of `commits` prop:
```js
[
  {
    "parents": [
      "82aa2102c8291f56f8dfefce1dce40d8a0dd686b",
      "175dfbbdbf8734069efaafced5a531dbf77c3a57"
    ],
    "sha": "5a7e04df76e21f9ba4a48098b6b26f19b51b99b1"
  },
  {
    "parents": [
      "90113cac59463df2e182e48444b8395658ebf840"
    ],
    "sha": "175dfbbdbf8734069efaafced5a531dbf77c3a57"
  },
  ...
]
```
