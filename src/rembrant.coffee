fs = require 'fs'
path = require 'path'


class Photo

  constructor: (json) ->
    @title =  json.title or ""
    @filename =  json.filename
    @caption =  json.caption or ""
    @album =  json.album or ""
    @sha =  json.sha or @getSHA()
    @smallThumb =  "#{@sha}-100.jpg"
    @bigThumb =  "#{@sha}-800.jpg"

  toJSON: ->
    {
      title: @title
      filename: @filename
      caption: @caption
      album: @album
      sha: @sha
      smallThumb: @smallThumb
      bigThumb: @bigThumb
    }

  getSHA: ->
    "abc-SHA"


class Manager

  constructor: (cwd) ->
    library = path.join cwd, 'library.json'
    json = fs.readFileSync library, 'utf-8'
    @json = JSON.parse json

    @albums = []
    for a in @json.albums
      @albums.push @parsePhotos a

  parsePhotos: (album) ->
    photos = album.photos
    album.photos = []
    for photo in photos
      p = new Photo photo
      album.photos.push p
    album

  makeTree: ->
    for album in @albums
      console.log album.name
      for photo in album.photos
        console.log "  #{photo.filename} - #{photo.sha}"


exports.run = ->
  argv = require('optimist').argv
  cwd = do process.cwd

  manager = new Manager cwd
  do manager.makeTree
