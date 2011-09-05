(function() {
  var EventEmitter, Photo, crypto, fs, im, path;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  fs = require('fs');
  path = require('path');
  crypto = require('crypto');
  EventEmitter = require('events').EventEmitter;
  im = require('imagemagick');
  Photo = (function() {
    __extends(Photo, EventEmitter);
    function Photo(json) {
      this._makeSmallThumb = __bind(this._makeSmallThumb, this);
      this._makeLargeThumb = __bind(this._makeLargeThumb, this);
      this.makeThumbs = __bind(this.makeThumbs, this);      this.library = json.library;
      this.title = json.title || "";
      this.filename = json.filename;
      this.caption = json.caption || "";
      this.album = json.album || "";
      this.sha = json.sha || this.getSHA();
    }
    Photo.prototype.getSmallThumbUrl = function() {
      return "" + this.sha + "-100.jpg";
    };
    Photo.prototype.getLargeThumbUrl = function() {
      return "" + this.sha + "-800.jpg";
    };
    Photo.prototype.getSHA = function() {
      var s, sum;
      sum = crypto.createHash('sha1');
      s = fs.ReadStream(this.filename);
      s.on('data', function(d) {
        return sum.update(d);
      });
      s.on('end', __bind(function() {
        this.sha = sum.digest('hex');
        return this.emit('done');
      }, this));
      return '';
    };
    Photo.prototype.makeThumbs = function() {
      if (!this.sha) {
        console.log("" + this.filename + " has no SHA.");
        return;
      }
      this._makeLargeThumb();
      return this._makeSmallThumb();
    };
    Photo.prototype._makeLargeThumb = function() {
      var dest, options;
      dest = path.join(this.libraryroot, this.library.cache, this.sha + "-100.jpg");
      if (path.existsSync(dest)) {
        return;
      }
      options = {
        srcPath: this.filename,
        dstPath: dest,
        width: 100
      };
      return im.resize(options, function(err, stdout, stderr) {
        if (err) {
          return console.log('Error creating thumbnail');
        }
      });
    };
    Photo.prototype._makeSmallThumb = function() {
      var dest, options;
      dest = path.join(this.libraryroot, this.library.cache, this.sha + "-800.jpg");
      if (path.existsSync(dest)) {
        return;
      }
      options = {
        srcPath: this.filename,
        dstPath: dest,
        width: 800
      };
      return im.resize(options, function(err, stdout, stderr) {
        if (err) {
          return console.log('Error creating thumbnail');
        }
      });
    };
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
    return Photo;
  })();
  exports.Photo = Photo;
}).call(this);
