# The main rembrant client file

$ ->

  # Models

  class Photo extends Backbone.Model
    defaults:
      selected: false

  class Album extends Backbone.Model


  # Collections

  class PhotoCollection extends Backbone.Collection

    model: Photo
    url: '/photos'

    selected: ->
      @filter (photo) ->
        photo.get 'selected'

    byAlbum: (album) ->
      @filter (photo) ->
        album.id in photo.get 'albums'

  class AlbumCollection extends Backbone.Collection
    model: Album
    url: '/albums'

  # Views

  class SidebarAlbumView extends Backbone.View
    tagname: 'div'
    className: 'album'

    events:
      'click a': 'click'

    initialize: ->
      do @render

    render: ->
      html = """
      <a href="">#{@model.get 'name'}</a>
      """
      $(@el).html html

    click: ->
      $('.album').removeClass 'album-active'
      $(@el).addClass 'album-active'
      app.gridView.showAlbum @model
      false

  class SidebarView extends Backbone.View
    el: $ '#sidebar'
    events:
      'click #new-album-link': 'newAlbum'
      'click .close': 'close'
      'click #new-album-submit': 'createNewAlbum'
      'click #add-selection-to-album': 'addToAlbum'

    initialize: ->
      @collection.bind 'reset', @render, @
      @collection.bind 'add', @add, @
      @newAlbumBox = $ '#new-album'

    add: (album) ->
      albumView = new SidebarAlbumView model: album
      $('#top').append albumView.el

    render: ->
      for album in @collection.models
        @add album

    # Event handlers

    newAlbum: ->
      do @newAlbumBox.show
      false

    close: ->
      do @newAlbumBox.hide
      false

    createNewAlbum: ->
      name = $('#new-album-name').val()
      @collection.create
        name: name
      do @close

    addToAlbum: ->
      selected = app.photos.selected()
      if selected.length is 0
        return false

      do @$('#album-selection').show
      false

  class AlbumSelectionView extends Backbone.View
    el: $ '#album-selection'
    events:
      'click #confirm-add-to-album': 'confirm'
      'click .close': 'close'

    initialize: ->
      @collection.bind 'all', @render, @
      do @center

    center: ->
      width = do $(window).width
      @el.css
        left: (width - 500) / 2

    render: ->
      for album in @collection.models
        @renderOne album

    renderOne: (album) ->
      html = """
      <li>
        <input type="checkbox" value="#{album.get 'id'}" />
        #{album.get 'name'}
      </li>
      """
      @$('ul').append html

    close: ->
      do @el.hide
      false

    confirm: ->
      checked = @$('input:checked')

      values = (parseInt i.value for i in checked)

      if values.length is 0
        alert 'Please select at least one.'
        return false

      for photo in app.photos.selected()
        original = photo.get 'albums'
        albums = _.union original, values
        photo.set albums: albums
        do photo.save
        do photo.view.remove

      do @el.hide

      false

  class PhotoView extends Backbone.View
    tagName: 'div'
    className: 'photo'

    events:
      'click': 'toggleSelected'
      'dblclick': 'showBigger'

    initialize: ->
      @model.view = @
      do @render
      @model.bind 'change', @render, @

    render: ->
      photo = do @model.toJSON
      html = """
      <img src="/photo/#{photo.sha}_100.jpg" />
      """
      if @model.get 'selected'
        $(@el).addClass 'selected-photo'
      else
        $(@el).removeClass 'selected-photo'
      $(@el).html html

    toggleSelected: ->
      current = @model.get 'selected'
      if current
        @model.set selected: false
      else
        @model.set selected: true

    showBigger: ->
      app.viewer.set @model

  class ViewerView extends Backbone.View
    el: $ '#viewer'
    events:
      'click': 'hide'

    initialize: ->
      width = do $('body').width
      $(@el).css
        left: (width - 800) /2

    set: (photo) ->
      html = """
      <img src="/photo/#{photo.get 'sha'}_800.jpg" />
      """
      $(@el).html html

      offset = do $(window).scrollTop
      height = do $(window).height
      $(@el).css
        top: offset + ((height - 573) / 2)

      do $(@el).show

    hide: ->
      do $(@el).hide

  class GridView extends Backbone.View
    el: $ '#grid'

    initialize: ->
      @collection.bind 'reset', @render, @
      @collection.bind 'add', @add, @

    add: (photo) ->
      photoView = new PhotoView model: photo
      @el.append photoView.el

    render: ->
      for photo in @collection.models
        @add photo
      do $('#loading').hide

    clear: ->
      do @el.empty

    showAlbum: (album) ->
      # Show pictures from a certain album
      # photos still belong to the collection
      photos = @collection.byAlbum album
      do @clear
      for photo in photos
        @add photo

  class CounterView extends Backbone.View
    el: $ '#selected-count'

    initialize: ->
      @collection.bind 'all', @render, @

    render: ->
      count = @collection.selected().length
      $(@el).text(count)

  # Router

  class RembrantRouter extends Backbone.Router

    routes:
      '': 'home'

    initialize: ->

    home: ->
      @photos = new PhotoCollection
      @albums = new AlbumCollection

      @sidebarView = new SidebarView collection: @albums
      @gridView = new GridView collection: @photos
      @viewer = new ViewerView
      @counter = new CounterView collection: @photos
      @albumSelectionView = new AlbumSelectionView collection: @albums

      do @photos.fetch
      do @albums.fetch

      #setTimeout =>
        #do @albums.fetch
      #, 2000

  ############################################################################

  # Start the engines
  app = new RembrantRouter
  Backbone.history.start()
