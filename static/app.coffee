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
      app.app.grid.loadPhotos @model
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
      'click .close':              'closeDialog'

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
      do model.save
      @albums.add model
      $('#new-album-name').val ''
      do @newAlbum.hide

    addAlbum: ->
      left = (app.app.width - 500) / 2
      @newAlbum.css
        left: left
        right: left
      do @newAlbum.show
      false

    closeDialog: ->
      do @newAlbum.hide
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
      left = (app.app.width - 840) / 2
      $(@el).css
        left: left
        right: left
      do $(@el).show
      @
  
  class GridView extends Backbone.View

    el: $ '#photos'

    events:
      'click #get-count':              'getCount'
      'click #add-selection-to-album': 'addToSelection'
      'click #confirm-add-to-album':   'confirmAddToAlbum'
      'click .close':                  'closeDialog'

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

    addToSelection: =>
      @selection = do @photos.selected
      if @selection.length is 0
        return false
      @renderAlbumSelection app.app.sidebar.albums
      false

    renderAlbumSelection: (albums) ->
      html = ""
      for album in albums.models
        model = do album.toJSON # Just to show off a paradigm
        a = """
        <li>
            <input type="checkbox" value="#{model.id}" />
            #{model.name}
        </li>
        """
        html += a
      $('#album-selection ul').html html
      do $('#album-selection').show

    closeDialog: ->
      do $('#album-selection').hide
      $('#album-selection li input:checked').attr('checked', '')
      false

    confirmAddToAlbum: =>
      selected = $('#album-selection li input:checked')
      selected = (s.value for s in selected)
      console.log @selection
      for photo in @selection
        original = photo.get 'albums'
        for s in selected
          s = parseInt s, 10
          if s not in original
            original.push s
        photo.save
          albums: original
          silent: true

      do $('#album-selection').hide
      false

    render: =>
      count = @photos.selected().length
      @$('#selected-count').text count
      @

  class Application extends Backbone.View

    initialize: ->
      @grid = new GridView
      @sidebar = new SidebarView
      @width = $('body').width()

  class RembrantRouter extends Backbone.Router

    routes:
      '': 'home'

    initialize: ->
      @app = new Application

    home: ->

  ############################################################################

  # Start the engines
  app = new RembrantRouter 
  Backbone.history.start()







