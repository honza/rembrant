(function() {
  var Album, EventEmitter, Library, formatDate, fs;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  fs = require('fs');
  EventEmitter = require('events').EventEmitter;
  Album = require('./album');
  formatDate = function(d) {
    var date, pad, time;
    pad = function(n) {
      if (n < 10) {
        return "0" + n;
      }
      return n;
    };
    date = "" + (d.getFullYear()) + "-" + (pad(d.getMonth())) + "-" + (pad(d.getDate()));
    time = "" + (pad(d.getHours())) + ":" + (pad(d.getMinutes())) + ":" + (pad(d.getSeconds()));
    return "" + date + " " + time;
  };
  Library = (function() {
    __extends(Library, EventEmitter);
    function Library(json, root) {
      this.json = json;
      this.root = root;
      this.toJSON = __bind(this.toJSON, this);
      this.source = this.json.source;
      this.cache = this.json.cache;
      this.albums = [];
      this.on('changed', __bind(function() {
        console.log('Saving library');
        return fs.writeFile('library.json', this.toJSON(), function(err) {
          if (err) {
            return console.log("Error saving library.json.");
          }
        });
      }, this));
      this.on('makeThumbs', __bind(function() {
        var album, photo, _i, _len, _ref, _results;
        _ref = this.albums;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          album = _ref[_i];
          _results.push((function() {
            var _j, _len2, _ref2, _results2;
            _ref2 = album.photos;
            _results2 = [];
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              photo = _ref2[_j];
              _results2.push(photo.makeThumbs());
            }
            return _results2;
          })());
        }
        return _results;
      }, this));
    }
    Library.prototype.parseAlbums = function() {
      var album, albums, _i, _len, _ref;
      albums = [];
      _ref = this.json.albums;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        album = _ref[_i];
        albums.push(new Album({
          name: album.name,
          photos: album.photos
        }));
      }
      return albums;
    };
    Library.prototype.toJSON = function() {
      var a, albums, json, now, _i, _len, _ref;
      now = new Date;
      _ref = this.albums;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        a = _ref[_i];
        albums = a.toJSON();
      }
      console.log(albums);
      json = {
        source: this.source,
        cache: this.cache,
        albums: albums || [],
        lastModified: formatDate(now)
      };
      return JSON.stringify(json, null, 4);
    };
    return Library;
  })();
  exports.Library = Library;
  exports.libraryTemplate = function() {
    var now, template;
    now = new Date;
    template = {
      source: "source",
      cache: "cache",
      albums: [],
      lastModified: formatDate(now)
    };
    return JSON.stringify(template, null, 4);
  };
}).call(this);
