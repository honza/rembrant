# app.coffee
#
# This file handles the parsing of command-line arguments and dispatches to
# other pieces of the application. No heavy-lifting should be done here.
#

fs = require 'fs'
Rembrant = require('./rembrant').rembrant
libraryTemplate = require('./models/library').libraryTemplate

exports.run = ->
  argv = require('optimist').argv

  if argv.init
    cwd = do process.cwd
    lib = do libraryTemplate
    fs.writeFile 'library.json', lib, (err) ->
      if err
        console.log 'Error writing to disk.'

    return

  if argv.import
    cwd = do process.cwd

    manager = new Rembrant cwd
    do manager.run

    return

  if argv.scan
    console.log 'Not implemented yet'
    return

  if argv.export
    console.log 'Not implemented yet'
    return

  if argv.deploy
    console.log 'Not implemented yet'
    return

  console.log 'Unknown option'
