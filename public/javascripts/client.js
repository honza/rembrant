// Generated by CoffeeScript 1.3.3
(function() {
  var AddSelectionToAlbumModalView, Album, AlbumCollection, AlbumView, Application, ModalView, Photo, PhotoCollection, PhotoView, TopBar,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.Rembrant = {};

  Photo = (function(_super) {

    __extends(Photo, _super);

    function Photo() {
      return Photo.__super__.constructor.apply(this, arguments);
    }

    Photo.prototype.thumb = function(size) {
      return "/image/" + (this.get('filename').split('.')[0]) + "_" + size + ".jpg";
    };

    return Photo;

  })(Backbone.Model);

  Album = (function(_super) {

    __extends(Album, _super);

    function Album() {
      return Album.__super__.constructor.apply(this, arguments);
    }

    return Album;

  })(Backbone.Model);

  PhotoCollection = (function(_super) {

    __extends(PhotoCollection, _super);

    function PhotoCollection() {
      return PhotoCollection.__super__.constructor.apply(this, arguments);
    }

    PhotoCollection.prototype.model = Photo;

    PhotoCollection.prototype.url = '/photos';

    PhotoCollection.prototype.selected = function() {
      return this.filter(function(photo) {
        return photo.get('selected');
      });
    };

    PhotoCollection.prototype.photosForAlbum = function(album) {
      return Rembrant.app.photos.filter(function(photo) {
        var _ref;
        return _ref = album.get('id'), __indexOf.call(photo.get('albums'), _ref) >= 0;
      });
    };

    return PhotoCollection;

  })(Backbone.Collection);

  AlbumCollection = (function(_super) {

    __extends(AlbumCollection, _super);

    function AlbumCollection() {
      return AlbumCollection.__super__.constructor.apply(this, arguments);
    }

    AlbumCollection.prototype.model = Album;

    AlbumCollection.prototype.url = '/albums';

    return AlbumCollection;

  })(Backbone.Collection);

  PhotoView = (function(_super) {

    __extends(PhotoView, _super);

    function PhotoView() {
      return PhotoView.__super__.constructor.apply(this, arguments);
    }

    PhotoView.prototype.events = {
      'click a': 'clickImage'
    };

    PhotoView.prototype.tagName = 'li';

    PhotoView.prototype.render = function() {
      this.$el.html("<a href=\"#\" class=\"thumbnail\">\n    <img src='" + (this.model.thumb(160)) + "' />\n</a>");
      return this.$el;
    };

    PhotoView.prototype.clickImage = function() {
      if (this.model.get("selected")) {
        this.model.set("selected", false);
        this.$el.find('a').removeClass('hover');
      } else {
        this.model.set("selected", true);
        this.$el.find('a').addClass('hover');
      }
      return false;
    };

    return PhotoView;

  })(Backbone.View);

  AlbumView = (function(_super) {

    __extends(AlbumView, _super);

    function AlbumView() {
      return AlbumView.__super__.constructor.apply(this, arguments);
    }

    AlbumView.prototype.tagName = 'li';

    AlbumView.prototype.events = {
      "click": "click"
    };

    AlbumView.prototype.click = function() {
      var photos;
      photos = Rembrant.app.photos.photosForAlbum(this.model);
      Rembrant.app.render(null, null, photos);
      return false;
    };

    AlbumView.prototype.render = function() {
      this.$el.html("<a href=''>" + (this.model.get('name')) + "</a>");
      return this.$el;
    };

    return AlbumView;

  })(Backbone.View);

  TopBar = (function(_super) {

    __extends(TopBar, _super);

    function TopBar() {
      return TopBar.__super__.constructor.apply(this, arguments);
    }

    TopBar.prototype.events = {
      "click #home": "clickHome",
      "click #add-album": "clickAddAlbum",
      "click #selection-action": "clickSelection"
    };

    TopBar.prototype.initialize = function() {
      this.$el = $('#top');
      this.$selection = this.$el.find('#selection-action');
      return Rembrant.app.photos.on('change', this.updateSelection, this);
    };

    TopBar.prototype.clickHome = function() {
      console.log('Click home');
      return false;
    };

    TopBar.prototype.clickAddAlbum = function() {
      new ModalView;
      return false;
    };

    TopBar.prototype.clickSelection = function() {
      new AddSelectionToAlbumModalView;
      return false;
    };

    TopBar.prototype.updateSelection = function() {
      var selected, text;
      selected = Rembrant.app.photos.selected();
      if (selected.length === 0) {
        text = '';
      } else {
        text = "Add selection to album (" + selected.length + ")";
      }
      return this.$selection.text(text);
    };

    return TopBar;

  })(Backbone.View);

  ModalView = (function(_super) {

    __extends(ModalView, _super);

    function ModalView() {
      return ModalView.__super__.constructor.apply(this, arguments);
    }

    ModalView.prototype.events = {
      'click .save': 'save',
      'click .cancel': 'close'
    };

    ModalView.prototype.save = function() {
      var album;
      album = new Album({
        name: this.input.val()
      });
      Rembrant.app.albums.add(album);
      album.save();
      this.input.val('');
      this.$el.modal('hide');
      return false;
    };

    ModalView.prototype.close = function() {
      this.input.val('');
      return this.$el.modal('hide');
    };

    ModalView.prototype.initialize = function() {
      this.$el = $('#addAlbumModal');
      this.$el.modal('show');
      return this.input = this.$el.find('.input-medium');
    };

    return ModalView;

  })(Backbone.View);

  AddSelectionToAlbumModalView = (function(_super) {

    __extends(AddSelectionToAlbumModalView, _super);

    function AddSelectionToAlbumModalView() {
      return AddSelectionToAlbumModalView.__super__.constructor.apply(this, arguments);
    }

    AddSelectionToAlbumModalView.prototype.events = {
      'click .save': 'save',
      'click .cancel': 'close'
    };

    AddSelectionToAlbumModalView.prototype.initialize = function() {
      this.$el = $('#addSelectionToAlbum');
      this.$el.modal('show');
      this.select = this.$el.find('select');
      return this.populate();
    };

    AddSelectionToAlbumModalView.prototype.save = function() {
      var albums, photo, selected, value, _i, _len;
      value = this.select.val();
      selected = Rembrant.app.photos.selected();
      console.log(selected);
      for (_i = 0, _len = selected.length; _i < _len; _i++) {
        photo = selected[_i];
        albums = photo.get('albums');
        albums.push(parseInt(value));
        photo.set('albums', albums);
        console.log(photo.isNew());
        photo.save();
      }
      return false;
    };

    AddSelectionToAlbumModalView.prototype.close = function() {};

    AddSelectionToAlbumModalView.prototype.populate = function() {
      var album, albums, _i, _len, _results;
      albums = Rembrant.app.albums.models;
      this.select.empty();
      _results = [];
      for (_i = 0, _len = albums.length; _i < _len; _i++) {
        album = albums[_i];
        _results.push(this.select.append("<option value=\"" + (album.get('id')) + "\">" + (album.get('name')) + "</option>"));
      }
      return _results;
    };

    return AddSelectionToAlbumModalView;

  })(Backbone.View);

  Application = (function(_super) {

    __extends(Application, _super);

    function Application() {
      return Application.__super__.constructor.apply(this, arguments);
    }

    Application.prototype.initialize = function() {
      this.$el = $('#root');
      this.$side = $('#albums');
      this.photos = new PhotoCollection;
      this.photos.on('reset', this.render, this);
      this.photos.fetch();
      this.albums = new AlbumCollection;
      this.albums.on('reset', this.renderAlbums, this);
      this.albums.on('add', this.addAlbum, this);
      return this.albums.fetch();
    };

    Application.prototype.render = function(photos, b, myPhotos) {
      var photo, view, _i, _len, _results;
      if (myPhotos) {
        photos = myPhotos;
      } else {
        photos = this.photos.models;
      }
      this.$el.empty();
      _results = [];
      for (_i = 0, _len = photos.length; _i < _len; _i++) {
        photo = photos[_i];
        view = new PhotoView({
          model: photo
        });
        _results.push(this.$el.append(view.render()));
      }
      return _results;
    };

    Application.prototype.renderAlbums = function() {
      var album, view, _i, _len, _ref, _results;
      this.$side.append("<li><a href=''>All</a></li>");
      _ref = this.albums.models;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        album = _ref[_i];
        view = new AlbumView({
          model: album
        });
        _results.push(this.$side.append(view.render()));
      }
      return _results;
    };

    Application.prototype.addAlbum = function(album) {
      var view;
      view = new AlbumView({
        model: album
      });
      return this.$side.append(view.render());
    };

    return Application;

  })(Backbone.View);

  $(function() {
    Rembrant.app = new Application;
    return Rembrant.topBar = new TopBar;
  });

}).call(this);
