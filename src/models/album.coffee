Photo = require('./photo').Photo

class Album

  constructor: (@obj) ->
    @photos = do @parsePhotos
    @name = @obj.name

  parsePhotos: ->
    photos = []
    for photo in @obj.photos
      photos.push new Photo photo

  toJSON: =>
    photos = [p.toJSON() for p in @photos]
    obj =
      name: @name
      photos: photos
    return obj


exports.Album = Album
