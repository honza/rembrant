window.Rembrant = {}


class Photo extends Backbone.Model
    thumb: (size) ->
        "/image/#{@get('filename').split('.')[0]}_#{size}.jpg"


class Album extends Backbone.Model


class PhotoCollection extends Backbone.Collection
    model: Photo
    url: '/photos'

    selected: ->
        @filter (photo) -> photo.get 'selected'

    photosForAlbum: (album) ->
        Rembrant.app.photos.filter (photo) ->
            album.get('id') in photo.get('albums')


class AlbumCollection extends Backbone.Collection
    model: Album
    url: '/albums'


class PhotoView extends Backbone.View

    events:
        'click a': 'clickImage'

    tagName: 'li'

    render: ->
        @$el.html """
            <a href="#" class="thumbnail">
                <img src='#{@model.thumb(160)}' />
            </a>
            """
        @$el

    clickImage: ->
        if @model.get("selected")
            @model.set "selected", false
            @$el.find('a').removeClass 'hover'
        else
            @model.set "selected", true
            @$el.find('a').addClass 'hover'
        false


class AlbumView extends Backbone.View

    tagName: 'li'

    events:
        "click": "click"

    click: ->
        photos = Rembrant.app.photos.photosForAlbum @model
        Rembrant.app.render null, null, photos
        false

    render: ->
        @$el.html "<a href=''>#{@model.get('name')}</a>"
        @$el


class TopBar extends Backbone.View

    events:
        "click #home": "clickHome"
        "click #add-album": "clickAddAlbum"
        "click #selection-action": "clickSelection"

    initialize: ->
        @$el = $ '#top'
        @$selection = @$el.find('#selection-action')

        Rembrant.app.photos.on 'change', @updateSelection, @

    clickHome: ->
        console.log 'Click home'
        false

    clickAddAlbum: ->
        new ModalView
        false

    clickSelection: ->
        new AddSelectionToAlbumModalView
        false

    updateSelection: ->
        selected = Rembrant.app.photos.selected()

        if selected.length is 0
            text = ''
        else
            text = "Add selection to album (#{selected.length})"

        @$selection.text text


class ModalView extends Backbone.View

    events:
        'click .save': 'save'
        'click .cancel': 'close'

    save: ->
        album = new Album
            name: @input.val()
        Rembrant.app.albums.add album
        album.save()
        @input.val ''
        @$el.modal 'hide'
        false

    close: ->
        @input.val ''
        @$el.modal 'hide'

    initialize: ->
        @$el = $ '#addAlbumModal'
        @$el.modal 'show'
        @input = @$el.find('.input-medium')


class AddSelectionToAlbumModalView extends Backbone.View

    events:
        'click .save': 'save'
        'click .cancel': 'close'

    initialize: ->
        @$el = $ '#addSelectionToAlbum'
        @$el.modal 'show'
        @select = @$el.find('select')
        @populate()

    save: ->
        value = @select.val()
        selected = Rembrant.app.photos.selected()
        console.log selected

        for photo in selected
            albums = photo.get 'albums'
            albums.push parseInt value
            photo.set 'albums', albums
            console.log photo.isNew()
            photo.save()
        false

    close: ->

    populate: ->
        albums = Rembrant.app.albums.models
        @select.empty()
        for album in albums
            @select.append """
            <option value="#{album.get('id')}">#{album.get('name')}</option>
            """


class Application extends Backbone.View

    initialize: ->
        @$el = $ '#root'
        @$side = $ '#albums'

        @photos = new PhotoCollection
        @photos.on 'reset', @render, @
        @photos.fetch()

        @albums = new AlbumCollection
        @albums.on 'reset', @renderAlbums, @
        @albums.on 'add', @addAlbum, @
        @albums.fetch()


    render: (photos, b, myPhotos) ->
        if myPhotos
            photos = myPhotos
        else
            photos = @photos.models

        @$el.empty()

        for photo in photos
            view = new PhotoView model: photo
            @$el.append view.render()

    renderAlbums: ->
        @$side.append "<li><a href=''>All</a></li>"

        for album in @albums.models
            view = new AlbumView model: album
            @$side.append view.render()

    addAlbum: (album) ->
        view = new AlbumView model: album
        @$side.append view.render()


$ ->
    Rembrant.app = new Application
    Rembrant.topBar = new TopBar
