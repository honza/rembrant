(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  $(function() {
    var Album, AlbumCollection, AlbumSelectionView, CounterView, GridView, Photo, PhotoCollection, PhotoView, RembrantRouter, SidebarAlbumView, SidebarView, ViewerView, app;
    Photo = (function(_super) {

      __extends(Photo, _super);

      function Photo() {
        Photo.__super__.constructor.apply(this, arguments);
      }

      Photo.prototype.defaults = {
        selected: false
      };

      return Photo;

    })(Backbone.Model);
    Album = (function(_super) {

      __extends(Album, _super);

      function Album() {
        Album.__super__.constructor.apply(this, arguments);
      }

      return Album;

    })(Backbone.Model);
    PhotoCollection = (function(_super) {

      __extends(PhotoCollection, _super);

      function PhotoCollection() {
        PhotoCollection.__super__.constructor.apply(this, arguments);
      }

      PhotoCollection.prototype.model = Photo;

      PhotoCollection.prototype.url = '/photos';

      PhotoCollection.prototype.selected = function() {
        return this.filter(function(photo) {
          return photo.get('selected');
        });
      };

      PhotoCollection.prototype.byAlbum = function(album) {
        return this.filter(function(photo) {
          var _ref;
          return _ref = album.id, __indexOf.call(photo.get('albums'), _ref) >= 0;
        });
      };

      return PhotoCollection;

    })(Backbone.Collection);
    AlbumCollection = (function(_super) {

      __extends(AlbumCollection, _super);

      function AlbumCollection() {
        AlbumCollection.__super__.constructor.apply(this, arguments);
      }

      AlbumCollection.prototype.model = Album;

      AlbumCollection.prototype.url = '/albums';

      return AlbumCollection;

    })(Backbone.Collection);
    SidebarAlbumView = (function(_super) {

      __extends(SidebarAlbumView, _super);

      function SidebarAlbumView() {
        SidebarAlbumView.__super__.constructor.apply(this, arguments);
      }

      SidebarAlbumView.prototype.tagname = 'div';

      SidebarAlbumView.prototype.className = 'album';

      SidebarAlbumView.prototype.events = {
        'click a': 'click'
      };

      SidebarAlbumView.prototype.initialize = function() {
        return this.render();
      };

      SidebarAlbumView.prototype.render = function() {
        var html;
        html = "<a href=\"\">" + (this.model.get('name')) + "</a>";
        return $(this.el).html(html);
      };

      SidebarAlbumView.prototype.click = function() {
        $('.album').removeClass('album-active');
        $(this.el).addClass('album-active');
        app.gridView.showAlbum(this.model);
        return false;
      };

      return SidebarAlbumView;

    })(Backbone.View);
    SidebarView = (function(_super) {

      __extends(SidebarView, _super);

      function SidebarView() {
        SidebarView.__super__.constructor.apply(this, arguments);
      }

      SidebarView.prototype.el = $('#sidebar');

      SidebarView.prototype.events = {
        'click #new-album-link': 'newAlbum',
        'click .close': 'close',
        'click #new-album-submit': 'createNewAlbum',
        'click #add-selection-to-album': 'addToAlbum'
      };

      SidebarView.prototype.initialize = function() {
        this.collection.bind('reset', this.render, this);
        this.collection.bind('add', this.add, this);
        return this.newAlbumBox = $('#new-album');
      };

      SidebarView.prototype.add = function(album) {
        var albumView;
        albumView = new SidebarAlbumView({
          model: album
        });
        return $('#top').append(albumView.el);
      };

      SidebarView.prototype.render = function() {
        var album, _i, _len, _ref, _results;
        _ref = this.collection.models;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          album = _ref[_i];
          _results.push(this.add(album));
        }
        return _results;
      };

      SidebarView.prototype.newAlbum = function() {
        this.newAlbumBox.show();
        return false;
      };

      SidebarView.prototype.close = function() {
        this.newAlbumBox.hide();
        return false;
      };

      SidebarView.prototype.createNewAlbum = function() {
        var name;
        name = $('#new-album-name').val();
        this.collection.create({
          name: name
        });
        return this.close();
      };

      SidebarView.prototype.addToAlbum = function() {
        var selected;
        selected = app.photos.selected();
        if (selected.length === 0) return false;
        this.$('#album-selection').show();
        return false;
      };

      return SidebarView;

    })(Backbone.View);
    AlbumSelectionView = (function(_super) {

      __extends(AlbumSelectionView, _super);

      function AlbumSelectionView() {
        AlbumSelectionView.__super__.constructor.apply(this, arguments);
      }

      AlbumSelectionView.prototype.el = $('#album-selection');

      AlbumSelectionView.prototype.events = {
        'click #confirm-add-to-album': 'confirm',
        'click .close': 'close'
      };

      AlbumSelectionView.prototype.initialize = function() {
        this.collection.bind('all', this.render, this);
        return this.center();
      };

      AlbumSelectionView.prototype.center = function() {
        var width;
        width = $(window).width();
        return this.el.css({
          left: (width - 500) / 2
        });
      };

      AlbumSelectionView.prototype.render = function() {
        var album, _i, _len, _ref, _results;
        _ref = this.collection.models;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          album = _ref[_i];
          _results.push(this.renderOne(album));
        }
        return _results;
      };

      AlbumSelectionView.prototype.renderOne = function(album) {
        var html;
        html = "<li>\n  <input type=\"checkbox\" value=\"" + (album.get('id')) + "\" />\n  " + (album.get('name')) + "\n</li>";
        return this.$('ul').append(html);
      };

      AlbumSelectionView.prototype.close = function() {
        this.el.hide();
        return false;
      };

      AlbumSelectionView.prototype.confirm = function() {
        var albums, checked, i, original, photo, values, _i, _len, _ref;
        checked = this.$('input:checked');
        values = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = checked.length; _i < _len; _i++) {
            i = checked[_i];
            _results.push(parseInt(i.value));
          }
          return _results;
        })();
        if (values.length === 0) {
          alert('Please select at least one.');
          return false;
        }
        _ref = app.photos.selected();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          photo = _ref[_i];
          original = photo.get('albums');
          albums = _.union(original, values);
          photo.set({
            albums: albums
          });
          photo.save();
          photo.view.remove();
        }
        this.el.hide();
        return false;
      };

      return AlbumSelectionView;

    })(Backbone.View);
    PhotoView = (function(_super) {

      __extends(PhotoView, _super);

      function PhotoView() {
        PhotoView.__super__.constructor.apply(this, arguments);
      }

      PhotoView.prototype.tagName = 'div';

      PhotoView.prototype.className = 'photo';

      PhotoView.prototype.events = {
        'click': 'toggleSelected',
        'dblclick': 'showBigger'
      };

      PhotoView.prototype.initialize = function() {
        this.model.view = this;
        this.render();
        return this.model.bind('change', this.render, this);
      };

      PhotoView.prototype.render = function() {
        var html, photo;
        photo = this.model.toJSON();
        html = "<img src=\"/photo/" + photo.sha + "_100.jpg\" />";
        if (this.model.get('selected')) {
          $(this.el).addClass('selected-photo');
        } else {
          $(this.el).removeClass('selected-photo');
        }
        return $(this.el).html(html);
      };

      PhotoView.prototype.toggleSelected = function() {
        var current;
        current = this.model.get('selected');
        if (current) {
          return this.model.set({
            selected: false
          });
        } else {
          return this.model.set({
            selected: true
          });
        }
      };

      PhotoView.prototype.showBigger = function() {
        return app.viewer.set(this.model);
      };

      return PhotoView;

    })(Backbone.View);
    ViewerView = (function(_super) {

      __extends(ViewerView, _super);

      function ViewerView() {
        ViewerView.__super__.constructor.apply(this, arguments);
      }

      ViewerView.prototype.el = $('#viewer');

      ViewerView.prototype.events = {
        'click': 'hide'
      };

      ViewerView.prototype.initialize = function() {
        var width;
        width = $('body').width();
        return $(this.el).css({
          left: (width - 800) / 2
        });
      };

      ViewerView.prototype.set = function(photo) {
        var height, html, offset;
        html = "<img src=\"/photo/" + (photo.get('sha')) + "_800.jpg\" />";
        $(this.el).html(html);
        offset = $(window).scrollTop();
        height = $(window).height();
        $(this.el).css({
          top: offset + ((height - 573) / 2)
        });
        return $(this.el).show();
      };

      ViewerView.prototype.hide = function() {
        return $(this.el).hide();
      };

      return ViewerView;

    })(Backbone.View);
    GridView = (function(_super) {

      __extends(GridView, _super);

      function GridView() {
        GridView.__super__.constructor.apply(this, arguments);
      }

      GridView.prototype.el = $('#grid');

      GridView.prototype.initialize = function() {
        this.collection.bind('reset', this.render, this);
        return this.collection.bind('add', this.add, this);
      };

      GridView.prototype.add = function(photo) {
        var photoView;
        photoView = new PhotoView({
          model: photo
        });
        return this.el.append(photoView.el);
      };

      GridView.prototype.render = function() {
        var photo, _i, _len, _ref;
        _ref = this.collection.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          photo = _ref[_i];
          this.add(photo);
        }
        return $('#loading').hide();
      };

      GridView.prototype.clear = function() {
        return this.el.empty();
      };

      GridView.prototype.showAlbum = function(album) {
        var photo, photos, _i, _len, _results;
        photos = this.collection.byAlbum(album);
        this.clear();
        _results = [];
        for (_i = 0, _len = photos.length; _i < _len; _i++) {
          photo = photos[_i];
          _results.push(this.add(photo));
        }
        return _results;
      };

      return GridView;

    })(Backbone.View);
    CounterView = (function(_super) {

      __extends(CounterView, _super);

      function CounterView() {
        CounterView.__super__.constructor.apply(this, arguments);
      }

      CounterView.prototype.el = $('#selected-count');

      CounterView.prototype.initialize = function() {
        return this.collection.bind('all', this.render, this);
      };

      CounterView.prototype.render = function() {
        var count;
        count = this.collection.selected().length;
        return $(this.el).text(count);
      };

      return CounterView;

    })(Backbone.View);
    RembrantRouter = (function(_super) {

      __extends(RembrantRouter, _super);

      function RembrantRouter() {
        RembrantRouter.__super__.constructor.apply(this, arguments);
      }

      RembrantRouter.prototype.routes = {
        '': 'home'
      };

      RembrantRouter.prototype.initialize = function() {};

      RembrantRouter.prototype.home = function() {
        this.photos = new PhotoCollection;
        this.albums = new AlbumCollection;
        this.sidebarView = new SidebarView({
          collection: this.albums
        });
        this.gridView = new GridView({
          collection: this.photos
        });
        this.viewer = new ViewerView;
        this.counter = new CounterView({
          collection: this.photos
        });
        this.albumSelectionView = new AlbumSelectionView({
          collection: this.albums
        });
        this.photos.fetch();
        return this.albums.fetch();
      };

      return RembrantRouter;

    })(Backbone.Router);
    app = new RembrantRouter;
    return Backbone.history.start();
  });

}).call(this);
