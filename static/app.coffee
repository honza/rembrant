# The main rembrant client file

$ ->

  # Models

  class Photo extends Backbone.Model
  class Album extends Backbone.Model


  # Collections

  class PhotoCollection extends Backbone.Collection

    model: Photo
    url: '/photos'

    selected: ->
      @filter (photo) ->
        photo.get 'selected'


  class AlbumCollection extends Backbone.Collection
    model: Album
    url: '/albums'

  # Views

  class AlbumLink extends Backbone.View

    tagName: 'li'
    events:
      'click a': 'handleClick'

    handleClick: =>
      app.grid.loadPhotos @model
      false

    render: ->
      html = """<a href="">#{@model.get 'name'}</a>"""
      $(@el).html html
      @

  class SidebarView extends Backbone.View

    el: $ '#sidebar'

    constructor: ->
      @albums = new AlbumCollection
      @albums.bind 'add', @addOne
      @albums.bind 'reset', @addAll
      @albums.bind 'all', @render

      do @albums.fetch

    addOne: (album) =>
      view = new AlbumLink model: album
      @el.append view.render().el

    addAll: => @albums.each @addOne

    render: ->


  class PhotoView extends Backbone.View

    events:
      'click img': 'toggleSelect'

    toggleSelect: ->
      if @model.get 'selected'
        $(@el).removeClass 'selected-photo'
        @model.unset 'selected'
      else
        $(@el).addClass 'selected-photo'
        @model.set selected: true


    render: ->
      html = """
      <img src="/photo/#{@model.get 'sha'}_100.jpg" />
      """
      $(@el).addClass 'photo'
      $(@el).html html
      @


  class GridView extends Backbone.View

    el: $ '#photos'

    events:
      'click #get-count': 'getCount'

    constructor: ->
      do @delegateEvents
      do @loadPhotos

    loadPhotos: (album) ->
      do @clear
      @photos = new PhotoCollection
      if album
        @photos.url = "/albums/#{album.get 'id'}/photos"
      @photos.bind 'add', @addOne
      @photos.bind 'reset', @addAll
      @photos.bind 'all', @render

      do @photos.fetch

    clear: -> $('.photo').remove()

    addOne: (photo) =>
      view = new PhotoView model: photo
      @$('#grid').append view.render().el

    addAll: =>
      @photos.each @addOne

    getCount: =>
      # This is an example of an event handler that does something with the
      # selected photos
      count = @photos.selected().length
      console.log count

    render: =>
      count = @photos.selected().length
      @$('#selected-count').text count
      @

  class Application extends Backbone.View

    constructor: ->
      @grid = new GridView
      @sidebar = new SidebarView

  ############################################################################

  # Start the engines
  app = new Application
