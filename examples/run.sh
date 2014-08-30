#!/bin/bash
./build.sh
open http://localhost:8080
http-server $EXAMPLES_DIR
