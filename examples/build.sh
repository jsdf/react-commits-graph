#!/bin/bash
REPO_ROOT=`git rev-parse --show-toplevel`
EXAMPLES_DIR="$REPO_ROOT/examples"
npm run prepublish
watchify -v --extension=".coffee" -o $EXAMPLES_DIR/bundle.js $EXAMPLES_DIR/demo.js