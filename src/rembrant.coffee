fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
_ = require 'underscore'

counter = 0

Photo = require('./photo').Photo
Library = require('./library').Library

class Manager

  constructor: (@cwd) ->
    library = path.join cwd, 'library.json'
    @library = JSON.parse fs.readFileSync library, 'utf-8'
    @library = new Library @library
    @hasLibrary = path.existsSync library
    @albums = []

    unless @hasLibrary
      @json = null
      return

    #for a in @json.albums
      #@albums.push @parsePhotos a

  parsePhotos: (album) ->
    photos = album.photos
    album.photos = []
    for photo in photos
      p = new Photo photo
      album.photos.push p
    album

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
    console.log 'Not implemented yet'
    return

  if argv.import
    cwd = do process.cwd

    manager = new Manager cwd
    do manager.importPhotos

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
