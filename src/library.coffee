fs = require 'fs'
{EventEmitter} = require 'events'

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

# Create a simple library.json template string
exports.libraryTemplate = ->
  now = new Date
  template =
    source: "source"
    cache: "cache"
    lastModified: formatDate now
  JSON.stringify template, null, 4
