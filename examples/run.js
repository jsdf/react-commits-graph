#!/usr/bin/env node

exec = require('child_process').exec
spawn = require('child_process').spawn

exec('git rev-parse --show-toplevel', function(err, stdout, stderr) {
  REPO_ROOT = stdout.split('\n')[0]
  EXAMPLES_DIR = REPO_ROOT+'/examples'

  BROWSERIFY_ARGS = [
    '--extension=".coffee"',
    '--outfile', EXAMPLES_DIR+'/bundle.js',
    '--entry', EXAMPLES_DIR+'/demo.js',
  ]

  exec('npm run prepublish', function(err, stdout, stderr) {
    if (process.argv[2] == 'watch') {
      console.log('watch and build')
      spawn('npm', ['run', 'watch'], { stdio: 'inherit' })
      spawn('watchify', ['-v'].concat(BROWSERIFY_ARGS), { stdio: 'inherit' })
    } else {
      console.log('build once')
      spawn('browserify', BROWSERIFY_ARGS, { stdio: 'inherit' })
    }
    spawn('http-server', [EXAMPLES_DIR], { stdio: 'inherit' })
    exec('open http://localhost:8080')
  })
})
