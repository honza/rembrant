fs = require 'fs'
{EventEmitter} = require 'events'


class Library extends EventEmitter

  constructor: (@json) ->
    @source = @json.source
    @on 'changed', =>
      string = JSON.stringify @toJSON(), null, 4
      fs.writeFile 'library.json', string, (err) ->
        if err
          console.log "Error saving library.json."


  toJSON: =>
    {
      source: @source
      photos: p.toJSON() for p in @photos
    }


exports.Library = Library
