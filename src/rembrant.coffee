# rembrant.coffee
#
# This file and the Manager class handles loading and serialization of JSON
# data, creating thumbnails, scanning for new photos, etc. The class is
# initialized in `app.coffee`.

fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
_ = require 'underscore'

counter = 0

Photo = require('./models/photo').Photo
Album = require('./models/album').Album
Library = require('./models/library').Library

class Manager

  constructor: (@cwd) ->
    # Read library file, parse it, create Library instance
    do @loadLibrary

  loadLibrary: ->
    library = path.join @cwd, 'library.json'
    unless path.existsSync library
      throw "Couldn't find library.json"
      return

    file = fs.readFileSync library, 'utf-8'
    if file is ""
      throw "Empty library.json"

    lib = JSON.parse file
    @library = new Library lib, @cwd

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

  # Temporary wrapper for the import logic
  run:  =>
    do @makeCacheDir
    do @importPhotos

  importPhotos: ->

    unless @library.source
      console.log "library.json error; missing 'source'"
      return

    source = path.join @cwd, @library.source

    unless path.existsSync source
      throw "Source '#{source}' doesn't exist."

    filenames = fs.readdirSync source

    unsorted = new Album
      name: 'Unsorted'
      photos: []

    @library.albums = [unsorted]

    for file in filenames
      filename = path.join source, file

      photo = new Photo
        filename: filename
        library: @library

      photo.on 'done', =>
        counter++
        if counter is filenames.length
          @library.emit 'changed'
          @library.emit 'makeThumbs'

      @library.albums[0].photos.push photo






exports.rembrant = Manager
