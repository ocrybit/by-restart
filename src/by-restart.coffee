fs = require('fs')
EventEmitter = require('events').EventEmitter
path = require('path')
util = require('util')
_ = require('underscore')
minimatch = require('minimatch')
path = require('path')
cp = require('child_process')
spawn = cp.spawn
module.exports = class ByRestart extends EventEmitter

  constructor: (@opts = {}) ->
    @coffee = @opts?.coffee ? false
    @command = @opts?.command
    @options = @opts?.options ? []
    @ignoreFiles = []

    if @opts?.ignoreFiles?
      @_setIgnoreFiles(@opts.ignoreFiles)

  _setListeners: (@bystander) ->
    @bystander.on('File changed', (file) =>
      extname = path.extname(file)
      if (@coffee and extname is '.coffee') or (not @coffee and extname is '.js')
        if not @_isIgnore(file)
          console.log(file + ' changed, restarting the server...')
          @ps.kill()
          @_run()
    )
  _init: (callback) ->
    @_run(callback)

  _run : (callback) ->
    @ps = spawn(@command,@options)
    @ps.stdout.setEncoding('utf8')
    @ps.stderr.setEncoding('utf8')
    @ps.stdout.on('data',(data)=>
      console.log(data)
    )
    @ps.stderr.on('data',(data)=>
      console.log(data)
    )
    @ps.on('exit',(code)=>
      console.log('An error found, restarting the server...')
      @ps.kill()
      @_run()
    )
    callback?()
  _setIgnoreFiles: (newFiles) ->
    @ignoreFiles = _(@ignoreFiles).union(newFiles)

  _isIgnore: (file) ->
    for v in @ignoreFiles
      if minimatch(file, v, {dot : true})
        return true
    return false
