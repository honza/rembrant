fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
{EventEmitter} = require 'events'
im = require 'imagemagick'


class Photo extends EventEmitter

  constructor: (json) ->
    @library = json.library
    @title =  json.title or ""
    @filename =  json.filename
    @caption =  json.caption or ""
    @album =  json.album or ""
    @sha =  json.sha or @getSHA()
    @smallThumb =  "#{@sha}-100.jpg"
    @bigThumb =  "#{@sha}-800.jpg"

  getSHA: ->
    sum = crypto.createHash 'sha1'
    s = fs.ReadStream @filename

    s.on 'data', (d) ->
      sum.update d

    s.on 'end', =>
      @sha = sum.digest 'hex'
      @emit 'done'

    ''

  makeThumbs: =>
    unless @sha
      console.log "#{@filename} has no SHA."
      return
    do @_makeLargeThumb
    do @_makeSmallThumb

  _makeLargeThumb: =>

    dest = path.join @libraryroot, @library.cache, @sha + "-100.jpg"

    if path.existsSync dest
      return

    options =
      srcPath: @filename
      dstPath: dest
      width: 100

    im.resize options, (err, stdout, stderr) ->
      if err
        console.log 'Error creating thumbnail'

  _makeSmallThumb: =>

    dest = path.join @libraryroot, @library.cache, @sha + "-800.jpg"

    if path.existsSync dest
      return

    options =
      srcPath: @filename
      dstPath: dest
      width: 800

    im.resize options, (err, stdout, stderr) ->
      if err
        console.log 'Error creating thumbnail'


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


exports.Photo = Photo
