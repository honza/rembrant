path = require 'path'


class Photo
  # filename is unique, no id is necessary

  constructor: (@filename, @dir, @albums=[1], @exif={}) ->

  @fromJSON: (json) ->
    p = new Photo json.filename, json.dir, json.albums, json.exif

  getHtmlName: ->
    base = path.basename @filename, '.jpg'
    base + '.html'

  getThumb: (width) ->
    base = path.basename @filename, '.jpg'
    "#{base}_#{width}.jpg"

exports.Photo = Photo
