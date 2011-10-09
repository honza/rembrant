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
    var GridView, Photo, PhotoCollection, PhotoView, grid;
    Photo = (function() {
      __extends(Photo, Backbone.Model);
      function Photo() {
        Photo.__super__.constructor.apply(this, arguments);
      }
      return Photo;
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
      GridView.prototype.el = $('#photos');
      GridView.prototype.events = {
        'click #get-count': 'getCount'
      };
      function GridView() {
        this.render = __bind(this.render, this);
        this.getCount = __bind(this.getCount, this);
        this.addAll = __bind(this.addAll, this);
        this.addOne = __bind(this.addOne, this);        this.photos = new PhotoCollection;
        this.photos.bind('add', this.addOne);
        this.photos.bind('reset', this.addAll);
        this.photos.bind('all', this.render);
        this.photos.fetch();
        this.delegateEvents();
      }
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
    return grid = new GridView;
  });
}).call(this);
