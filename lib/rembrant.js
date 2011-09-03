(function() {
  var Library, Manager, Photo, counter, crypto, fs, path, _;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  fs = require('fs');
  path = require('path');
  crypto = require('crypto');
  _ = require('underscore');
  counter = 0;
  Photo = require('./photo').Photo;
  Library = require('./library').Library;
  Manager = (function() {
    function Manager(cwd) {
      var library;
      this.cwd = cwd;
      library = path.join(cwd, 'library.json');
      this.library = JSON.parse(fs.readFileSync(library, 'utf-8'));
      this.library = new Library(this.library);
      this.hasLibrary = path.existsSync(library);
      this.albums = [];
      if (!this.hasLibrary) {
        this.json = null;
        return;
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
    Manager.prototype.importPhotos = function() {
      var file, filename, filenames, photo, photos, source, _i, _len;
      if (!this.library.source) {
        console.log("library.json error; missing 'source'");
        return;
      }
      source = path.join(this.cwd, this.library.source);
      filenames = fs.readdirSync(source);
      photos = [];
      for (_i = 0, _len = filenames.length; _i < _len; _i++) {
        file = filenames[_i];
        filename = path.join(source, file);
        photo = new Photo({
          filename: filename
        });
        photo.on('done', __bind(function() {
          counter++;
          if (counter === filenames.length) {
            console.log('finished');
            this.library.photos = photos;
            return this.library.emit('changed');
          }
        }, this));
        photos.push(photo);
      }
      return console.log('end of importing');
    };
    return Manager;
  })();
  exports.run = function() {
    var argv, cwd, manager;
    argv = require('optimist').argv;
    cwd = process.cwd();
    manager = new Manager(cwd);
    return manager.importPhotos();
  };
}).call(this);
