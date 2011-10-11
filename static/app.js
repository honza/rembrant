(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(function() {
    var Album, AlbumCollection, AlbumLink, Application, GridView, Photo, PhotoCollection, PhotoView, SidebarView, app;
    Photo = (function() {
      __extends(Photo, Backbone.Model);
      function Photo() {
        Photo.__super__.constructor.apply(this, arguments);
      }
      return Photo;
    })();
    Album = (function() {
      __extends(Album, Backbone.Model);
      function Album() {
        Album.__super__.constructor.apply(this, arguments);
      }
      return Album;
    })();
    PhotoCollection = (function() {
      __extends(PhotoCollection, Backbone.Collection);
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
      return PhotoCollection;
    })();
    AlbumCollection = (function() {
      __extends(AlbumCollection, Backbone.Collection);
      function AlbumCollection() {
        AlbumCollection.__super__.constructor.apply(this, arguments);
      }
      AlbumCollection.prototype.model = Album;
      AlbumCollection.prototype.url = '/albums';
      return AlbumCollection;
    })();
    AlbumLink = (function() {
      __extends(AlbumLink, Backbone.View);
      function AlbumLink() {
        this.handleClick = __bind(this.handleClick, this);
        AlbumLink.__super__.constructor.apply(this, arguments);
      }
      AlbumLink.prototype.tagName = 'li';
      AlbumLink.prototype.events = {
        'click a': 'handleClick'
      };
      AlbumLink.prototype.handleClick = function() {
        app.grid.loadPhotos(this.model);
        return false;
      };
      AlbumLink.prototype.render = function() {
        var html;
        html = "<a href=\"\">" + (this.model.get('name')) + "</a>";
        $(this.el).html(html);
        return this;
      };
      return AlbumLink;
    })();
    SidebarView = (function() {
      __extends(SidebarView, Backbone.View);
      function SidebarView() {
        this.addAll = __bind(this.addAll, this);
        this.addOne = __bind(this.addOne, this);
        SidebarView.__super__.constructor.apply(this, arguments);
      }
      SidebarView.prototype.el = $('#sidebar');
      SidebarView.prototype.initialize = function() {
        this.albums = new AlbumCollection;
        this.albums.bind('add', this.addOne);
        this.albums.bind('reset', this.addAll);
        this.albums.bind('all', this.render);
        return this.albums.fetch();
      };
      SidebarView.prototype.addOne = function(album) {
        var view;
        view = new AlbumLink({
          model: album
        });
        return this.el.append(view.render().el);
      };
      SidebarView.prototype.addAll = function() {
        return this.albums.each(this.addOne);
      };
      SidebarView.prototype.render = function() {};
      return SidebarView;
    })();
    PhotoView = (function() {
      __extends(PhotoView, Backbone.View);
      function PhotoView() {
        PhotoView.__super__.constructor.apply(this, arguments);
      }
      PhotoView.prototype.events = {
        'click img': 'toggleSelect'
      };
      PhotoView.prototype.toggleSelect = function() {
        if (this.model.get('selected')) {
          $(this.el).removeClass('selected-photo');
          return this.model.unset('selected');
        } else {
          $(this.el).addClass('selected-photo');
          return this.model.set({
            selected: true
          });
        }
      };
      PhotoView.prototype.render = function() {
        var html;
        html = "<img src=\"/photo/" + (this.model.get('sha')) + "_100.jpg\" />";
        $(this.el).addClass('photo');
        $(this.el).html(html);
        return this;
      };
      return PhotoView;
    })();
    GridView = (function() {
      __extends(GridView, Backbone.View);
      function GridView() {
        this.render = __bind(this.render, this);
        this.getCount = __bind(this.getCount, this);
        this.addAll = __bind(this.addAll, this);
        this.addOne = __bind(this.addOne, this);
        GridView.__super__.constructor.apply(this, arguments);
      }
      GridView.prototype.el = $('#photos');
      GridView.prototype.events = {
        'click #get-count': 'getCount'
      };
      GridView.prototype.initialize = function() {
        this.delegateEvents();
        return this.loadPhotos();
      };
      GridView.prototype.loadPhotos = function(album) {
        this.clear();
        this.photos = new PhotoCollection;
        if (album) {
          this.photos.url = "/albums/" + (album.get('id')) + "/photos";
        }
        this.photos.bind('add', this.addOne);
        this.photos.bind('reset', this.addAll);
        this.photos.bind('all', this.render);
        return this.photos.fetch();
      };
      GridView.prototype.clear = function() {
        return $('.photo').remove();
      };
      GridView.prototype.addOne = function(photo) {
        var view;
        view = new PhotoView({
          model: photo
        });
        return this.$('#grid').append(view.render().el);
      };
      GridView.prototype.addAll = function() {
        return this.photos.each(this.addOne);
      };
      GridView.prototype.getCount = function() {
        var count;
        count = this.photos.selected().length;
        return console.log(count);
      };
      GridView.prototype.render = function() {
        var count;
        count = this.photos.selected().length;
        this.$('#selected-count').text(count);
        return this;
      };
      return GridView;
    })();
    Application = (function() {
      __extends(Application, Backbone.View);
      function Application() {
        Application.__super__.constructor.apply(this, arguments);
      }
      Application.prototype.initialize = function() {
        this.grid = new GridView;
        return this.sidebar = new SidebarView;
      };
      return Application;
    })();
    return app = new Application;
  });
}).call(this);
