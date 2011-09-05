fs = require 'fs'
{EventEmitter} = require 'events'
Album = require './album'

# formatDate
#
# take Date object and return a date string formated like this:
#   YYYY-MM-DD HH:MM:SS
formatDate = (d) ->
  pad = (n) ->
    if n < 10
      return "0#{n}"
    n

  date = "#{do d.getFullYear}-#{pad do d.getMonth}-#{pad do d.getDate}"
  time = "#{pad do d.getHours}:#{pad do d.getMinutes}:#{pad do d.getSeconds}"

  return "#{date} #{time}"

class Library extends EventEmitter

  constructor: (@json, @root) ->
    @source = @json.source
    @cache = @json.cache
    @albums = []

    @on 'changed', =>
      console.log 'Saving library'
      fs.writeFile 'library.json', @toJSON(), (err) ->
        if err
          console.log "Error saving library.json."

    @on 'makeThumbs', =>
      for album in @albums
        for photo in album.photos
          do photo.makeThumbs

  parseAlbums: ->
    albums = []
    for album in @json.albums
      albums.push new Album
        name: album.name
        photos: album.photos

    albums

  toJSON: =>
    now = new Date
    #albums = do @parseAlbums
    albums = a.toJSON() for a in @albums
    console.log albums

    json = 
      source: @source
      cache: @cache
      albums: albums or []
      lastModified: formatDate now
    JSON.stringify json, null, 4


exports.Library = Library

# Create a simple library.json template string
exports.libraryTemplate = ->
  now = new Date
  template =
    source: "source"
    cache: "cache"
    albums: []
    lastModified: formatDate now
  JSON.stringify template, null, 4
