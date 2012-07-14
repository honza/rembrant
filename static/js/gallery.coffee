# This file is part of rembrant
# Depends on `data`

app = null
router = null
cookie =
    isSmall: 'photoGalleryIsSmall'

photoCount = 200

setIsSmallCookie = (bool) ->
    if bool
        value = '1'
    else
        value = '0'
    $.cookie cookie.isSmall, value

getIsSmallCookie = ->
    $.cookie(cookie.isSmall) is '1'

class Photo extends Backbone.Model
    thumb: (size) -> "#{@get('filename').split('.')[0]}_#{size}.jpg"

class PhotoCollection extends Backbone.Collection
    model: Photo

class PhotoView extends Backbone.View
    events:
        'click a': 'click'

    click: ->
        router.navigate "i/#{@model.get('filename')}", trigger: true

    render: (isThumb) ->
        if isThumb
            span = "span2"
            url = "#{@model.thumb(160)}"
        else
            span = "span12"
            url = "#{@model.thumb(930)}"
        @$el.html """
        <div class="#{span}">
            <a href="javascript:;" class="thumbnail">
                <img src="#{url}" />
            </a>
        </div>
        """

class GalleryView extends Backbone.View

    events:
        'click #big': 'showBig'
        'click #small': 'showSmall'
        'click .pagination a': 'clickPage'

    initialize: ->
        @photoCollection = new PhotoCollection data.photos
        @$el = $ '#root'
        @$photos = $ '#photos'
        @isSmall = getIsSmallCookie()

    clickPage: (e) ->
        page = e.srcElement.innerText
        router.navigate "p/#{page}", trigger: true
        false

    render: ->
        @renderPage 1

    renderSingle: (filename) ->
        i = @photoCollection.find (photo) ->
            filename is photo.get('filename')
        unless i
            return @$photos.html "<h1>Not Found</h1>"
        view = new PhotoView model: i
        @$photos.empty()
        @$photos.append(view.render(false))

    renderPage: (number) ->
        if not number
            number = @page
        number = parseInt number
        @page = number
        @$photos.empty()
        latest = @photoCollection.models

        if number is 1
            end = latest.length
            start = end - photoCount
        else
            end = latest.length - (photoCount * (number - 1)) - 1
            start = end - photoCount
        if start < 0
            start = 0
        latest = latest[start..end].reverse()

        for photo in latest
            view = new PhotoView model: photo
            @$photos.append view.render(@isSmall)

        pagination = $('.pagination ul')
        pagination.empty()
        total = @photoCollection.models.length / photoCount
        counter = 1

        _.times total, ->
            if counter is number
                html = """<li class="active"><a href="javascript:;">#{counter}</a></li>"""
            else
                html = """<li><a href="javascript:;">#{counter}</a></li>"""
            pagination.append html
            counter++

    showBig: ->
        @isSmall = no
        setIsSmallCookie no
        @renderPage()

    showSmall: ->
        @isSmall = yes
        setIsSmallCookie yes
        @renderPage()

class Router extends Backbone.Router
    initialize: (options) ->
        @app = options.app

    routes:
        '': 'root'
        'i/:filename': 'image'
        'p/:number': 'page'

    root: ->
        @app.render()

    image: (image) ->
        @app.renderSingle image

    page: (number) ->
        @app.renderPage number

$ ->
    app = new GalleryView
    router = new Router app: app
    Backbone.history.start()
