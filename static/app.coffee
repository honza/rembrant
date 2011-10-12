# The main rembrant client file

$ ->

  # Models

  class Photo extends Backbone.Model
  class Album extends Backbone.Model
    urlRoot: '/albums'


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
    events:
      'click .new-album':          'addAlbum'
      'click #new-album-submit':   'newAlbumSubmit'

    initialize: ->
      @newAlbum = $ '#new-album'


      @albums = new AlbumCollection
      @albums.bind 'add', @addOne
      @albums.bind 'reset', @addAll
      @albums.bind 'all', @render

      do @render
      do @albums.fetch

    addOne: (album) =>
      view = new AlbumLink model: album
      @el.append view.render().el

    addAll: => @albums.each @addOne

    newAlbumSubmit: ->
      albumName = do $('#new-album-name').val
      model = new Album
        name: albumName
      console.log do model.url
      do model.save
      @albums.add model
      $('#new-album-name').val ''
      do @newAlbum.hide

    addAlbum: ->
      left = (app.width - 500) / 2
      @newAlbum.css
        left: left
        right: left
      do @newAlbum.show
      false

    render: ->
      html = """
      <li><a class="new-album" href="">Add new album</a></li>
      """
      $(@el).append html
      @


  class PhotoView extends Backbone.View

    events:
      'click img': 'toggleSelect'
      'dblclick img': 'showLarge'

    toggleSelect: ->
      if @model.get 'selected'
        $(@el).removeClass 'selected-photo'
        @model.unset 'selected'
      else
        $(@el).addClass 'selected-photo'
        @model.set selected: true

    showLarge: =>
      view = new Viewer model: @model
      view.render()


    render: ->
      html = """
      <img src="/photo/#{@model.get 'sha'}_100.jpg" />
      """
      $(@el).addClass 'photo'
      $(@el).html html
      @

  class Viewer extends Backbone.View

    el: $ '#viewer'

    events:
      'click img': 'close'

    close: ->
      do $(@el).hide

    render: ->
      html = """
      <img src="/photo/#{@model.get 'sha'}_800.jpg" />
      """
      $(@el).html html
      left = (app.width - 840) / 2
      $(@el).css
        left: left
        right: left
      do $(@el).show
      @
  

  class GridView extends Backbone.View

    el: $ '#photos'

    events:
      'click #get-count': 'getCount'

    initialize: ->
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

    initialize: ->
      @grid = new GridView
      @sidebar = new SidebarView
      @width = $('body').width()

  ############################################################################

  # Start the engines
  app = new Application
