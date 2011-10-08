# The main rembrant client file

class Photo

  constructor: (json) ->
    @id = json.id
    @filename = json.filename
    @sha = json.sha
    @albumId = json.album_id

  render: ->
    """
    <div class="photo">
      <img src="/photo/#{@sha}_800.jpg" />
    </div>
    """


class App

  constructor: ->
    @el = $ '#photos'

  run: ->
    $.getJSON '/photos', null, (response) =>
      console.log response
      for photo in response.photos
        p = new Photo photo
        @el.append do p.render

$ ->
  app = new App
  do app.run
