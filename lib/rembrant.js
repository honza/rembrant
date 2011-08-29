(function() {
  var Manager, Photo, fs, path;
  fs = require('fs');
  path = require('path');
  Photo = (function() {
    function Photo(json) {
      this.title = json.title || "";
      this.filename = json.filename;
      this.caption = json.caption || "";
      this.album = json.album || "";
      this.sha = json.sha || this.getSHA();
      this.smallThumb = "" + this.sha + "-100.jpg";
      this.bigThumb = "" + this.sha + "-800.jpg";
    }
    Photo.prototype.toJSON = function() {
      return {
        title: this.title,
        filename: this.filename,
        caption: this.caption,
        album: this.album,
        sha: this.sha,
        smallThumb: this.smallThumb,
        bigThumb: this.bigThumb
      };
    };
    Photo.prototype.getSHA = function() {
      return "abc-SHA";
    };
    return Photo;
  })();
  Manager = (function() {
    function Manager(cwd) {
      var a, json, library, _i, _len, _ref;
      library = path.join(cwd, 'library.json');
      json = fs.readFileSync(library, 'utf-8');
      this.json = JSON.parse(json);
      this.albums = [];
      _ref = this.json.albums;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        a = _ref[_i];
        this.albums.push(this.parsePhotos(a));
      }
    }
    Manager.prototype.parsePhotos = function(album) {
      var p, photo, photos, _i, _len;
      photos = album.photos;
      album.photos = [];
      for (_i = 0, _len = photos.length; _i < _len; _i++) {
        photo = photos[_i];
        p = new Photo(photo);
        album.photos.push(p);
      }
      return album;
    };
    Manager.prototype.makeTree = function() {
      var album, photo, _i, _len, _ref, _results;
      _ref = this.albums;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        album = _ref[_i];
        console.log(album.name);
        _results.push((function() {
          var _j, _len2, _ref2, _results2;
          _ref2 = album.photos;
          _results2 = [];
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            photo = _ref2[_j];
            _results2.push(console.log("  " + photo.filename + " - " + photo.sha));
          }
          return _results2;
        })());
      }
      return _results;
    };
    return Manager;
  })();
  exports.run = function() {
    var argv, cwd, manager;
    argv = require('optimist').argv;
    cwd = process.cwd();
    manager = new Manager(cwd);
    return manager.makeTree();
  };
}).call(this);
