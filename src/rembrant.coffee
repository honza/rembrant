fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
_ = require 'underscore'

counter = 0

Photo = require('./photo').Photo
Library = require('./library').Library
libraryTemplate = require('./library').libraryTemplate

class Manager

  constructor: (@cwd) ->
    # Read library file, parse it, create Library instance
    library = path.join cwd, 'library.json'
    @library = JSON.parse fs.readFileSync library, 'utf-8'
    @library = new Library @library
    @hasLibrary = path.existsSync library

    @albums = []

    unless @hasLibrary
      @json = null
      return

  makeCacheDir: =>
    unless @library.cache
      console.log 'Error: "cache" setting is required'
      return
    cache = path.join @cwd, @library.cache
    unless path.existsSync cache
      fs.mkdir cache, '0777', (err) ->
        if err
          console.log err

  parsePhotos: (album) ->
    photos = album.photos
    album.photos = []
    for photo in photos
      p = new Photo photo
      album.photos.push p
    album

  run:  =>
    do @makeCacheDir
    do @importPhotos

  importPhotos: ->

    unless @library.source
      console.log "library.json error; missing 'source'"
      return

    source = path.join @cwd, @library.source
    filenames = fs.readdirSync source
    photos = []

    for file in filenames
      filename = path.join source, file

      photo = new Photo
        filename: filename

      #do photo.getSHA

      photo.on 'done', =>
        counter++
        if counter is filenames.length
          console.log 'finished'
          @library.photos = photos
          @library.emit 'changed'

      photos.push photo

    console.log 'end of importing'


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

    manager = new Manager cwd
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
