# Rembrant - photo gallery software
# (c) 2011 - Honza Pokorny - All rights reserved
# Freely available under the terms of the BSD license
# https://github.com/honza/rembrant

fs = require 'fs'
path = require 'path'
_ = require 'underscore'
{spawn, exec} = require 'child_process'
async = require 'async'
eco = require 'eco'
thumb = require('./src/thumbnail.js').thumb
Photo = require('./src/photo.coffee').Photo
exif = require './src/exif.coffee'
rename = require './src/rename.coffee'

baseTemplate = fs.readFileSync __dirname + "/views/base.html", "utf-8"

library =
  source: 'test-photos'
  cache: 'cache'
  lastModified: ''
  awsKey: ''
  awsSecret: ''
  awsBucket: ''
  photos: []
  albums: [
    id: 1
    name: 'Unsorted'
  ]

class Rembrant

  constructor: (filename) ->
    if not path.existsSync filename
      console.log "Path doesn't exist, creating..."
      do @createLibrary
      return

    @library = fs.readFileSync filename, 'utf-8'
    @library = JSON.parse @library

    photos = []

    for photo in @library.photos
      photos.push Photo.fromJSON photo

    @library.photos = photos

  makeThumbs: ->

    thumb
      source: @library.source
      destination: @library.cache
      suffix: '_800'
      concurrency: 2
      width: 800
    , ->
      console.log 'done'

    thumb
      source: @library.source
      destination: @library.cache
      suffix: '_100'
      concurrency: 2
      width: 100
    , ->
      console.log 'done'

  createLibrary: ->
    string = JSON.stringify library
    fs.writeFileSync 'library.json', string

  importPhotos: ->
    files = fs.readdirSync @library.source
    photos = @library.photos or []

    libraryFilenames = _.reject files, (file) ->
      e = path.extname file
      e isnt '.jpg'

    for file in libraryFilenames
      if file not in photos
        photos.push new Photo file, @library.source

    @library.photos = photos

    do @ensureExif
    # do @makeThumbs

  ensureExif: ->
    async.concatSeries @library.photos, exif.readExifImage, (err, list) =>
      console.log 'done'
      do @save

  scan: ->
    files = fs.readdirSync @library.source
    newFiles = _.difference files, _.pluck @library.photos, 'filename'

    for file in newFiles
      console.log file
      @library.photos.push new Photo file

  save: ->
    @library.lastModified = ''
    string = JSON.stringify @library
    fs.writeFileSync 'library.json', string

  imagesByDate: ->
    _.sortBy @library.photos, (image) ->
      image.exif['Exif.Photo.DateTimeOriginal']

  generateIndex: ->
    template = fs.readFileSync __dirname + "/views/front.html", "utf-8"
    html = eco.render template, albums: @library.albums
    @finalizeFile html, 'build/index.html'

  generateAlbums: ->
    template = fs.readFileSync __dirname + "/views/index.html", "utf-8"
    for album in @library.albums
      photos = _.filter @library.photos, (p) ->
        album.id in p.albums
      html = eco.render template, photos: photos
      @finalizeFile html, "build/album-#{album.id}.html"
      
    # and all images on one screen
    html = eco.render template, photos: @library.photos
    @finalizeFile html, 'build/all.html'

  generatePages: ->
    template = fs.readFileSync __dirname + "/views/single.html", "utf-8"
    for photo in @library.photos
      html = eco.render template, photo: photo
      fs.writeFileSync 
      @finalizeFile html, "build/#{do photo.getHtmlName}"

  finalizeFile: (content, filename) ->
    rendered = eco.render baseTemplate, content: content
    fs.writeFileSync filename, rendered

  normalize: ->
    rename.renameFilesInDirectory @library.source, ->
      console.log 'done'

  export: ->
    do @generateIndex
    do @generateAlbums
    do @generatePages


program = require 'commander'

program.version '0.0.1'
program.option '-i, --import'
program.option '-s, --scan'
program.option '-e, --export'
program.option '-t, --thumbs'
program.parse process.argv

r = new Rembrant 'library.json'

if program.thumbs
  do r.makeThumbs

if program.export
  do r.export

if program.import
  do r.importPhotos
