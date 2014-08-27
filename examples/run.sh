#!/bin/bash
REPO_ROOT=`git rev-parse --show-toplevel`
EXAMPLES_DIR="$REPO_ROOT/examples"
npm run prepublish
browserify $EXAMPLES_DIR/demo.js > $EXAMPLES_DIR/bundle.js
open http://localhost:8080
http-server $EXAMPLES_DIR
