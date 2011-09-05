(function() {
  var Album, Photo;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Photo = require('./photo').Photo;
  Album = (function() {
    function Album(obj) {
      this.obj = obj;
      this.toJSON = __bind(this.toJSON, this);
      this.photos = this.parsePhotos();
      this.name = this.obj.name;
    }
    Album.prototype.parsePhotos = function() {
      var photo, photos, _i, _len, _ref, _results;
      photos = [];
      _ref = this.obj.photos;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        photo = _ref[_i];
        _results.push(photos.push(new Photo(photo)));
      }
      return _results;
    };
    Album.prototype.toJSON = function() {
      var obj, p, photos;
      photos = [
        (function() {
          var _i, _len, _ref, _results;
          _ref = this.photos;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            p = _ref[_i];
            _results.push(p.toJSON());
          }
          return _results;
        }).call(this)
      ];
      obj = {
        name: this.name,
        photos: photos
      };
      return obj;
    };
    return Album;
  })();
  exports.Album = Album;
}).call(this);
