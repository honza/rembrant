(function() {
  var Library, Manager, Photo, counter, crypto, fs, libraryTemplate, path, _;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  fs = require('fs');
  path = require('path');
  crypto = require('crypto');
  _ = require('underscore');
  counter = 0;
  Photo = require('./photo').Photo;
  Library = require('./library').Library;
  libraryTemplate = require('./library').libraryTemplate;
  Manager = (function() {
    function Manager(cwd) {
      var library;
      this.cwd = cwd;
      this.run = __bind(this.run, this);
      this.makeCacheDir = __bind(this.makeCacheDir, this);
      library = path.join(cwd, 'library.json');
      if (!path.existsSync(library)) {
        console.log(library);
        throw "Couldn't find library.json";
        return;
      }
      this.library = JSON.parse(fs.readFileSync(library, 'utf-8'));
      this.library = new Library(this.library, this.cwd);
      this.hasLibrary = path.existsSync(library);
      this.albums = [];
      if (!this.hasLibrary) {
        this.json = null;
        return;
      }
    }
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
      var file, filename, filenames, photo, photos, source, _i, _len, _results;
      if (!this.library.source) {
        console.log("library.json error; missing 'source'");
        return;
      }
      source = path.join(this.cwd, this.library.source);
      filenames = fs.readdirSync(source);
      photos = [];
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
            this.library.photos = photos;
            this.library.emit('changed');
            return this.library.emit('makeThumbs');
          }
        }, this));
        _results.push(photos.push(photo));
      }
      return _results;
    };
    return Manager;
  })();
  exports.run = function() {
    var argv, cwd, lib, manager;
    argv = require('optimist').argv;
    if (argv.init) {
      cwd = process.cwd();
      lib = libraryTemplate();
      fs.writeFile('library.json', lib, function(err) {
        if (err) {
          return console.log('Error writing to disk.');
        }
      });
      return;
    }
    if (argv["import"]) {
      cwd = process.cwd();
      manager = new Manager(cwd);
      manager.run();
      return;
    }
    if (argv.scan) {
      console.log('Not implemented yet');
      return;
    }
    if (argv["export"]) {
      console.log('Not implemented yet');
      return;
    }
    if (argv.deploy) {
      console.log('Not implemented yet');
      return;
    }
    return console.log('Unknown option');
  };
}).call(this);
