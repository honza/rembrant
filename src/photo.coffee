fs = require 'fs'
crypto = require 'crypto'
{EventEmitter} = require 'events'


class Photo extends EventEmitter

  constructor: (json) ->
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
