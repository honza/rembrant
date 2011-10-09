# The main rembrant client file

$ ->

  # Models

  class Photo extends Backbone.Model


  # Collections

  class PhotoCollection extends Backbone.Collection

    model: Photo
    url: '/photos'

    selected: ->
      @filter (photo) ->
        photo.get 'selected'

  # Views

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
      @photos = new PhotoCollection
      @photos.bind 'add', @addOne
      @photos.bind 'reset', @addAll
      @photos.bind 'all', @render

      do @photos.fetch
      do @delegateEvents

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

  ############################################################################

  # Start the engines
  grid = new GridView
