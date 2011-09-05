(function() {
  var Album, Library, Manager, Photo, counter, crypto, fs, path, _;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  fs = require('fs');
  path = require('path');
  crypto = require('crypto');
  _ = require('underscore');
  counter = 0;
  Photo = require('./models/photo').Photo;
  Album = require('./models/album').Album;
  Library = require('./models/library').Library;
  Manager = (function() {
    function Manager(cwd) {
      this.cwd = cwd;
      this.run = __bind(this.run, this);
      this.makeCacheDir = __bind(this.makeCacheDir, this);
      this.loadLibrary();
    }
    Manager.prototype.loadLibrary = function() {
      var file, lib, library;
      library = path.join(this.cwd, 'library.json');
      if (!path.existsSync(library)) {
        throw "Couldn't find library.json";
        return;
      }
      file = fs.readFileSync(library, 'utf-8');
      if (file === "") {
        throw "Empty library.json";
      }
      lib = JSON.parse(file);
      return this.library = new Library(lib, this.cwd);
    };
    Manager.prototype.makeCacheDir = function() {
      var cache;
      if (!this.library.cache) {
        console.log('Error: "cache" setting is required');
        return;
      }
      cache = path.join(this.cwd, this.library.cache);
      if (!path.existsSync(cache)) {
        return fs.mkdir(cache, '0777', function(err) {
          if (err) {
            return console.log(err);
          }
        });
      }
    };
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
    Manager.prototype.run = function() {
      this.makeCacheDir();
      return this.importPhotos();
    };
    Manager.prototype.importPhotos = function() {
      var file, filename, filenames, photo, source, unsorted, _i, _len, _results;
      if (!this.library.source) {
        console.log("library.json error; missing 'source'");
        return;
      }
      source = path.join(this.cwd, this.library.source);
      if (!path.existsSync(source)) {
        throw "Source '" + source + "' doesn't exist.";
      }
      filenames = fs.readdirSync(source);
      unsorted = new Album({
        name: 'Unsorted',
        photos: []
      });
      this.library.albums = [unsorted];
      _results = [];
      for (_i = 0, _len = filenames.length; _i < _len; _i++) {
        file = filenames[_i];
        filename = path.join(source, file);
        photo = new Photo({
          filename: filename,
          library: this.library
        });
        photo.on('done', __bind(function() {
          counter++;
          if (counter === filenames.length) {
            this.library.emit('changed');
            return this.library.emit('makeThumbs');
          }
        }, this));
        _results.push(this.library.albums[0].photos.push(photo));
      }
      return _results;
    };
    return Manager;
  })();
  exports.rembrant = Manager;
}).call(this);
